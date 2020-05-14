module TDAC

using Random, Distributions, Statistics, Base.Threads, YAML, GaussianRandomFields, MPI, HDF5

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
    grf = GaussianRandomField(cov, CirculantEmbedding(), x, y, minpadding=pad, primes=true)

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

    return init_tdac(params.dim_state, params.nobs, params.nprt, params.master_rank)

end

function init_tdac(dim_state::Int, nobs::Int, nprt_total::Int, master_rank::Int = 0)

    # Do memory allocations

    # For now, assume that the particles can be evenly divided between ranks
    @assert mod(nprt_total, MPI.Comm_size(MPI.COMM_WORLD)) == 0
    nprt_per_rank = Int(nprt_total / MPI.Comm_size(MPI.COMM_WORLD))

    # station location in digital grids
    ist = Vector{Int}(undef, nobs)
    jst = Vector{Int}(undef, nobs)
    
    if MPI.Comm_rank(MPI.COMM_WORLD) == master_rank
        state = zeros(Float64, dim_state, nprt_total) # model state vectors for particles
        obs_model = Matrix{Float64}(undef, nobs, nprt_total) # forecasted tsunami height

        state_true = zeros(Float64, dim_state) # model vector: true wavefield (observation)   
        state_avg = zeros(Float64, dim_state) # average of particle state vectors
        state_resampled = Matrix{Float64}(undef, dim_state, nprt_total) # resampled state vectors
        weights = Vector{Float64}(undef, nprt_total) # particle weights
        obs_true = Vector{Float64}(undef, nobs) # observed tsunami height
    else
        state = zeros(Float64, dim_state, nprt_per_rank) # model state vectors for particles
        obs_model = Matrix{Float64}(undef, nobs, nprt_per_rank) # forecasted tsunami height
        state_true = Vector{Float64}(undef, dim_state)
        state_avg = nothing
        state_resampled = nothing
        weights = nothing
        obs_true = nothing
    end
        
    return state, state_true, state_avg, state_resampled, weights, obs_true, obs_model, ist, jst
end

function write_params(params)

    file = h5open(params.output_filename, "cw")
        
    if !exists(file, params.title_params)
        
        group = g_create(file, params.title_params)
        
        fields = fieldnames(typeof(params));
        
        for field in fields
            
            attrs(group)[string(field)] = getfield(params, field)
            
        end
        
    else
        
        @warn "Write failed, group " * params.title_params * " already exists in " * file.filename * "!"
        
    end

    close(file)
    
end

function write_grid(params)

    h5open(params.output_filename, "cw") do file

        if !exists(file, params.title_grid)
        
            # Write grid axes
            x,y = get_axes(params)
            group = g_create(file, params.title_grid)
            #TODO: use d_write instead of d_create when they fix it in the HDF5 package
            ds_x,dtype_x = d_create(group, "x", collect(x))
            ds_y,dtype_x = d_create(group, "y", collect(x))
            ds_x[1:params.nx] = collect(x)
            ds_y[1:params.ny] = collect(y)
            attrs(ds_x)["Unit"] = "m"
            attrs(ds_y)["Unit"] = "m"

        else

            @warn "Write failed, group " * params.title_grid * " already exists in " * file.filename * "!"
            
        end

    end

end

function write_snapshot(state_true::AbstractVector{T}, state_avg::AbstractVector{T}, it::Int, params::tdac_params) where T

    if params.verbose
        println("Writing output at timestep = ", it)
    end

    h5open(params.output_filename, "cw") do file

        write_surface_height(file, state_true, it, params.title_syn, params)
        write_surface_height(file, state_avg, it, params.title_da, params)

    end

end

function write_surface_height(file::HDF5File, state::AbstractVector{T}, it::Int, title::String, params::tdac_params) where T

    group_name = params.state_prefix * "_" * title
    subgroup_name = "t" * string(floor(Int, (it - 1) / params.ntdec))
    dataset_name = "height"

    if !exists(file, group_name)
        group = g_create(file, group_name)
    else
        group = g_open(file, group_name)
    end

    if !exists(group, subgroup_name)
        subgroup = g_create(group, subgroup_name)
    else
        subgroup = g_open(group, subgroup_name)
    end

    if !exists(subgroup, dataset_name)
        #TODO: use d_write instead of d_create when they fix it in the HDF5 package
        ds,dtype = d_create(subgroup, dataset_name, @view(state[1:params.dim_grid]))
        ds[1:params.dim_grid] = @view(state[1:params.dim_grid])
        attrs(ds)["Description"] = "Ocean surface height"
        attrs(ds)["Unit"] = "m"
        attrs(ds)["Time_step"] = it
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end

end

function tdac(params::tdac_params)

    if !MPI.Initialized()
        MPI.Init()
    end
    
    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    my_size = MPI.Comm_size(MPI.COMM_WORLD)
    
    nprt_per_rank = Int(params.nprt / my_size)
    
    if(params.verbose && my_rank == params.master_rank)
        write_grid(params)
        write_params(params)
    end

    state, state_true, state_avg, state_resampled, weights, obs_true, obs_model, ist, jst = init_tdac(params)

    background_grf = init_gaussian_random_field_generator(params)

    rng = Random.MersenneTwister(params.random_seed + my_rank)
    
    # Set up tsunami model
    gg, hh, hm, hn, fm, fn, fe = LLW2d.setup(params.nx, params.ny, params.bathymetry_setup)

    if my_rank == params.master_rank
        # obtain initial tsunami height
        eta = reshape(@view(state_true[1:params.dim_grid]), params.nx, params.ny)
        LLW2d.initheight!(eta, hh, params.dx, params.dy, params.source_size)
    end

    MPI.Bcast!(state_true, params.master_rank, MPI.COMM_WORLD)

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

        if my_rank == params.master_rank
        
            if params.verbose && mod(it - 1, params.ntdec) == 0
                write_snapshot(state_true, state_avg, it, params)
            end

            # integrate true synthetic wavefield and generate observed data
            tsunami_update!(state_true, hm, hn, fn, fm, fe, gg, params)

        end
        
        # Forecast: Update tsunami forecast and get observations from it
        # Parallelised with threads and MPI.
        Threads.@threads for ip in 1:nprt_per_rank

            tsunami_update!(@view(state[:,ip]), hm, hn, fn, fm, fe, gg, params)

        end
                
        # Weigh and resample particles
        if mod(it - 1, params.da_period) == 0

            # Gather all particles to master rank
            # Doing MPI collectives in place to save memory allocations.
            # This style with if statmeents is recommended instead of MPI.Gather_in_place! which is a bit strange.
            # Note that only master_rank allocates memory for all particles. Other ranks only allocate
            # for their chunk of state.
            if my_rank == params.master_rank
                MPI.Gather!(nothing, @view(state[:]), params.dim_state * nprt_per_rank, params.master_rank, MPI.COMM_WORLD)
                MPI.Gather!(nothing, @view(obs_model[:]), params.nobs * nprt_per_rank, params.master_rank, MPI.COMM_WORLD)
            else
                MPI.Gather!(@view(state[:]), nothing, params.dim_state * nprt_per_rank, params.master_rank, MPI.COMM_WORLD)
                MPI.Gather!(@view(obs_model[:]), nothing, params.nobs * nprt_per_rank, params.master_rank, MPI.COMM_WORLD)
            end
            
            if my_rank == params.master_rank

                get_obs!(obs_true, state_true, ist, jst, params)
                
                for ip in 1:params.nprt
                    add_random_field!(@view(state[:,ip]), background_grf, rng, params)
                    get_obs!(@view(obs_model[:,ip]), @view(state[:,ip]), ist, jst, params)
                    add_noise!(@view(obs_model[:,ip]), rng, params)
                end
                
                get_weights!(weights, obs_true, obs_model, cov_obs)
                resample!(state_resampled, state, weights)
                state .= state_resampled
                
            end

            # Scatter the new particles to all ranks. In place similar to gather above.
            if my_rank == params.master_rank
                MPI.Scatter!(@view(state[:]),
                             nothing,
                             params.dim_state * nprt_per_rank,
                             params.master_rank,
                             MPI.COMM_WORLD)
            else
                MPI.Scatter!(nothing,
                             @view(state[:]),
                             params.dim_state * nprt_per_rank,
                             params.master_rank,
                             MPI.COMM_WORLD)
            end
        end

        if my_rank == params.master_rank
            Statistics.mean!(state_avg, state)
        end

    end

    # At this point we should call `MPI.Finalize()`, but this will be
    # automatically run at the end of the Julia session.  Not having
    # `MPI.Finalize()` here allows us to call `tdac()` multiple times during the
    # same session.

    return state_true, state_avg
end

# Initialise params struct with user-defined dict of values.
function get_params(user_input_dict::Dict)

    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = tdac_params(;user_input...)
    
end

# Initialise params struct with default values
get_params() = tdac_params()

function get_params(path_to_input_file::String)

    # Read input provided in a yaml file. Overwrite default input parameters with the values provided.
    if isfile(path_to_input_file)
        user_input_dict = YAML.load_file(path_to_input_file)
        params = get_params(user_input_dict)
        if params.verbose
            println("Read input parameters from ",path_to_input_file)
        end
    else
        @warn "Input file " * path_to_input_file * " not found, using default parameters"
        params = get_params()
    end
    return params

end

function tdac(path_to_input_file::String = "")

    if !MPI.Initialized()
        MPI.Init()
    end

    # Do I/O on rank 0 only and then broadcast params
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0

        params = get_params(path_to_input_file)

    else

        params = nothing

    end

    params = MPI.bcast(params, 0, MPI.COMM_WORLD)

    return tdac(params)

end

end # module
