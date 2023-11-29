"""
    ParticleFilter

Abstract type for particle filters.  Currently implemented subtypes are:
* [`BootstrapFilter`](@ref)
* [`OptimalFilter`](@ref)
"""
abstract type ParticleFilter end

"""
    ParticleDA.init_filter(filter_params, model, nprt_per_rank, ::T) -> NamedTuple

Initialise any data structures required by filter of type `T`, with filtering specific
parameters specified by `filter_params`, state space model to perform filtering with
described by `model` and `nprt_per_rank` particles per MPI rank.

New filter implementations should extend this method specifying `T` as the appropriate
singleton type for the new filter.
"""
function init_filter end

"""
    ParticleDA.sample_proposal_and_compute_log_weights!(
        states, log_weights, observation, model, filter_data, ::T, rng
    )

Sample new values for two-dimensional array of state vectors `states` from proposal
distribution writing in-place to `states` array and compute logarithm of unnormalized 
particle weights writing to `log_weights` given observation vector `observation`, with
state space model described by `model`, named tuple of filter specific data
structures `filter_data`, filter type `T` and random number generator `rng` used to
generate any random draws.

New filter implementations should extend this method specifying `T` as the appropriate
singleton type for the new filter.
"""
function sample_proposal_and_compute_log_weights! end

"""
    BootstrapFilter <: ParticleFilter

Singleton type `BootstrapFilter`.  This can be used as argument of 
[`run_particle_filter`](@ref) to select the bootstrap filter.
"""
struct BootstrapFilter <: ParticleFilter end

"""
    OptimalFilter <: ParticleFilter

Singleton type `OptimalFilter`.  This can be used as argument of 
[`run_particle_filter`](@ref) to select the optimal proposal filter (for conditionally
linear-Gaussian models).
"""
struct OptimalFilter <: ParticleFilter end

# Initialize arrays used by the filter
function init_filter(
    filter_params::FilterParameters, 
    model, 
    nprt_per_rank::Int,
    n_tasks::Int,
    ::Type{BootstrapFilter}, 
    summary_stat_type::Type{<:AbstractSummaryStat}
)
    state_dimension = get_state_dimension(model)
    state_eltype = get_state_eltype(model)
    if MPI.Comm_rank(MPI.COMM_WORLD) == filter_params.master_rank
        weights = Vector{state_eltype}(undef, filter_params.nprt)
        unpacked_statistics = init_unpacked_statistics(
            summary_stat_type, state_eltype, state_dimension
        )
    else
        weights = Vector{state_eltype}(undef, nprt_per_rank)
        unpacked_statistics = nothing
    end
    resampling_indices = Vector{Int}(undef, filter_params.nprt)
    statistics = init_statistics(summary_stat_type, state_eltype, state_dimension)

    # Memory buffer used during copy of the states
    copy_buffer = Array{state_eltype, 2}(undef, state_dimension, nprt_per_rank)
    return (; 
        weights,
        resampling_indices,
        statistics,
        unpacked_statistics,
        copy_buffer,
        n_tasks,
    )
end

struct OfflineMatrices{R<:Real, M<:AbstractMatrix{R}, F<:AbstractPDMat{R}}
    # Covariance between state X and observations Y given previous state x
    cov_X_Y::M  
    # Covariance between observations Y given previous state x
    cov_Y_Y::F  
end

struct OnlineMatrices{T<:AbstractMatrix}
    # Buffer of size (observation dimension, number of particles per rank) for holding
    # intermediate values in computation of optimal proposal update
    observation_buffer::T
    # Buffer of size (state dimension, number of particles per rank) for holding
    # intermediate values in computation of optimal proposal update
    state_buffer::T
end

# Allocate and compute matrices that do not depend on time-dependent variables
function init_offline_matrices(model)
    return OfflineMatrices(
        get_covariance_state_observation_given_previous_state(model), 
        get_covariance_observation_observation_given_previous_state(model),
    )
end

# Allocate memory for matrices that will be updated during the time stepping loop.
function init_online_matrices(model, nprt_per_rank::Int)
    observation_dimension = get_observation_dimension(model)
    updated_state_dimension = length(
        get_state_indices_correlated_to_observations(model)
    )
    return OnlineMatrices(
        Matrix{get_observation_eltype(model)}(
            undef, observation_dimension, nprt_per_rank
        ),
        Matrix{get_state_eltype(model)}(
            undef, updated_state_dimension, nprt_per_rank
        ),
    )
end

# Initialize arrays used by the filter
function init_filter(
    filter_params::FilterParameters, 
    model,
    nprt_per_rank::Int,
    n_tasks::Int,
    ::Type{OptimalFilter}, 
    summary_stat_type::Type{<:AbstractSummaryStat}
)
    filter_data = init_filter(
        filter_params, model, nprt_per_rank, n_tasks, BootstrapFilter, summary_stat_type
    )
    offline_matrices = init_offline_matrices(model)
    online_matrices = init_online_matrices(model, nprt_per_rank)
    observation_dimension = get_observation_dimension(model)
    observation_eltype = get_observation_eltype(model)
    observation_mean_buffer = Array{observation_eltype, 2}(
        undef, observation_dimension, filter_data.n_tasks
    )
    return (; filter_data..., offline_matrices, online_matrices, observation_mean_buffer)
end

function sample_proposal_and_compute_log_weights!(
    states::AbstractMatrix,
    log_weights::AbstractVector,
    observation::AbstractVector,
    time_index::Integer,
    model,
    filter_data::NamedTuple,
    ::Type{BootstrapFilter},
    rng::Random.AbstractRNG,
)
    n_particle = size(states, 2)
    @sync for (particle_indices, task_index) in chunks(1:n_particle, filter_data.n_tasks)
        Threads.@spawn for particle_index in particle_indices
            state = selectdim(states, 2, particle_index)
            update_state_deterministic!(state, model, time_index, task_index)
            update_state_stochastic!(state, model, rng, task_index)
            log_weights[particle_index] = get_log_density_observation_given_state(
                observation, state, model, task_index
            )
        end
    end
end

function get_log_density_observation_given_previous_state(
    observation::AbstractVector{T},
    pre_noise_state::AbstractVector{S},
    model,
    filter_data::NamedTuple,
    task_index::Integer=1
) where {S, T}
    observation_mean = selectdim(filter_data.observation_mean_buffer, 2, task_index)
    get_observation_mean_given_state!(observation_mean, pre_noise_state, model, task_index)
    return -invquad(
        filter_data.offline_matrices.cov_Y_Y, observation - observation_mean
    ) / 2 
end

# ldiv! not currently defined for PDMat so define here
LinearAlgebra.ldiv!(A::PDMat, B::AbstractMatrix) = ldiv!(A.chol, B)

function update_states_given_observations!(
    states::AbstractMatrix, 
    observation::AbstractVector, 
    model, 
    filter_data, 
    rng::Random.AbstractRNG
)
    observation_buffer = filter_data.online_matrices.observation_buffer
    state_buffer = filter_data.online_matrices.state_buffer
    cov_X_Y = filter_data.offline_matrices.cov_X_Y
    cov_Y_Y = filter_data.offline_matrices.cov_Y_Y
    # Compute Y ~ Normal(HX, R) for each particle X
    n_particle = size(states, 2)
    @sync for (particle_indices, task_index) in chunks(1:n_particle, filter_data.n_tasks)
        Threads.@spawn for particle_index in particle_indices
            sample_observation_given_state!(
                selectdim(observation_buffer, 2, particle_index),
                selectdim(states, 2, particle_index),
                model,
                rng,
                task_index
            )
        end
    end
    # To allow for only a subset of state components being correlated to observations
    # (given previous state) and so needing to be updated as part of optimal proposal
    # the model can specify the relevant indices to update. This avoids computing a
    # zero update for such state components 
    update_indices = get_state_indices_correlated_to_observations(model)
    # Update particles to account for observations, X = X - QHᵀ(HQHᵀ + R)⁻¹(Y − y)
    # The following lines are equivalent to the single statement version
    #     states[update_indices..., :] .-= (
    #         cov_X_Y * (cov_Y_Y  \ (observation_buffer .- observation))
    #     )
    # but we stage across multiple statements to allow using in-place operations to
    # avoid unnecessary allocations.
    observation_buffer .-= observation
    ldiv!(cov_Y_Y, observation_buffer)
    mul!(state_buffer, cov_X_Y, observation_buffer)
    @view(states[update_indices, :]) .-= state_buffer
end

function sample_proposal_and_compute_log_weights!(
    states::AbstractMatrix,
    log_weights::AbstractVector,
    observation::AbstractVector,
    time_index::Integer,
    model,
    filter_data::NamedTuple,
    ::Type{OptimalFilter},
    rng::Random.AbstractRNG,
)
    n_particle = size(states, 2)
    @sync for (particle_indices, task_index) in chunks(1:n_particle, filter_data.n_tasks)
        Threads.@spawn for particle_index in particle_indices
            state = selectdim(states, 2, particle_index)
            update_state_deterministic!(state, model, time_index, task_index)
            # Particle weights for optimal proposal _do not_ depend on state noise values
            # therefore we calculate them using states after applying deterministic part of
            # time update but before adding state noise
            log_weights[particle_index] = get_log_density_observation_given_previous_state(
                observation, state, model, filter_data, task_index
            )
            update_state_stochastic!(state, model, rng, task_index)
        end
    end
    # Update to account for conditioning on observations can be performed using matrix-
    # matrix level 3 BLAS operations therefore perform outside of threaded loop over
    # particles 
    update_states_given_observations!(states, observation, model, filter_data, rng)
end
