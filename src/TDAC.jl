module TDAC

using Random, Distributions, Statistics, MPI, Base.Threads, YAML, GaussianRandomFields, HDF5
using TimerOutputs

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

    tsunami_update!(state, params.nx, params.ny, params.dim_grid, params.n_integration_step,
                    params.dx, params.dy, params.time_step, hm, hn, fm, fn, fe, gg)

end

# Update tsunami wavefield with LLW2d in-place.
function tsunami_update!(state::AbstractVector{T},
                         nx::Int,
                         ny::Int,
                         nn::Int,
                         nt::Int,
                         dx::Real,
                         dy::Real,
                         time_interval::Real,
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

    dt = time_interval / nt
    
    for it in 1:nt
        # Parts of model vector are aliased to tsunami heiht and velocities
        LLW2d.timestep!(eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, hm, hn, fn, fm, fe, gg, dx, dy, dt)
    end

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

struct RandomField{F<:GaussianRandomField,W<:AbstractArray,Z<:AbstractArray}
    grf::F
    w::W
    z::Z
end

function init_gaussian_random_field_generator(params::tdac_params)

    x, y = get_axes(params)
    return init_gaussian_random_field_generator(params.lambda,params.nu, params.sigma, x, y, params.padding, params.primes)

end

# Initialize a gaussian random field generating function using the Matern covariance kernel
# and circulant embedding generation method
# TODO: Could generalise this
function init_gaussian_random_field_generator(lambda::T,
                                              nu::T,
                                              sigma::T,
                                              x::AbstractVector{T},
                                              y::AbstractVector{T},
                                              pad::Int,
                                              primes::Bool) where T

    # Let's limit ourselves to two-dimensional fields
    dim = 2

    cov = CovarianceFunction(dim, Matern(lambda, nu, σ = sigma))
    grf = GaussianRandomField(cov, CirculantEmbedding(), x, y, minpadding=pad, primes=primes)
    v = grf.data[1]
    w = Array{complex(float(eltype(v)))}(undef, size(v))
    z = Array{eltype(grf.cov)}(undef, length.(grf.pts))

    return RandomField(grf, w, z)
end

# Get a random sample from gaussian random field grf using random number generator rng
function sample_gaussian_random_field!(field::AbstractVector{T},
                                       grf::RandomField,
                                       rng::Random.AbstractRNG) where T

    field .= @view(GaussianRandomFields._sample!(grf.w, grf.z, grf.grf, randn(rng, size(grf.grf.data[1])))[:])

end

# Get a random sample from gaussian random field grf using random_numbers
function sample_gaussian_random_field!(field::AbstractVector{T},
                                       grf::RandomField,
                                       random_numbers::AbstractArray{T}) where T

    field .= @view(GaussianRandomFields._sample!(grf.w, grf.z, grf.grf, random_numbers)[:])

end

function add_random_field!(state::AbstractVector{T},
                           grf::RandomField,
                           rng::Random.AbstractRNG,
                           params::tdac_params) where T

    add_random_field!(state, grf, rng, params.n_state_var, params.dim_grid)

end

# Add a gaussian random field to each variable in the state vector of one particle
function add_random_field!(state::AbstractVector{T},
                           grf::RandomField,
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

struct StateVectors{T<:AbstractArray, S<:AbstractArray}

    particles::T
    truth::S
    avg::S
    var::S
    resampled::T
    
end

struct ObsVectors{T<:AbstractArray,S<:AbstractArray}

    truth::T
    model::S

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T
    
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
        state_particles = zeros(Float64, dim_state, nprt_total) # model state vectors for particles
        obs_model = Matrix{Float64}(undef, nobs, nprt_total) # forecasted tsunami height

        state_truth = zeros(Float64, dim_state) # model vector: true wavefield (observation)   
        state_avg = zeros(Float64, dim_state) # average of particle state vectors
        state_var = zeros(Float64, dim_state) # average of particle state vectors
        state_resampled = Matrix{Float64}(undef, dim_state, nprt_total) # resampled state vectors
        weights = Vector{Float64}(undef, nprt_total) # particle weights
        obs_truth = Vector{Float64}(undef, nobs) # observed tsunami height
    else
        state_particles = zeros(Float64, dim_state, nprt_per_rank) # model state vectors for particles
        obs_model = Matrix{Float64}(undef, nobs, nprt_per_rank) # forecasted tsunami height
        state_truth = Vector{Float64}(undef, dim_state)

        # The below arrays are not needed on non-master ranks. However, to fit them in the
        # data structures, we define them as 0-size Vectors
        state_avg = Vector{Float64}(undef, 0)
        state_var = Vector{Float64}(undef, 0)
        state_resampled = Vector{Float64}(undef, 0)
        obs_truth = Vector{Float64}(undef, 0)
        weights = Vector{Float64}(undef, 0)
    end
    
    return StateVectors(state_particles, state_truth, state_avg, state_var, state_resampled), ObsVectors(obs_truth, obs_model), StationVectors(ist, jst), weights
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

function write_snapshot(states::StateVectors, it::Int, params::tdac_params) where T

    if params.verbose
        println("Writing output at timestep = ", it)
    end

    h5open(params.output_filename, "cw") do file

        write_surface_height(file, states.truth, it, params.title_syn, params)
        write_surface_height(file, states.avg, it, params.title_avg, params)
        write_surface_height(file, states.var, it, params.title_var, params)

    end

end

function write_surface_height(file::HDF5File, state::AbstractVector{T}, it::Int, title::String, params::tdac_params) where T

    group_name = params.state_prefix * "_" * title
    subgroup_name = "t" * string(it)
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
        attrs(ds)["Time (s)"] = it * params.time_step
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

    if params.enable_timers
        TimerOutputs.enable_debug_timings(TDAC)
    end    
    timer = TimerOutput()

    @timeit_debug timer "Initialization" begin
    
        states, observations, stations, weights = init_tdac(params)
        
        background_grf = init_gaussian_random_field_generator(params)

        rng = Random.MersenneTwister(params.random_seed)
        
        #TODO: Put all llw2d setup in one function
        # Set up tsunami model
        #TODO: Put these in a data structure
        gg, hh, hm, hn, fm, fn, fe = LLW2d.setup(params.nx, params.ny, params.bathymetry_setup)
        
        # Obtain initial tsunami height.
        # I think it is more efficient to have all ranks call `initheight` than do it on master
        # and then broadcast, since we need it for all ranks to initialize particles.
        eta = reshape(@view(states.truth[1:params.dim_grid]), params.nx, params.ny)
        LLW2d.initheight!(eta, hh, params.dx, params.dy, params.source_size)
        
        # set station positions
        LLW2d.set_stations!(stations.ist,
                            stations.jst,
                            params.station_separation,
                            params.station_boundary,
                            params.station_dx,
                            params.station_dy,
                            params.dx,
                            params.dy)
    
        # Initialize all particles to the true initial state + noise
        states.particles .= states.truth
        for ip in 1:params.nprt
            add_random_field!(@view(states.particles[:,ip]), background_grf, rng, params)
        end

        cov_obs = get_obs_covariance(stations.ist, stations.jst, params)
        
    end
        
    # Write initial state + metadata
    if(params.verbose && my_rank == params.master_rank)
        @timeit_debug timer "IO" write_grid(params)
        @timeit_debug timer "IO" write_params(params)
        @timeit_debug timer "IO" write_snapshot(states, 0, params)
    end   

    for it in 1:params.n_time_step

        if my_rank == params.master_rank
            
            # integrate true synthetic wavefield
            @timeit_debug timer "True State Update" tsunami_update!(states.truth, hm, hn, fn, fm, fe, gg, params)

            # Get observation from true synthetic wavefield
            @timeit_debug timer "True Observations" get_obs!(observations.truth, states.truth, stations.ist, stations.jst, params)
            
        end

        # This loop has been split for diagnostic purposes. Fusing it may boost performance.
        @timeit_debug timer "Particle Model" Threads.@threads for ip in 1:nprt_per_rank
            
            # Forecast: Update tsunami forecast
            tsunami_update!(@view(states.particles[:,ip]), hm, hn, fn, fm, fe, gg, params)

        end

        @timeit_debug timer "Particle Noise" Threads.@threads for ip in 1:nprt_per_rank
            
            # Add process noise
            add_random_field!(@view(states.particles[:,ip]), background_grf, rng, params)

        end

        @timeit_debug timer "Particle Observations" Threads.@threads for ip in 1:nprt_per_rank

            # get observations, add observation noise
            get_obs!(@view(observations.model[:,ip]),
                     @view(states.particles[:,ip]),
                     stations.ist,
                     stations.jst,
                     params)
            add_noise!(@view(observations.model[:,ip]), rng, params)
        end

        # Gather all particles to master rank
        # Doing MPI collectives in place to save memory allocations.
        # This style with if statmeents is recommended instead of MPI.Gather_in_place! which is a bit strange.
        # Note that only master_rank allocates memory for all particles. Other ranks only allocate
        # for their chunk of state.
        if my_rank == params.master_rank
            @timeit_debug timer "MPI Gather" MPI.Gather!(nothing,
                                                         @view(states.particles[:]),
                                                         params.dim_state * nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
            @timeit_debug timer "MPI Gather" MPI.Gather!(nothing,
                                                         @view(observations.model[:]),
                                                         params.nobs * nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
        else
            @timeit_debug timer "MPI Gather" MPI.Gather!(@view(states.particles[:]),
                                                         nothing,
                                                         params.dim_state * nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
            @timeit_debug timer "MPI Gather" MPI.Gather!(@view(observations.model[:]),
                                                         nothing,
                                                         params.nobs * nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
        end

        if my_rank == params.master_rank
            
            # Weigh and resample particles
            @timeit_debug timer "Weights" get_weights!(weights, observations.truth, observations.model, cov_obs)
            @timeit_debug timer "Resample" resample!(states.resampled, states.particles, weights)
            @timeit_debug timer "State Copy" states.particles .= states.resampled

            # Scatter the new particles to all ranks. In place similar to gather above.
            @timeit_debug timer "MPI Scatter" MPI.Scatter!(@view(states.particles[:]),
                                                           nothing,
                                                           params.dim_state * nprt_per_rank,
                                                           params.master_rank,
                                                           MPI.COMM_WORLD)
            
            # Calculate statistical values
            @timeit_debug timer "Particle Mean" Statistics.mean!(states.avg, states.particles)
            @timeit_debug timer "Particle Variance" states.var .= @view(Statistics.var(states.particles; dims=2)[:])

            # Write output
            if params.verbose
                @timeit_debug timer "IO" write_snapshot(states, it, params)
            end
            
        else
            @timeit_debug timer "MPI Scatter" MPI.Scatter!(nothing,
                                                           @view(states.particles[:]),
                                                           params.dim_state * nprt_per_rank,
                                                           params.master_rank,
                                                           MPI.COMM_WORLD)
        end        
    end

    if my_rank == params.master_rank && params.enable_timers
        print_timer(timer)
    end
    
    return states.truth, states.avg, states.var
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
