module ParticleDA

using Random, Distributions, Statistics, MPI, Base.Threads, YAML, GaussianRandomFields, HDF5
import Future
using TimerOutputs
using DelimitedFiles

export particle_filter

include("params.jl")
include("llw2d.jl")
include("io.jl")

using .Default_params
using .LLW2d

# grid-to-grid distance
get_distance(i0, j0, i1, j1, dx, dy) =
    sqrt((float(i0 - i1) * dx) ^ 2 + (float(j0 - j1) * dy) ^ 2)

function get_obs!(obs::AbstractVector{T},
                  state::AbstractArray{T,3},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int},
                  params::Parameters) where T

    get_obs!(obs,state,params.nx,ist,jst)

end

# Return observation data at stations from given model state
function get_obs!(obs::AbstractVector{T},
                  state::AbstractArray{T,3},
                  nx::Integer,
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int}) where T
    @assert length(obs) == length(ist) == length(jst)

    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        iptr = (jj - 1) * nx + ii
        obs[i] = state[iptr]
    end
end

function tsunami_update!(dx_buffer::AbstractMatrix{T},
                         dy_buffer::AbstractMatrix{T},
                         state::AbstractArray{T,3},
                         model_matrices::LLW2d.Matrices{T},
                         params::Parameters) where T

    tsunami_update!(dx_buffer, dy_buffer, state, params.n_integration_step,
                    params.dx, params.dy, params.time_step, model_matrices)

end

# Update tsunami wavefield with LLW2d in-place.
function tsunami_update!(dx_buffer::AbstractMatrix{T},
                         dy_buffer::AbstractMatrix{T},
                         state::AbstractArray{T,3},
                         nt::Int,
                         dx::Real,
                         dy::Real,
                         time_interval::Real,
                         model_matrices::LLW2d.Matrices{T}) where T

    eta_a = @view(state[:, :, 1])
    mm_a  = @view(state[:, :, 2])
    nn_a  = @view(state[:, :, 3])
    eta_f = @view(state[:, :, 1])
    mm_f  = @view(state[:, :, 2])
    nn_f  = @view(state[:, :, 3])

    dt = time_interval / nt

    for it in 1:nt
        # Parts of model vector are aliased to tsunami heiht and velocities
        LLW2d.timestep!(dx_buffer, dy_buffer, eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, model_matrices, dx, dy, dt)
    end

end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from independent normal pdfs for each observation.
function get_log_weights!(weight::AbstractVector{T},
                          obs::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          obs_noise_std::T) where T

    nobs = size(obs_model,1)
    @assert size(obs,1) == nobs

    weight .= 1.0

    for iobs = 1:nobs
        weight .+= logpdf.(Normal(obs[iobs], obs_noise_std), @view(obs_model[iobs,:]))
    end

end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from a multivariate normal pdf with mean equal to real observations and covariance equal to cov_obs
function get_log_weights!(weight::AbstractVector{T},
                          obs::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          cov_obs::AbstractMatrix{T}) where T

    weight .= Distributions.logpdf(Distributions.MvNormal(obs, cov_obs), obs_model)

end


#
function normalized_exp!(weight::AbstractVector)

    weight .-= maximum(weight)
    @. weight = exp(weight)
    weight ./= sum(weight)

end

# Resample particles from given weights using Stochastic Universal Sampling
function resample!(resampled_indices::AbstractVector{Int}, weight::AbstractVector{T}) where T

    nprt = length(weight)
    nprt_inv = 1.0 / nprt
    k = 1

    #TODO: Do we need to sort state by weight here?

    weight_cdf = cumsum(weight)
    u0 = nprt_inv * Random.rand(T)

    # Note: To parallelise this loop, updates to k and u have to be atomic.
    # TODO: search for better parallel implementations
    for ip in 1:nprt

        u = u0 + (ip - 1) * nprt_inv

        while(u > weight_cdf[k])
            k += 1
        end

        resampled_indices[ip] = k

    end

end

function get_axes(params::Parameters)

    return get_axes(params.nx, params.ny, params.dx, params.dy)

end

function get_axes(nx::Int, ny::Int, dx::Real, dy::Real)

    x = range(0, length=nx, step=dx)
    y = range(0, length=ny, step=dy)

    return x,y
end

function init_gaussian_random_field_generator(params::Parameters)

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
    xi = Array{eltype(grf.cov)}(undef, size(v)..., nthreads())
    w = Array{complex(float(eltype(v)))}(undef, size(v)..., nthreads())
    z = Array{eltype(grf.cov)}(undef, length.(grf.pts)..., nthreads())

    return RandomField(grf, xi, w, z)
end

# Get a random sample from random_field_generator using random number generator rng
function sample_gaussian_random_field!(field::AbstractMatrix{T},
                                       random_field_generator::RandomField,
                                       rng::Random.AbstractRNG) where T

    @. @view(random_field_generator.xi[:,:,threadid()]) = randn((rng,), T)
    sample_gaussian_random_field!(field, random_field_generator, @view(random_field_generator.xi[:,:,threadid()]))

end

# Get a random sample from random_field_generator using random_numbers
function sample_gaussian_random_field!(field::AbstractMatrix{T},
                                       random_field_generator::RandomField,
                                       random_numbers::AbstractArray{T}) where T

    field .= GaussianRandomFields._sample!(@view(random_field_generator.w[:,:,threadid()]),
                                           @view(random_field_generator.z[:,:,threadid()]),
                                           random_field_generator.grf,
                                           random_numbers)

end

function add_random_field!(state::AbstractArray{T,4},
                           field_buffer::AbstractArray{T,4},
                           generator::RandomField,
                           rng::AbstractVector{<:Random.AbstractRNG},
                           params::Parameters) where T

    add_random_field!(state, field_buffer, generator, rng, params.n_state_var, params.nprt)

end

# Add a gaussian random field to the height in the state vector of all particles
function add_random_field!(state::AbstractArray{T,4},
                           field_buffer::AbstractArray{T,4},
                           generator::RandomField,
                           rng::AbstractVector{<:Random.AbstractRNG},
                           nvar::Int,
                           nprt::Int) where T

    Threads.@threads for ip in 1:nprt

        for ivar in 1:nvar

            sample_gaussian_random_field!(@view(field_buffer[:, :, 1, threadid()]), generator, rng[threadid()])
            # Add the random field only to the height component.
            @view(state[:, :, ivar, ip]) .+= @view(field_buffer[:, :, 1, threadid()])

        end

    end

end

function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, params::Parameters) where T

    add_noise!(vec, rng, 0.0, params.obs_noise_std)

end

# Add a (mean, std) normal distributed random number to each element of vec
function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, mean::T, std::T) where T

    d = truncated(Normal(mean, std), 0.0, Inf)
    @. vec += rand((rng,), d)

end

struct SummaryStat{T}
    avg::T
    var::T
    n::Int
end

function SummaryStat(X::AbstractVector)
    m = mean(X)
    v = varm(X,m, corrected=true)
    n = length(X)
    SummaryStat(m,v,n)
end

function init_arrays(params::Parameters)

    return init_arrays(params.nx, params.ny, params.n_state_var, params.nobs, params.nprt, params.master_rank)

end

function init_arrays(nx::Int, ny::Int, n_state_var::Int, nobs::Int, nprt_total::Int, master_rank::Int = 0)
    state_avg = zeros(T, nx, ny, n_state_var) # average of particle state vectors
    state_var = zeros(T, nx, ny, n_state_var) # variance of particle state vectors
    state_resampled = Array{T,4}(undef, nx, ny, n_state_var, nprt_per_rank)

    # Model vector for data assimilation
    #   state[:, :, 1, :]: tsunami height eta(nx,ny)
    #   state[:, :, 2, :]: vertically integrated velocity Mx(nx,ny)
    #   state[:, :, 3, :]: vertically integrated velocity Mx(nx,ny)
    state_particles = zeros(T, nx, ny, n_state_var, nprt_per_rank)
    state_truth = zeros(T, nx, ny, n_state_var) # model vector: true wavefield (observation)
    obs_truth = Vector{T}(undef, nobs)          # observed tsunami height
    obs_model = Matrix{T}(undef, nobs, nprt_per_rank) # forecasted tsunami height

    # station location in digital grids
    ist = Vector{Int}(undef, nobs)
    jst = Vector{Int}(undef, nobs)

    # Buffer array to be used in the tsunami update
    field_buffer = Array{T}(undef, nx, ny, 2, nthreads())

    return StateVectors(state_particles, state_resampled, state_truth), ObsVectors(obs_truth, obs_model), StationVectors(ist, jst), field_buffer
end

function set_initial_state!(states::StateVectors, model_matrices::LLW2d.Matrices{T},
                            field_buffer::AbstractArray{T, 4},
                            rng::AbstractVector{<:Random.AbstractRNG},
                            nprt_per_rank::Int,
                            params::Parameters) where T

    # Set true initial state
    LLW2d.initheight!(@view(states.truth[:, :, 1]), model_matrices, params.dx, params.dy, params.source_size)

    # Create generator for the initial random field
    x,y = get_axes(params)
    initial_grf = init_gaussian_random_field_generator(params.lambda_initial_state,
                                                       params.nu_initial_state,
                                                       params.sigma_initial_state,
                                                       x,
                                                       y,
                                                       params.padding,
                                                       params.primes)

    # Since states.particles is initially created as `zeros` we don't need to set it to 0 here
    # to get the default behaviour

    if params.particle_initial_state == "true"
        states.particles .= states.truth
    end

    # Add samples of the initial random field to all particles
    add_random_field!(states.particles, field_buffer, initial_grf, rng, params.n_state_var, nprt_per_rank)

end

function set_stations!(stations::StationVectors, params::Parameters) where T

    set_stations!(stations.ist,
                  stations.jst,
                  params.station_filename,
                  params.station_distance_x,
                  params.station_distance_y,
                  params.station_boundary_x,
                  params.station_boundary_y,
                  params.dx,
                  params.dy)

end

function set_stations!(ist::AbstractVector, jst::AbstractVector, filename::String, distance_x::T, distance_y::T, boundary_x::T, boundary_y::T, dx::T, dy::T) where T

    if filename != ""
        coords = readdlm(filename, ',', Float64, '\n'; comments=true, comment_char='#')
        ist .= floor.(Int, coords[:,1] / dx)
        jst .= floor.(Int, coords[:,2] / dy)
    else
        LLW2d.set_stations!(ist,jst,distance_x,distance_y,boundary_x,boundary_y,dx,dy)
    end

end

function stats_reduction(S1::SummaryStat, S2::SummaryStat)

    n = S1.n + S2.n
    m = (S1.avg*S1.n + S2.avg*S2.n) / n

    # Calculate pooled unbiased sample variance of two groups. From https://stats.stackexchange.com/q/384951
    # Can be found in https://www.tandfonline.com/doi/abs/10.1080/00031305.2014.966589
    # To get the uncorrected variance, use
    # v = (S1.n * (S1.var + S1.avg * (S1.avg-m)) + S2.n * (S2.var + S2.avg * (S2.avg-m)))/n
    v = ((S1.n-1) * S1.var + (S2.n-1) * S2.var + S1.n*S2.n/n * (S2.avg - S1.avg)^2 )/(n-1)

    SummaryStat(m, v, n)

end

function get_mean_and_var!(statistics::Array{SummaryStat{T},3},
                           particles::AbstractArray{T,4},
                           master_rank::Int) where T

    Threads.@threads for idx in CartesianIndices(statistics)
        statistics[idx] = SummaryStat(@view(particles[idx,:]))
    end

    MPI.Reduce!(statistics, stats_reduction, master_rank, MPI.COMM_WORLD)

end

function unpack_statistics!(avg::AbstractArray{T}, var::AbstractArray{T}, statistics::AbstractArray{SummaryStat{T}}) where T

    for idx in CartesianIndices(statistics)
        avg[idx] = statistics[idx].avg
        var[idx] = statistics[idx].var
    end
end

function copy_states!(states::StateVectors, resampling_indices::Vector{Int}, my_rank::Int, nprt_per_rank::Int)

    copy_states!(states.particles, states.buffer, resampling_indices, my_rank, nprt_per_rank)

end

function copy_states!(particles::AbstractArray{T,4},
                      buffer::AbstractArray{T,4},
                      resampling_indices::Vector{Int},
                      my_rank::Int,
                      nprt_per_rank::Int) where T

    # These are the particle indices stored on this rank
    particles_have = my_rank * nprt_per_rank + 1:(my_rank + 1) * nprt_per_rank

    # These are the particle indices this rank should have after resampling
    particles_want = resampling_indices[particles_have]

    # These are the ranks that have the particles this rank should have
    rank_has = floor.(Int, (particles_want .- 1) / nprt_per_rank)

    # We could work out how many sends and receives we have to do and allocate
    # this appropriately but, lazy
    reqs = Vector{MPI.Request}(undef, 0)

    # Send particles to processes that want them
    for (k,id) in enumerate(resampling_indices)
        rank_wants = floor(Int, (k - 1) / nprt_per_rank)
        if id in particles_have && rank_wants != my_rank
            local_id = id - my_rank * nprt_per_rank
            req = MPI.Isend(@view(particles[:,:,:,local_id]), rank_wants, id, MPI.COMM_WORLD)
            push!(reqs, req)
        end
    end

    # Receive particles this rank wants from ranks that have them
    # If I already have them, just do a local copy
    # Receive into a buffer so we dont accidentally overwrite stuff
    for (k,proc,id) in zip(1:nprt_per_rank, rank_has, particles_want)
        if proc == my_rank
            local_id = id - my_rank * nprt_per_rank
            @view(buffer[:,:,:,k]) .= @view(particles[:,:,:,local_id])
        else
            req = MPI.Irecv!(@view(buffer[:,:,:,k]), proc, id, MPI.COMM_WORLD)
            push!(reqs,req)
        end
    end

    # Wait for all comms to complete
    MPI.Waitall!(reqs)

    particles .= buffer

end

### These functions and data strcutures will go into the model
struct RandomField{F<:GaussianRandomField,X<:AbstractArray,W<:AbstractArray,Z<:AbstractArray}
    grf::F
    xi::X
    w::W
    z::Z
end

struct StateVectors{T<:AbstractArray, S<:AbstractArray}

    particles::T
    buffer::T
    truth::S

end

struct ObsVectors{T<:AbstractArray,S<:AbstractArray}

    truth::T
    model::S

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T

end

struct ModelData
    states
    statistics
    observations
    stations
    field_buffer
    background_grf
    model_matrices
end
get_particles(d::ModelData) = d.states.particles
get_truth_observations(d::ModelData) = d.observations.truth
get_model_observations(d::ModelData) = d.observations.model
function write_initial_state(d::ModelData, weights, params)
    write_grid(params)
    write_params(params)
    write_stations(d.stations.ist, d.stations.jst, params)
    unpack_statistics!(d.avg_arr, d.var_arr, d.statistics)
    write_snapshot(d.states.truth, d.avg_arr, d.var_arr, weights, 0, params)
end

function init(params::Parameters, rng::AbstractVector{<:Random.AbstractRNG}, nprt_per_rank::Int)
    states, statistics, observations, stations, field_buffer = init_arrays(params)

    background_grf = init_gaussian_random_field_generator(params)

    # Set up tsunami model
    model_matrices = LLW2d.setup(params.nx,
                                 params.ny,
                                 params.bathymetry_setup,
                                 params.absorber_thickness_fraction,
                                 params.boundary_damping,
                                 params.cutoff_depth)

    set_stations!(stations, params)

    set_initial_state!(states, model_matrices, field_buffer, rng, nprt_per_rank, params)

    return ModelData(states, observations, stations, field_buffer, background_grf, model_matrices)
end

function update_truth!(d::ModelData params)
    tsunami_update!(@view(d.field_buffer[:, :, 1, 1]),
                    @view(d.field_buffer[:, :, 2, 1]),
                    d.states.truth, d.model_matrices, params)
end

function update_particles!(d::ModelData, nprt_per_rank, params)
    Threads.@threads for ip in 1:nprt_per_rank
        tsunami_update!(@view(d.field_buffer[:, :, 1, threadid()]), @view(d.field_buffer[:, :, 2, threadid()]),
                        @view(d.states.particles[:, :, :, ip]), d.model_matrices, params)

    end
    add_random_field!(d.states.particles,
                      d.field_buffer,
                      d.background_grf,
                      d.rng,
                      params.n_state_var,
                      nprt_per_rank)

end

function truth_observations!(d::ModelData, params)
    get_obs!(d.observations.truth, d.states.truth, d.stations.ist, d.stations.jst, params)
    return d.observations.truth
end

function particles_observations!(d::ModelData, nprt_per_rank, params)
    for ip in 1:nprt_per_rank
        get_obs!(@view(observations.model[:,ip]),
                 @view(states.particles[:, :, :, ip]),
                 stations.ist,
                 stations.jst,
                 params)
    add_noise!(@view(d.observations.model[:,ip]), d.rng[1], params)
    end
    return d.observations.model
end

### End of model functions

function particle_filter(params::Parameters, rng::AbstractVector{<:Random.AbstractRNG}, init)

    if !MPI.Initialized()
        MPI.Init()
    end

    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    my_size = MPI.Comm_size(MPI.COMM_WORLD)

    # For now, assume that the particles can be evenly divided between ranks
    @assert mod(params.nprt, my_size) == 0

    nprt_per_rank = Int(params.nprt / my_size)

    if params.enable_timers
        TimerOutputs.enable_debug_timings(ParticleDA)
    end
    timer = TimerOutput()

    # TODO: ideally this will be an argument of the function, to choose a
    # different datatype.
    T = Float64

    nprt_per_rank = Int(nprt_total / MPI.Comm_size(MPI.COMM_WORLD))

    # Do memory allocations

    if MPI.Comm_rank(MPI.COMM_WORLD) == master_rank
        weights = Vector{T}(undef, nprt_total)
    else
        weights = Vector{T}(undef, nprt_per_rank)
    end

    resampling_indices = Vector{Int}(undef, params.nprt)

    mean_and_var = Array{SummaryStat{T}, 3}(undef, nx, ny, n_state_var)
    avg_arr = Array{T,3}(undef, nx, ny, n_state_var)
    var_arr = Array{T,3}(undef, nx, ny, n_state_var)

    @timeit_debug timer "Initialization" model_data = init(params, rng, nprt_per_rank)

    @timeit_debug timer "Mean and Var" get_mean_and_var!(statistics, get_particles(model_data), params.master_rank)

    # Write initial state + metadata
    if(params.verbose && my_rank == params.master_rank)
        @timeit_debug timer "IO" write_initial_state(model_data, params)
    end

    for it in 1:params.n_time_step

        # integrate true synthetic wavefield
        @timeit_debug timer "True State Update" update_truth!(model_data, params)

        # Get observation from true synthetic wavefield
        @timeit_debug timer "Observations" truth_observations = truth_observations!(model_data, params)

        # Forecast: Update tsunami forecast and get observations from it
        # Parallelised with threads.

        @timeit_debug timer "Particle State Update and Process Noise" update_particles!(model_data, nprt_per_rank, params)

        # Add process noise, get observations, add observation noise (to particles)
        @timeit_debug timer "Observations" model_observations = particles_observations!(model_data, nprt_per_rank, params)

        @timeit_debug timer "Weights" get_log_weights!(@view(weights[1:nprt_per_rank]),
                                                       truth_observations,
                                                       model_observations,
                                                       params.obs_noise_std)

        # Gather weights to master rank and resample particles.
        # Doing MPI collectives in place to save memory allocations.
        # This style with if statmeents is recommended instead of MPI.Gather_in_place! which is a bit strange.
        # Note that only master_rank allocates memory for all particles. Other ranks only allocate
        # for their chunk of state.
        if my_rank == params.master_rank
            @timeit_debug timer "MPI Gather" MPI.Gather!(nothing,
                                                         weights,
                                                         nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
            @timeit_debug timer "Weights" normalized_exp!(weights)
            @timeit_debug timer "Resample" resample!(resampling_indices, weights)

        else
            @timeit_debug timer "MPI Gather" MPI.Gather!(weights,
                                                         nothing,
                                                         nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
        end

        # Broadcast resampled particle indices to all ranks
        MPI.Bcast!(resampling_indices, params.master_rank, MPI.COMM_WORLD)

        @timeit_debug timer "State Copy" copy_states!(states, resampling_indices, my_rank, nprt_per_rank)

        @timeit_debug timer "Mean and Var" get_mean_and_var!(statistics, states.particles, params.master_rank)

        if my_rank == params.master_rank && params.verbose

            @timeit_debug timer "IO" begin
                unpack_statistics!(avg_arr, var_arr, statistics)
                write_snapshot(states.truth, avg_arr, var_arr, weights, it, params)
            end

        end

    end

    if params.enable_timers

        if my_rank == params.master_rank
            print_timer(timer)
        end

        if params.verbose
            # Gather string representations of timers from all ranks and write them on master
            str_timer = string(timer)

            # Assume the length of the timer string on master is the longest (because master does more stuff)
            if my_rank == params.master_rank
                length_timer = length(string(timer))
            else
                length_timer = nothing
            end

            length_timer = MPI.bcast(length_timer, params.master_rank, MPI.COMM_WORLD)

            chr_timer = Vector{Char}(rpad(str_timer,length_timer))

            timer_chars = MPI.Gather(chr_timer, params.master_rank, MPI.COMM_WORLD)

            if my_rank == params.master_rank
                write_timers(length_timer, my_size, timer_chars, params)
            end
        end
    end

    unpack_statistics!(avg_arr, var_arr, statistics)

    return states.truth, avg_arr, var_arr
end

# Initialise params struct with user-defined dict of values.
function get_params(user_input_dict::Dict)

    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = Parameters(;user_input...)

end

# Initialise params struct with default values
get_params() = Parameters()

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

function particle_filter(path_to_input_file::String, rng::AbstractRNG)

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

    rng_vec = let m = rng
        [m; accumulate(Future.randjump, fill(big(10)^20, nthreads()-1), init=m)]
    end;

    return particle_filter(params, rng_vec, init)

end

function particle_filter(path_to_input_file::String = "")

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

    return particle_filter(params)

end

function particle_filter(params::Parameters)

    if !MPI.Initialized()
        MPI.Init()
    end

    rng = let m = Random.MersenneTwister(params.random_seed + MPI.Comm_rank(MPI.COMM_WORLD))
        [m; accumulate(Future.randjump, fill(big(10)^20, nthreads()-1), init=m)]
    end;

    return particle_filter(params, rng, init)

end

end # module
