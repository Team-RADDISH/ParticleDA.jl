module TDAC

using Random, Distributions, Statistics, Distributed, Base.Threads, YAML, GaussianRandomFields, HDF5

export tdac, main

include("params.jl")
include("llw2d.jl")

using .Default_params
using .LLW2d

# grid-to-grid distance
get_distance(i0, j0, i1, j1, dx, dy) =
    sqrt((float(i0 - i1) * dx) ^ 2 + (float(j0 - j1) * dy) ^ 2)

function get_obs!(obs::AbstractVector{T},
                  state::AbstractVector{T},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int},
                  params::tdac_params) where T

    get_obs!(obs,state,params.nx,ist,jst)
    
end

# Return observation data at stations from given model state
function get_obs!(obs::AbstractVector{T},
                  state::AbstractVector{T},
                  nx::Integer,
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int}) where T
    @assert length(obs) == length(ist) == length(jst)
    nn = length(state)
    
    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        iptr = (jj - 1) * nx + ii
        obs[i] = state[iptr]
    end
end

function get_obs_covariance(ist::AbstractVector{Int},
                            jst::AbstractVector{Int},
                            params::tdac_params)

    return get_obs_covariance(params.nobs, params.inv_rr, params.dx, params.dy, ist, jst)
    
end

# Observation covariance matrix based on simple exponential decay
function get_obs_covariance(nobs::Int,
                            inv_rr::Real,
                            dx::Real,
                            dy::Real,
                            ist::AbstractVector{Int},
                            jst::AbstractVector{Int})
    
    @assert nobs == length(ist) == length(jst)
    mu_boo = Matrix{Float64}(undef, nobs, nobs)

    # Estimate background error between stations
    for j in 1:nobs, i in 1:nobs
        # Gaussian correlation function
        dist = get_distance(ist[i], jst[i], ist[j], jst[j], dx, dy)
        mu_boo[i, j] = exp(-(dist * inv_rr) ^ 2)
    end
    
    return mu_boo
end

function tsunami_update!(state::AbstractVector{T},
                         hm::AbstractMatrix{T},
                         hn::AbstractMatrix{T},
                         fm::AbstractMatrix{T},
                         fn::AbstractMatrix{T},
                         fe::AbstractMatrix{T},
                         gg::AbstractMatrix{T},
                         params::tdac_params) where T

    tsunami_update!(state, params.nx, params.ny, params.dim_grid, params.dx, params.dy, params.dt, hm, hn, fm, fn, fe, gg)

end

# Update tsunami wavefield with LLW2d in-place.
function tsunami_update!(state::AbstractVector{T},
                         nx::Int,
                         ny::Int,
                         nn::Int,
                         dx::Real,
                         dy::Real,
                         dt::Real,
                         hm::AbstractMatrix{T},
                         hn::AbstractMatrix{T},
                         fm::AbstractMatrix{T},
                         fn::AbstractMatrix{T},
                         fe::AbstractMatrix{T},
                         gg::AbstractMatrix{T}) where T

    @assert nn == nx * ny
    
    eta_a = reshape(@view(state[1:nn]), nx, ny)
    mm_a  = reshape(@view(state[(nn + 1):(2 * nn)]), nx, ny)
    nn_a  = reshape(@view(state[(2 * nn + 1):(3 * nn)]), nx, ny)
    eta_f = reshape(@view(state[1:nn]), nx, ny)
    mm_f  = reshape(@view(state[(nn + 1):(2 * nn)]), nx, ny)
    nn_f  = reshape(@view(state[(2 * nn + 1):(3 * nn)]), nx, ny)

    # Parts of model vector are aliased to tsunami heiht and velocities
    LLW2d.timestep!(eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, hm, hn, fn, fm, fe, gg, dx, dy, dt)
    
end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from a multivariate normal pdf with mean equal to real observations and covariance equal to observation covariance
function get_weights!(weight::AbstractVector{T},
                      obs::AbstractVector{T},
                      obs_model::AbstractMatrix{T},
                      cov_obs::AbstractMatrix{T}) where T
        
    weight .= Distributions.pdf(Distributions.MvNormal(obs, cov_obs), obs_model) # TODO: Verify that this works
    
    weight ./= sum(weight)
    
end

# Resample particles from given weights using Stochastic Universal Sampling
function resample!(state_resampled::AbstractMatrix{T}, state::AbstractMatrix{T}, weight::AbstractVector{S}) where {T,S}

    ns = size(state,1)
    nprt = size(state,2)
    
    nprt_inv = 1.0 / nprt
    k = 1

    #TODO: Do we need to sort state by weight here?
    
    weight_cdf = cumsum(weight)
    u0 = nprt_inv * Random.rand(S)

    # Note: To parallelise this loop, updates to k and u have to be atomic.
    # TODO: search for better parallel implementations
    for ip in 1:nprt

        u = u0 + (ip - 1) * nprt_inv
        
        while(u > weight_cdf[k])
            k += 1
        end

        for is in 1:ns
            state_resampled[is,ip] = state[is,k]
        end
        
    end
    
end

function get_axes(params::tdac_params)

    return get_axes(params.nx, params.ny, params.dx, params.dy)
    
end

function get_axes(nx::Int, ny::Int, dx::Real, dy::Real)

    x = range(0, length=nx, step=dx)
    y = range(0, length=ny, step=dy)

    return x,y
end

function init_gaussian_random_field_generator(params::tdac_params)

    x, y = get_axes(params)
    return init_gaussian_random_field_generator(params.lambda,params.nu, params.sigma, x, y, params.padding)
    
end

# Initialize a gaussian random field generating function using the Matern covariance kernel
# and circulant embedding generation method
# TODO: Could generalise this
function init_gaussian_random_field_generator(lambda::T,
                                              nu::T,
                                              sigma::T,
                                              x::AbstractVector{T},
                                              y::AbstractVector{T},
                                              pad::Int) where T
                                               
    # Let's limit ourselves to two-dimensional fields
    dim = 2
    
    cov = CovarianceFunction(dim, Matern(lambda, nu, σ = sigma))
    grf = GaussianRandomField(cov, CirculantEmbedding(), x, y, minpadding=pad)
    
end

# Get a random sample from gaussian random field grf using random number generator rng
function sample_gaussian_random_field!(field::AbstractVector{T},
                                       grf::GaussianRandomFields.GaussianRandomField,
                                       rng::Random.AbstractRNG) where T

    field .= @view(GaussianRandomFields.sample(grf, xi=randn(rng, randdim(grf)))[:])
    
end

# Get a random sample from gaussian random field grf using random_numbers
function sample_gaussian_random_field!(field::AbstractVector{T},
                                       grf::GaussianRandomFields.GaussianRandomField,
                                       random_numbers::AbstractVector{T}) where T

    field .= @view(GaussianRandomFields.sample(grf, xi=random_numbers)[:])

end

function add_random_field!(state::AbstractVector{T},
                           grf::GaussianRandomFields.GaussianRandomField,
                           rng::Random.AbstractRNG,
                           params::tdac_params) where T

    add_random_field!(state, grf, rng, params.n_state_var, params.dim_grid)
    
end

# Add a gaussian random field to each variable in the state vector of one particle
function add_random_field!(state::AbstractVector{T},
                           grf::GaussianRandomFields.GaussianRandomField,
                           rng::Random.AbstractRNG,
                           nvar::Int,
                           dim_grid::Int) where T

    random_field = Vector{Float64}(undef, dim_grid)
    
    for ivar in 1:nvar
        
        sample_gaussian_random_field!(random_field, grf, rng)
        @view(state[(nvar-1)*dim_grid+1:nvar*dim_grid]) .+= random_field

    end

end

function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, params::tdac_params) where T

    add_noise!(vec, rng, params.obs_noise_amplitude)
    
end

# Add a (0,1) normal distributed random number, scaled by amplitude, to each element of vec
function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, amplitude::T) where T

    @. vec += amplitude * randn((rng,), T)
    
end

function init_tdac(params::tdac_params)

    return init_tdac(params.dim_state, params.nobs, params.nprt)
    
end

function init_tdac(dim_state::Int, nobs::Int, nprt::Int)

    # Do memory allocations
    
    # Model vector for data assimilation
    #   state*(        1:  Nx*Ny): tsunami height eta(nx,ny)
    #   state*(  Nx*Ny+1:2*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    #   state*(2*Nx*Ny+1:3*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    state = zeros(Float64, dim_state, nprt) # model state vectors for particles
    
    state_true = zeros(Float64, dim_state) # model vector: true wavefield (observation)   
    state_avg = zeros(Float64, dim_state) # average of particle state vectors

    state_resampled = Matrix{Float64}(undef, dim_state, nprt) 
    
    weights = Vector{Float64}(undef, nprt)
    
    obs_real = Vector{Float64}(undef, nobs)        # observed tsunami height
    obs_model = Matrix{Float64}(undef, nobs, nprt) # forecasted tsunami height

    # station location in digital grids
    ist = Vector{Int}(undef, nobs)
    jst = Vector{Int}(undef, nobs)

    return state, state_true, state_avg, state_resampled, weights, obs_real, obs_model, ist, jst
end

function print_output(state_true::AbstractVector{T}, state_avg::AbstractVector{T}, it::Int, params) where T

    # save tsunami wavefield snapshot for visualization
    println("Writing output at timestep = ", it)
    
    LLW2d.output_snap(reshape(@view(state_true[1:params.dim_grid]),params.nx,params.ny),
                      floor(Int, (it - 1) / params.ntdec),
                      params.title_syn, params.dx, params.dy)
    LLW2d.output_snap(reshape(@view(state_avg[1:params.dim_grid]),params.nx,params.ny),
                      floor(Int, (it - 1) / params.ntdec),
                      params.title_da, params.dx, params.dy)
end

function tdac(params::tdac_params)
    
    state, state_true, state_avg, state_resampled, weights, obs_real, obs_model, ist, jst = init_tdac(params.dim_state,
                                                                                                      params.nobs,
                                                                                                      params.nprt)

    state, state_true, state_avg, state_resampled, weights, obs_real, obs_model, ist, jst = init_tdac(params)
    
    background_grf = init_gaussian_random_field_generator(params)

    rng = Random.MersenneTwister(params.random_seed)
    
    # Set up tsunami model
    gg, hh, hm, hn, fm, fn, fe = LLW2d.setup(params.nx, params.ny, params.bathymetry_setup)

    # obtain initial tsunami height
    eta = reshape(@view(state_true[1:params.dim_grid]), params.nx, params.ny)
    LLW2d.initheight!(eta, hh, params.dx, params.dy, params.source_size)

    # Initialize all particles to the true initial state
    state .= state_true
    
    # set station positions
    LLW2d.set_stations!(ist,
                        jst,
                        params.station_separation,
                        params.station_boundary,
                        params.station_dx,
                        params.station_dy,
                        params.dx,
                        params.dy)

    cov_obs = get_obs_covariance(ist, jst, params)
    
    for it in 1:params.ntmax

        if params.verbose && mod(it - 1, params.ntdec) == 0
            print_output(state_true, state_avg, it, params)
        end

        # integrate true synthetic wavefield and generate observed data
        tsunami_update!(state_true, hm, hn, fn, fm, fe, gg, params)
        get_obs!(obs_real, state_true, ist, jst, params)
        
        # Forecast: Update tsunami forecast and get observations from it
        # Parallelised with threads. TODO: Consider distributed and/or simd
        Threads.@threads for ip in 1:params.nprt
            
            tsunami_update!(@view(state[:,ip]), hm, hn, fn, fm, fe, gg, params)
            add_random_field!(@view(state[:,ip]), background_grf, rng, params)
            get_obs!(@view(obs_model[:,ip]), @view(state[:,ip]), ist, jst, params)
            add_noise!(@view(obs_model[:,ip]), rng, params)
            
        end

        # Weigh and resample particles
        if mod(it - 1, params.da_period) == 0
            
            get_weights!(weights, obs_real, obs_model, cov_obs)            
            resample!(state_resampled, state, weights)
            state .= state_resampled

        end
        
        Statistics.mean!(state_avg, state)
        
    end

    return state_true, state_avg
end

function get_params(path_to_input_file::String)

    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)

    # Read input provided in a yaml file. Overwrite default input parameters with the values provided.
    if isfile(path_to_input_file)
        user_input_dict = YAML.load_file(path_to_input_file)
        user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
        params = tdac_params(;user_input...)
        if my_rank == params.master_rank
            println("Read input parameters from ",path_to_input_file)
        end
    else
        if my_rank == params.master_rank
            if !isempty(path_to_input_file)
                println("Input file ", path_to_input_file, " not found, using default parameters.")
            else
                println("Using default parameters")
            end
        end
        params = tdac_params()
    end
    return params

end

function tdac(path_to_input_file::String = "")

    MPI.Init()

    params = get_params(path_to_input_file)

    return tdac(params)

end

end # module
