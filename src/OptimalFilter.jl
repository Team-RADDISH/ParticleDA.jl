using LinearAlgebra
using PDMats

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
function init_offline_matrices(model_data)
    return OfflineMatrices(
        get_covariance_observation_state_given_previous_state(model_data), 
        get_covariance_observation_observation_given_previous_state(model_data),
    )
end

# Allocate memory for matrices that will be updated during the time stepping loop.
function init_online_matrices(model_data, nprt_per_rank::Int)
    observation_dimension = get_observation_dimension(model_data)
    updated_state_dimension = length(
        get_state_indices_correlated_to_observations(model_data)
    )
    return OnlineMatrices(
        Matrix{get_observation_eltype(model_data)}(
            undef, observation_dimension, nprt_per_rank
        ),
        Matrix{get_state_eltype(model_data)}(
            undef, updated_state_dimension, nprt_per_rank
        ),
    )
end

LinearAlgebra.ldiv!(A::PDMat, B::AbstractMatrix) = ldiv!(A.chol, B)

function update_states_given_observations!(
    states::AbstractMatrix, 
    observation::AbstractVector, 
    model_data, 
    filter_data, 
    rng::Random.AbstractRNG
)
    observation_buffer = filter_data.online_matrices.observation_buffer
    state_buffer = filter_data.online_matrices.state_buffer
    cov_X_Y = filter_data.offline_matrices.cov_X_Y
    cov_Y_Y = filter_data.offline_matrices.cov_Y_Y
    # Compute Y ~ Normal(HX, R) for each particle X
    num_particle = size(states, 2)
    @Threads.threads :static for p in 1:num_particle
        sample_observation_given_state!(
            selectdim(observation_buffer, 2, p),
            selectdim(states, 2, p),
            model_data,
            rng
        )
    end
    # To allow for only a subset of state components being correlated to observations
    # (given previous state) and so needing to be updated as part of optimal proposal
    # the model can specify the relevant indices to update. This avoids computing a
    # zero update for such state components 
    update_indices = get_state_indices_correlated_to_observations(model_data)
    # Update particles to account for observations, X = X - QHᵀ(HQHᵀ + R)⁻¹(Y − y)
    # The following lines are equivalent to the single statement version
    #     particles[update_indices..., :] .-= (
    #         cov_X_Y * (cov_Y_Y  \ (observation_buffer .- observation))
    #     )
    # but we stage across multiple statements to allow using in-place operations to
    # avoid unnecessary allocations.
    observation_buffer .-= observation
    ldiv!(cov_Y_Y, observation_buffer)
    mul!(state_buffer, cov_X_Y, observation_buffer)
    states[update_indices, :] .-= state_buffer
end
