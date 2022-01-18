module ParticleDA

using Random
using Distributions, Statistics, MPI, Base.Threads, YAML, HDF5
using TimerOutputs
import Future
using EllipsisNotation

export run_particle_filter, BootstrapFilter, OptimalFilter

include("params.jl")
include("io.jl")
include("OptimalFilter.jl")

using .Default_params

# Functions to extend in the model

"""
    ParticleDA.get_grid_size(model_data) -> NTuple{N, Int} where N

Return a tuple with the dimensions (number of nodes) of the grid.
"""
function get_grid_size end
"""
    ParticleDA.get_grid_domain_size(model_data) -> NTuple{N, float} where N

Return a tuple with the dimensions (metres) of the grid domain.
"""
function get_grid_domain_size end
"""
    ParticleDA.get_grid_cell_size(model_data) -> NTuple{N, float} where N

Return a tuple with the dimensions (metres) of a grid cell.
"""
function get_grid_cell_size end

"""
    ParticleDA.get_n_state_var(model_data) -> Int

Return the number of state variables.
"""
function get_n_state_var end

"""
    ParticleDa.get_obs_noise_std(model_data) -> Float

Return standard deviation of observation noise. Required for optimal filter only.
"""
function get_obs_noise_std end

"""
    ParticleDa.get_model_noise(model_data) -> NamedTuple({:sigma, :lambda, :nu},Tuple{Float, Float, Float})

Return parameters of the noise covariance function of the first state variable (height). Required for optimal filter only.
"""
function get_model_noise_params end

"""
    ParticleDA.get_particle(model_data) -> particles

Return the vector of particles.  This method is intended to be extended by the
user with the above signature, specifying the type of `model_data`.  Note: this
function should return the vector of particles itself and not a copy, because it
will be modified in-place.
"""
function get_particles end

"""
   ParticleDA.set_particles!(model_data, particles)

Overwrite particle state in model_data with the vector particles. This method is intended to be extended by the
user with the above signature, specifying the type of `model_data`.
"""
function set_particles! end

"""
    ParticleDA.get_truth(model_data) -> truth_observations

Return the vector of true observations.  This method is intended to be extended
by the user with the above signature, specifying the type of `model_data`.
"""
function get_truth end

"""
    ParticleDA.get_stations(model_data) -> NamedTuple({:nst,:ist,:jst},Tuple{Int, Array{Float,1}, Array{Float,1}})

Return a named tuple with number of stations and their coordinates (nst,ist,jst) of the
points of observation. This method is intended to be extended by the user with the above signature,
specifying the type of `model_data`.
Required for optimal filter only.
"""
function get_stations end

"""
    ParticleDA.update_truth!(model_data, nprt_per_rank::Int) -> truth_observations

Update the true observations using the dynamic of the model and return the
vector of the true observations.  `nprt_per_rank` is the number of particles per
each MPI rank.  This method is intended to be extended by the user with the
above signature, specifying the type of `model_data`.
"""
function update_truth! end

"""
    ParticleDA.update_particle_dynamics!(model_data, nprt_per_rank::Int)

Update the particles using the dynamic of the model.  `nprt_per_rank` is the
number of particles per each MPI rank.  This method is intended to be extended
by the user with the above signature, specifying the type of `model_data`.
"""
function update_particle_dynamics! end

"""
    ParticleDA.update_particle_noise!(model_data, nprt_per_rank::Int)

Update the particles using the noise of the model and return the vector of the
particles.  `nprt_per_rank` is the number of particles per each MPI rank.  This
method is intended to be extended by the user with the above signature,
specifying the type of `model_data`.
"""
function update_particle_noise! end

"""
    ParticleDA.get_particle_observations!(model_data, nprt_per_rank::Int) -> particles_observations

Return the vector of the particles observations.  `nprt_per_rank` is the number
of particles per each MPI rank.  This method is intended to be extended by the
user with the above signature, specifying the type of `model_data`.
"""
function get_particle_observations! end

"""
    ParticleDA.write_snapshot(output_filename, model_data, avg_arr, var_arr, weights, it)

Write a snapshot of the data after an update of the particles to the HDF5 file
`output_filename`.  `avg_arr` is the array of the mean of the particles,
`var_arr` is the array of the standard deviation of the particles, `weights` is
the array of the weigths of the particles, `it` is the index of the time step
(`it==0` is the initial state, before moving forward the model for the first
time).  This method is intended to be extended by the user with the above
signature, specifying the type of `model_data`.
"""
function write_snapshot end

"""
    ParticleFilter

Abstract type for the particle filter to use.  Currently used subtypes are:
* [`BootstrapFilter`](@ref)
* [`OptimalFilter`](@ref)
"""
abstract type ParticleFilter end
"""
    BootstrapFilter()

Instantiate the singleton type `BootstrapFilter`.  This can be used as argument
of [`run_particle_filter`](@ref) to select the bootstrap filter.
"""
struct BootstrapFilter <: ParticleFilter end
struct OptimalFilter <: ParticleFilter end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from independent normal pdfs for each observation.
function get_log_weights!(weight::AbstractVector{T},
                          obs::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          weight_std::T) where T

    nobs = size(obs_model,1)
    @assert size(obs,1) == nobs

    weight .= 1.0

    for iobs = 1:nobs
        weight .+= logpdf.(Normal(obs[iobs], weight_std), @view(obs_model[iobs,:]))
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
function resample!(resampled_indices::AbstractVector{Int}, weight::AbstractVector{T}, rng::Random.AbstractRNG=Random.default_rng()) where T

    nprt = length(weight)
    nprt_inv = 1.0 / nprt
    k = 1

    #TODO: Do we need to sort state by weight here?

    weight_cdf = cumsum(weight)
    u0 = nprt_inv * rand(rng, T)

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

function get_mean_and_var!(statistics::Array{SummaryStat{T}},
                           particles::AbstractArray{T},
                           master_rank::Int) where T

    ndims(particles) != ndims(statistics) + 1 &&
        error("particles must have one dimension more than statistics")
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

function copy_states!(particles::AbstractArray{T},
                      buffer::AbstractArray{T},
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
            req = MPI.Isend(@view(particles[..,local_id]), rank_wants, id, MPI.COMM_WORLD)
            push!(reqs, req)
        end
    end

    # Receive particles this rank wants from ranks that have them
    # If I already have them, just do a local copy
    # Receive into a buffer so we dont accidentally overwrite stuff
    for (k,proc,id) in zip(1:nprt_per_rank, rank_has, particles_want)
        if proc == my_rank
            local_id = id - my_rank * nprt_per_rank
            @view(buffer[..,k]) .= @view(particles[..,local_id])
        else
            req = MPI.Irecv!(@view(buffer[..,k]), proc, id, MPI.COMM_WORLD)
            push!(reqs,req)
        end
    end

    # Wait for all comms to complete
    MPI.Waitall!(reqs)

    particles .= buffer

end

# Initialize arrays used by the filter
function init_filter(filter_params::FilterParameters, model_data, nprt_per_rank::Int, ::Vector{<:Random.AbstractRNG}, T::Type, ::BootstrapFilter)

    if MPI.Comm_rank(MPI.COMM_WORLD) == filter_params.master_rank
        weights = Vector{T}(undef, filter_params.nprt)
    else
        weights = Vector{T}(undef, nprt_per_rank)
    end

    resampling_indices = Vector{Int}(undef, filter_params.nprt)

    size = get_grid_size(model_data)
    n_state_var = get_n_state_var(model_data)

    statistics = Array{SummaryStat{T}, length(size) + 1}(undef, size..., n_state_var)
    avg_arr = Array{T, length(size) + 1}(undef, size..., n_state_var)
    var_arr = Array{T, length(size) + 1}(undef, size..., n_state_var)

    # Memory buffer used during copy of the states
    copy_buffer = Array{T, length(size) + 2}(undef, size..., n_state_var, nprt_per_rank)

    return (;weights, resampling_indices, statistics, avg_arr, var_arr, copy_buffer)
end

# Initialize arrays used by the filter
function init_filter(filter_params::FilterParameters, model_data, nprt_per_rank::Int, rng::Vector{<:Random.AbstractRNG}, T::Type, ::OptimalFilter)

    filter_data = init_filter(filter_params, model_data, nprt_per_rank, rng, T, BootstrapFilter())

    stations = get_stations(model_data)
    size = get_grid_size(model_data)
    domain_size = get_grid_domain_size(model_data)
    cell_size = get_grid_cell_size(model_data)

    grid = Grid(size...,cell_size...,domain_size...)
    grid_ext = Grid((grid.nx-1)*2, (grid.ny-1)*2, grid.dx, grid.dy, (grid.x_length-grid.dx)*2, (grid.y_length-grid.dy)*2)

    model_noise_params = get_model_noise_params(model_data)
    obs_noise_std = get_obs_noise_std(model_data)
    # Precompute two FFT plans, one in-place and the other out-of-place
    C = complex(T)
    tmp_array = Matrix{C}(undef, grid_ext.nx, grid_ext.ny)
    fft_plan, fft_plan! = FFTW.plan_fft(tmp_array), FFTW.plan_fft!(tmp_array)

    offline_matrices = init_offline_matrices(grid, grid_ext, stations, model_noise_params, obs_noise_std, fft_plan, fft_plan!, T)
    online_matrices = init_online_matrices(grid, grid_ext, stations, nprt_per_rank, T)

    return (; filter_data..., offline_matrices, online_matrices, stations, grid, grid_ext, rng, obs_noise_std, fft_plan, fft_plan!)
end

function update_particle_proposal!(model_data, filter_data, truth_observations, nprt_per_rank, filter_type::BootstrapFilter)

    update_particle_noise!(model_data, nprt_per_rank)

end

function update_particle_proposal!(model_data, filter_data, truth_observations, nprt_per_rank, filter_type::OptimalFilter)

        # Optimal Filter: After updating the particle dynamics, we apply the "optimal proposal" in
        #                 sample_height_proposal!() to the first state variable (height). We apply
        #                 a sample from the gaussian random field in update_particle_noise!() to the other
        #                 state variables (velocity).

        particles = get_particles(model_data)

        # Apply optimal proposal, the result will be in offline_matrices.samples
        sample_height_proposal!(@view(particles[:,:,1,:]),
                                filter_data.offline_matrices,
                                filter_data.online_matrices,
                                truth_observations,
                                filter_data.stations,
                                filter_data.grid,
                                filter_data.grid_ext,
                                filter_data.fft_plan,
                                filter_data.fft_plan!,
                                nprt_per_rank,
                                filter_data.rng[threadid()],
                                filter_data.obs_noise_std)

        # Add noise from the standard gaussian random field to all state variables in model_data
        update_particle_noise!(model_data, nprt_per_rank)

        # Overwrite the height state variable with the samples of the optimal proposal
        particles[:,:,1,:] .= filter_data.online_matrices.samples
        set_particles!(model_data, particles)

end

function run_particle_filter(init, filter_params::FilterParameters, model_params_dict::Dict, filter_type; rng::Union{Random.AbstractRNG,Nothing}=nothing)

    MPI.Init()

    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    my_size = MPI.Comm_size(MPI.COMM_WORLD)

    # For now, assume that the particles can be evenly divided between ranks
    @assert mod(filter_params.nprt, my_size) == 0

    nprt_per_rank = Int(filter_params.nprt / my_size)

    if filter_params.enable_timers
        TimerOutputs.enable_debug_timings(ParticleDA)
    end
    timer = TimerOutput()

    nprt_per_rank = Int(filter_params.nprt / MPI.Comm_size(MPI.COMM_WORLD))

    _rng = let
        m = if isnothing(rng)
            Random.MersenneTwister(filter_params.random_seed + my_rank)
        else
            rng
        end
        [m; accumulate(Future.randjump, fill(big(10)^20, nthreads()-1), init=m)]
    end

    # Do memory allocations
    @timeit_debug timer "Model initialization" model_data = init(model_params_dict, nprt_per_rank, my_rank, _rng)

    # TODO: put the body of this block in a function
    @timeit_debug timer "Filter initialization" filter_data = init_filter(filter_params, model_data, nprt_per_rank, _rng, Float64, filter_type)

    @timeit_debug timer "get_particles" particles = get_particles(model_data)
    @timeit_debug timer "Mean and Var" get_mean_and_var!(filter_data.statistics, particles, filter_params.master_rank)

    # Write initial state (time = 0) + metadata
    if(filter_params.verbose && my_rank == filter_params.master_rank)
        @timeit_debug timer "IO" begin
            unpack_statistics!(filter_data.avg_arr, filter_data.var_arr, filter_data.statistics)
            write_snapshot(filter_params.output_filename,
                           model_data,
                           filter_data.avg_arr,
                           filter_data.var_arr,
                           filter_data.weights,
                           0)
        end
    end

    for it in 1:filter_params.n_time_step

        # integrate true synthetic wavefield
        @timeit_debug timer "True State Update and Process Noise" truth_observations = update_truth!(model_data, nprt_per_rank)

        # Forecast: Update tsunami forecast and get observations from it
        # Parallelised with threads.

        @timeit_debug timer "Particle Dynamics" update_particle_dynamics!(model_data, nprt_per_rank);
        @timeit_debug timer "Particle Proposal" update_particle_proposal!(model_data, filter_data, truth_observations, nprt_per_rank, filter_type)
        @timeit_debug timer "Particle Observations" model_observations = get_particle_observations!(model_data, nprt_per_rank)

        @timeit_debug timer "Particle Weights" get_log_weights!(@view(filter_data.weights[1:nprt_per_rank]),
                                                       truth_observations,
                                                       model_observations,
                                                       filter_params.weight_std)

        # Gather weights to master rank and resample particles.
        # Doing MPI collectives in place to save memory allocations.
        # This style with if statmeents is recommended instead of MPI.Gather_in_place! which is a bit strange.
        # Note that only master_rank allocates memory for all particles. Other ranks only allocate
        # for their chunk of state.
        if my_rank == filter_params.master_rank
            @timeit_debug timer "MPI Gather" MPI.Gather!(MPI.IN_PLACE,
                                                         UBuffer(filter_data.weights, nprt_per_rank),
                                                         filter_params.master_rank,
                                                         MPI.COMM_WORLD)
            @timeit_debug timer "Weights" normalized_exp!(filter_data.weights)
            @timeit_debug timer "Resample" resample!(filter_data.resampling_indices, filter_data.weights, _rng[threadid()])

        else
            @timeit_debug timer "MPI Gather" MPI.Gather!(filter_data.weights,
                                                         nothing,
                                                         filter_params.master_rank,
                                                         MPI.COMM_WORLD)
        end

        # Broadcast resampled particle indices to all ranks
        MPI.Bcast!(filter_data.resampling_indices, filter_params.master_rank, MPI.COMM_WORLD)

        @timeit_debug timer "get_particles" particles = get_particles(model_data)
        @timeit_debug timer "State Copy" copy_states!(particles,
                                                      filter_data.copy_buffer,
                                                      filter_data.resampling_indices,
                                                      my_rank,
                                                      nprt_per_rank)

        @timeit_debug timer "Mean and Var" get_mean_and_var!(filter_data.statistics, particles, filter_params.master_rank)

        if my_rank == filter_params.master_rank && filter_params.verbose

            @timeit_debug timer "IO" begin
                unpack_statistics!(filter_data.avg_arr, filter_data.var_arr, filter_data.statistics)
                write_snapshot(filter_params.output_filename, model_data, filter_data.avg_arr, filter_data.var_arr, filter_data.weights, it)
            end

        end

    end

    if filter_params.enable_timers

        if my_rank == filter_params.master_rank
            print_timer(timer)
        end

        if filter_params.verbose
            # Gather string representations of timers from all ranks and write them on master
            str_timer = string(timer)

            timer_lengths = MPI.Gather(sizeof(str_timer), filter_params.master_rank, MPI.COMM_WORLD)

            if my_rank == filter_params.master_rank
                timer_chars = MPI.Gatherv!(str_timer,
                                           MPI.VBuffer(Vector{UInt8}(undef, sum(timer_lengths)), timer_lengths),
                                           filter_params.master_rank,
                                           MPI.COMM_WORLD)
                @timeit_debug timer "IO" write_timers(timer_lengths, my_size, timer_chars, filter_params)
            else
                MPI.Gatherv!(str_timer, nothing, filter_params.master_rank, MPI.COMM_WORLD)
            end
        end
    end

    unpack_statistics!(filter_data.avg_arr, filter_data.var_arr, filter_data.statistics)

    return get_truth(model_data), filter_data.avg_arr, filter_data.var_arr
end

# Initialise params struct with user-defined dict of values.
function get_params(T, user_input_dict::Dict)

    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = T(;user_input...)

end

get_params(user_input_dict::Dict) = get_params(FilterParameters, user_input_dict)

# Initialise params struct with default values
get_params() = FilterParameters()

function read_input_file(path_to_input_file::String)

    # Read input provided in a yaml file. Overwrite default input parameters with the values provided.
    if isfile(path_to_input_file)
        user_input_dict = YAML.load_file(path_to_input_file)
    else
        @warn "Input file " * path_to_input_file * " not found, using default parameters"
        user_input_dict = Dict()
    end
    return user_input_dict

end

"""
    run_particle_filter(init, path_to_input_file::String, filter_type::ParticleFilter)

Run the particle filter.  `init` is the function which initialise the model,
`path_to_input_file` is the path to the YAML file with the input parameters.
`filter_type` is the particle filter to use.  See [`ParticleFilter`](@ref) for
the possible values.
"""
function run_particle_filter(init, path_to_input_file::String, filter_type::ParticleFilter; rng::Union{Random.AbstractRNG,Nothing}=nothing)

    MPI.Init()

    # Do I/O on rank 0 only and then broadcast params
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0

        user_input_dict = read_input_file(path_to_input_file)

    else

        user_input_dict = nothing

    end

    user_input_dict = MPI.bcast(user_input_dict, 0, MPI.COMM_WORLD)

    return run_particle_filter(init, user_input_dict, filter_type; rng)

end

"""
    run_particle_filter(init, user_input_dict::Dict, filter_type::ParticleFilter)

Run the particle filter.  `init` is the function which initialise the model,
`user_input_dict` is the list of input parameters, as a `Dict`.  `filter_type`
is the particle filter to use.  See [`ParticleFilter`](@ref) for the possible
values.
"""
function run_particle_filter(init, user_input_dict::Dict, filter_type::ParticleFilter; rng::Union{Random.AbstractRNG,Nothing}=nothing)

    filter_params = get_params(FilterParameters, get(user_input_dict, "filter", Dict()))
    model_params_dict = get(user_input_dict, "model", Dict())

    return run_particle_filter(init, filter_params, model_params_dict, filter_type; rng)

end

end # module
