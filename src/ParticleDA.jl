module ParticleDA

using Random
using Distributions, Statistics, MPI, Base.Threads, YAML, HDF5
using TimerOutputs
using EllipsisNotation
using PDMats

export run_particle_filter, BootstrapFilter, OptimalFilter

include("params.jl")
include("io.jl")
include("OptimalFilter.jl")

using .Default_params

# Functions to extend in the model

"""
    ParticleDA.get_state_dimension(model_data) -> Integer
    
Return the positive integer dimension of the state vector `X` which is assumed to be
fixed for all time steps.
"""
function get_state_dimension end

"""
    ParticleDA.get_observation_dimension(model_data) -> Integer
    
Return the positive integer dimension of the observation vector `Y` which is assumed to 
be fixed for all time steps.
"""
function get_observation_dimension end

"""
    ParticleDA.get_state_eltype(model_data) -> Type

Return the element type of the state vector `X` which is assumed to be fixed for all 
  time steps.
"""
function get_state_eltype end

"""
    ParticleDA.get_observation_eltype(model_data) -> Type

Return the element type of the observation vector `Y` which is assumed to be fixed for 
all time steps.
"""
function get_observation_eltype end

"""
    ParticleDA.get_covariance_state_noise(model_data, i, j) -> Real

Return covariance `cov(U[i], U[j])` between components of the zero-mean Gaussian state 
noise vector `U`.
"""
function get_covariance_state_noise end

"""
    ParticleDA.get_covariance_observation_noise(model_data, i, j) -> Real

Return covariance `cov(V[i], V[j])` between components of the zero-mean Gaussian 
observation noise vector `V`.
"""
function get_covariance_observation_noise end

"""
    ParticleDA.get_covariance_state_observation_given_previous_state(
        model_data, i, j
    ) -> Real
    
Return the covariance `cov(X[i], Y[j])` between components of the state vector 
`X = F(x) + U` and observation vector `Y = H * X + V` where `H` is the linear 
observation operator, `F` the (potentially non-linear) forward operator describing the 
deterministic state dynamics, `U` is a zero-mean Gaussian state noise vector, `V` is a 
zero-mean Gaussian observation noise vector and `x` is the state at the previous 
observation time.
"""
function get_covariance_state_observation_given_previous_state end

"""
    ParticleDA.get_covariance_observation_observation_given_previous_state(
        model_data, i, j
    ) -> Real
    
Return covariance `cov(Y[i], Y[j])` between components of the observation vector 
`Y = H * (F(x) + U) + V` where `H` is the linear observation operator, `F` the 
(potentially non-linear) forward operator describing the deterministic state dynamics,
`U` is a zero-mean Gaussian state noise vector, `V` is a zero-mean Gaussian observation
noise vector and `x` is the state at the previous observation time.
"""
function get_covariance_observation_observation_given_previous_state end

"""
    ParticleDA.get_particles(model_data) -> AbstractMatrix

Return the two-dimensional array of state particles, with first dimension corresponding
to the state index and second the particle index.  This method is intended to be 
extended by the user with the above signature, specifying the type of `model_data`. 
Note: this function should return the particle data itself and not a copy, because it 
will be modified in-place.
"""
function get_particles end

"""
   ParticleDA.set_particles!(model_data, particles)

Overwrite state particles in `model_data`` with the data in the two-dimensional array 
`particles`.  This method is intended to be extended by the user with the above 
signature, specifying the type of `model_data`.
"""
function set_particles! end

"""
    ParticleDA.get_truth(model_data) -> AbstractVector

Return the vector of true observations.  This method is intended to be extended
by the user with the above signature, specifying the type of `model_data`.
"""
function get_truth end

"""
    ParticleDA.update_truth!(model_data) -> truth_observations

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
    ParticleDA.sample_observations_given_particles!(
        simulated_observations, model_data, nprt_per_rank::Int
    )

Simulate noisy observations of the state for each of the state particles in `model_data`
associated with the current MPI rank and write to the `simulated_observation` array
which should be of size `(dim_observation, nprt_per_rank)` where `dim_observation` is
the dimension of each observation vector and `nprt_per_rank` is the number of particles
per each MPI rank.
"""
function sample_observations_given_particles! end

"""
    ParticleDA.get_log_density_observation_given_state(observation, state, model_data)
    
Return the logarithm of the probability density of an observation vector given a
state vector. Any additive terms that are constant with respect to the state may be
neglected.
"""
function get_log_density_observation_given_state end

"""
    ParticleDA.get_observation_mean_given_state!(observation_mean, state, model_data)
    
Compute the mean of the multivariate normal distribution on the observations given
the current state and write to the first argument.
"""
function get_observation_mean_given_state! end

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

# Additional methods for models. These may be optionally extended by the user for a 
# specific `model_data` type, for example to provide more efficient implementations, 
# however the versions below will work providing methods for the generic functions
# described above are implemented by the model.

"""
    ParticleDA.get_state_indices_correlated_to_observations(
        model_data
    ) -> AbstractVector{Int}

Return the vector containing the indices of the state vector `X` which at least one of 
the observations `Y`` are correlated to, that is `i ∈ 1:get_state_dimension(model_data)`
such that `cov(X[i], Y[j]) > 0` for at least one 
`j ∈ 1:get_observation_dimension(model_data)`. This is used to avoid needing to compute
and store zero covariance terms. Defaults to returning all state indices which will
always give correct results but will be inefficient if there are zero blocks in 
`cov(X, Y)`.
"""
function get_state_indices_correlated_to_observations(model_data)
    return 1:get_state_dimension(model_data)
end

"""
    ParticleDA.get_covariance_observation_noise(model_data) -> AbstractPDMat

Return covariance matrix `cov(U, U)` of zero-mean Gaussian state noise vector `U`. 
Defaults to computing dense matrix using index-based 
`ParticleDA.get_covariance_state_noise` method. Models may extend to exploit any 
sparsity structure in covariance matrix.
"""
function ParticleDA.get_covariance_state_noise(model_data)
    state_dimension = get_state_dimension(model_data)
    cov = Matrix{get_state_eltype(model_data)}(
        undef, state_dimension, state_dimension
    )
    for i in 1:state_dimension
        for j in 1:i
            cov[i, j] = get_covariance_state_noise(model_data, i, j) 
        end
    end
    return PDMat(Symmetric(cov, :L))
end

"""
    ParticleDA.get_covariance_observation_noise(model_data) -> AbstractMatrix

Return covariance matrix `cov(V, V)` of zero-mean Gaussian observation noise vector `V`. 
Defaults to computing dense matrix using index-based 
`ParticleDA.get_covariance_observation_noise` method. Models may extend to exploit any 
sparsity structure in covariance matrix.
"""
function get_covariance_observation_noise(model_data)
    observation_dimension = get_observation_dimension(model_data)
    cov = Matrix{get_observation_eltype(model_data)}(
        undef, observation_dimension, observation_dimension
    )
    for i in 1:observation_dimension
        for j in 1:i
            cov[i, j] = get_covariance_observation_noise(model_data, i, j)
        end
    end
    return PDMat(Symmetric(cov, :L))
end

"""
    ParticleDA.get_covariance_observation_state_given_previous_state(
        model_data
    ) -> AbstractMatrix
    
Return the covariance matrix `cov(X[i], Y)` between the state vector `X = F(x) + U` and 
observation vector `Y = H * X + V` where `H` is the linear  observation operator, `F` 
the (potentially non-linear) forward operator describing the  deterministic 
state dynamics, `U` is a zero-mean Gaussian state noise vector, `V` is a 
zero-mean Gaussian observation noise vector and `x` is the state at the previous 
observation time. The indices `i` here are those returned by 
[`get_state_indices_correlated_to_observations`](@ref) which can be used to avoid
computing and storing blocks of `cov(X, Y)` which will always be zero. 
"""
function get_covariance_observation_state_given_previous_state(model_data)
    state_indices = get_state_indices_correlated_to_observations(model_data)
    observation_dimension = get_observation_dimension(model_data)
    cov = Matrix{get_state_eltype(model_data)}(
        undef, length(state_indices), observation_dimension
    )
    for i in state_indices
        for j in 1:observation_dimension
            cov[i, j] = get_covariance_state_observation_given_previous_state(
                model_data, i, j
            )
        end
    end
    return cov
end

"""
    ParticleDA.get_covariance_observation_observation_given_previous_state(
        model_data
    ) -> AbstractPDMat
    
Return covariance matrix `cov(Y, Y)` of the observation vector `Y = H * (F(x) + U) + V` 
where `H` is the linear observation operator, `F` the (potentially non-linear) forward 
operator describing the deterministic state dynamics, `U` is a zero-mean Gaussian state
noise vector, `V` is a zero-mean Gaussian observation noise vector and `x` is the state
at the previous observation time. Defaults to computing a dense matrix. Models may 
extend to exploit any sparsity structure in covariance matrix.
"""
function get_covariance_observation_observation_given_previous_state(
    model_data
)
    observation_dimension = get_observation_dimension(model_data)
    cov = Matrix{get_observation_eltype(model_data)}(
        undef, observation_dimension, observation_dimension
    )
    for i in 1:observation_dimension
        for j in 1:i
            cov[i, j] = get_covariance_observation_observation_given_previous_state(
                model_data, i, j
            )
        end
    end
    return PDMat(Symmetric(cov, :L))
end

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


# Get logarithm of unnormalized importance weights for particles for filter specific
# proposal distribution
function get_log_weights!(
    log_weights::AbstractVector{T},  
    observation::AbstractVector{T}, 
    model_data, 
    filter_data::NamedTuple,
    filter_type::ParticleFilter,
) where T
    particles = get_particles(model_data)
    for p in 1:size(log_weights, 1)
        log_weights[p] = compute_individual_particle_log_weight(
            observation, 
            particles[:, p],
            model_data,
            filter_data, 
            filter_type
       )
    end
end

function compute_individual_particle_log_weight(
    observation::AbstractVector{T},
    state::AbstractVector{T},
    model_data,
    filter_data::NamedTuple,
    ::BootstrapFilter,
) where T
    return ParticleDA.get_log_density_observation_given_state(
        observation, state, model_data
    )
end

function compute_individual_particle_log_weight(
    observation::AbstractVector{T},
    state::AbstractVector{T},
    model_data,
    filter_data::NamedTuple,
    ::OptimalFilter,
) where T
    observation_mean = ParticleDA.get_observation_mean_given_state!(
        buffer, state, model_data
    )
    return -invquad(filter_data.offline_matrices.cov_Y_Y, observation - observation_mean) / 2
end

#
function normalized_exp!(weight::AbstractVector)

    weight .-= maximum(weight)
    @. weight = exp(weight)
    weight ./= sum(weight)

end

# Resample particles from given weights using Stochastic Universal Sampling
function resample!(resampled_indices::AbstractVector{Int}, weight::AbstractVector{T}, rng::Random.AbstractRNG=Random.TaskLocalRNG()) where T

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
function init_filter(filter_params::FilterParameters, model_data, nprt_per_rank::Int, ::Random.AbstractRNG, ::BootstrapFilter)

    state_dimension = get_state_dimension(model_data)
    cov_observation_noise = get_covariance_observation_noise(model_data)
    state_eltype = get_state_eltype(model_data)

    if MPI.Comm_rank(MPI.COMM_WORLD) == filter_params.master_rank
        weights = Vector{state_eltype}(undef, filter_params.nprt)
    else
        weights = Vector{state_eltype}(undef, nprt_per_rank)
    end

    resampling_indices = Vector{Int}(undef, filter_params.nprt)
    
    statistics = Array{SummaryStat{state_eltype}, 1}(undef, state_dimension)
    avg_arr = Array{state_eltype, 1}(undef, state_dimension)
    var_arr = Array{state_eltype, 1}(undef, state_dimension)

    # Memory buffer used during copy of the states
    copy_buffer = Array{state_eltype, 2}(undef, state_dimension, nprt_per_rank)

    return (; weights, resampling_indices, statistics, avg_arr, var_arr, copy_buffer, cov_observation_noise)
end

# Initialize arrays used by the filter
function init_filter(filter_params::FilterParameters, model_data, nprt_per_rank::Int, rng::Random.AbstractRNG, ::OptimalFilter)
    filter_data = init_filter(filter_params, model_data, nprt_per_rank, rng, BootstrapFilter())

    offline_matrices = init_offline_matrices(model_data)
    online_matrices = init_online_matrices(model_data, nprt_per_rank)

    return (; filter_data..., offline_matrices, online_matrices, rng)
end

function update_particle_proposal!(model_data, filter_data, observations, nprt_per_rank, filter_type::BootstrapFilter)
    update_particle_noise!(model_data, nprt_per_rank)
end

function update_particle_proposal!(model_data, filter_data, observations, nprt_per_rank, filter_type::OptimalFilter)
    update_particle_noise!(model_data, nprt_per_rank)
    update_particles_given_observations!(model_data, filter_data, observations, nprt_per_rank)
end

function run_particle_filter(init, filter_params::FilterParameters, model_params_dict::Dict, filter_type; rng::Random.AbstractRNG=Random.TaskLocalRNG())

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

    # Do memory allocations
    @timeit_debug timer "Model initialization" model_data = init(model_params_dict, nprt_per_rank, my_rank, rng)

    # TODO: put the body of this block in a function
    @timeit_debug timer "Filter initialization" filter_data = init_filter(filter_params, model_data, nprt_per_rank, rng, filter_type)

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
        @timeit_debug timer "True State Update and Process Noise" observations = update_truth!(model_data)

        # Forecast: Update tsunami forecast and get observations from it
        # Parallelised with threads.

        @timeit_debug timer "Particle Dynamics" update_particle_dynamics!(model_data, nprt_per_rank);
        @timeit_debug timer "Particle Proposal" update_particle_proposal!(model_data, filter_data, observations, nprt_per_rank, filter_type)
        
        # TODO: need to have access to *previous* states here as for optimal proposal
        # particle weights depend on previous particle values not updated values.
        @timeit_debug timer "Particle Weights" get_log_weights!(
            @view(filter_data.weights[1:nprt_per_rank]),
            observations,
            model_data,
            filter_data,
            filter_type,
        )

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
            @timeit_debug timer "Resample" resample!(filter_data.resampling_indices, filter_data.weights, rng)

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
function run_particle_filter(init, path_to_input_file::String, filter_type::ParticleFilter; rng::Random.AbstractRNG=Random.TaskLocalRNG())

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
function run_particle_filter(init, user_input_dict::Dict, filter_type::ParticleFilter; rng::Random.AbstractRNG=Random.TaskLocalRNG())

    filter_params = get_params(FilterParameters, get(user_input_dict, "filter", Dict()))
    model_params_dict = get(user_input_dict, "model", Dict())

    return run_particle_filter(init, filter_params, model_params_dict, filter_type; rng)

end

end # module
