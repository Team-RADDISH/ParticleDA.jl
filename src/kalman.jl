module Kalman

using LinearAlgebra
using PDMats
using ParticleDA

"""
    lmult_by_state_transition_matrix!(matrix::AbstractMatrix, model, time_index)

Compute `matrix = state_transition_matrix * matrix`."""
function lmult_by_state_transition_matrix!(
	matrix::AbstractMatrix, model, time_index
)
	for col in eachcol(matrix)
	    ParticleDA.update_state_deterministic!(
	        col, model, time_index
	    )
	end
end

"""
    lmult_by_observation_matrix!(
        output_matrix::AbstractMatrix, rhs_matrix::AbstractMatrix, model
    )

Compute `output_matrix = observation_matrix * rhs_matrix`."""
function lmult_by_observation_matrix!(
	output_matrix::AbstractMatrix, rhs_matrix::AbstractMatrix, model
)
	for (observation_vector, state_vector) in zip(
		eachcol(output_matrix), eachcol(rhs_matrix)
	)
		ParticleDA.get_observation_mean_given_state!(
			observation_vector, state_vector, model
		)
	end
end

abstract type AbstractKalmanFilter end

"""Kalman filter for linear Gaussian state space models using matrix-free updates.

Applies model state transition and observation functions directly to perform covariance
updates. This is more memory efficient and allows for time varying state transitions but
may be slower compared to using explicit matrix-matrix multiplies.
"""
struct MatrixFreeKalmanFilter <: AbstractKalmanFilter 
    model
end

"""
    pre_and_postmultiply_by_state_transition_matrix!(
        state_covar::Matrix, filter::MatrixFreeKalmanFilter, time_index::Int
    )

Compute `state_covar = transition_matrix * state_covar * transition_matrix'`.
"""
function pre_and_postmultiply_by_state_transition_matrix!(
    state_covar::Matrix, filter::MatrixFreeKalmanFilter, time_index::Int
)
    lmult_by_state_transition_matrix!(state_covar, filter.model, time_index)
    lmult_by_state_transition_matrix!(state_covar', filter.model, time_index)
end

"""
    pre_and_postmultiply_by_state_transition_matrix!(
        state_covar::Matrix, filter::MatrixFreeKalmanFilter, time_index::Int
    )

Compute `observation_covar = observation_matrix * state_covar * observation_matrix'`.
"""
function pre_and_postmultiply_by_observation_matrix!(
    state_observation_covar::Matrix, 
    observation_covar::Matrix, 
    state_covar::Matrix, 
    filter::MatrixFreeKalmanFilter
)
    lmult_by_observation_matrix!(
        state_observation_covar', state_covar', filter.model
    )
    lmult_by_observation_matrix!(
        observation_covar, state_observation_covar, filter.model
    )
end    

"""Kalman filter for linear Gaussian state space models.

Explicitly constructs state transition and observation matrices. Assumes state
transition matrix is time-invariant.
"""
struct KalmanFilter <: AbstractKalmanFilter 
    transition_matrix::Matrix
    observation_matrix::Matrix
    temp_matrix::Matrix
end

function KalmanFilter(model)
	transition_matrix = Matrix{ParticleDA.get_state_eltype(model)}(
        I, 
        ParticleDA.get_state_dimension(model), 
        ParticleDA.get_state_dimension(model)
    )
    observation_matrix = Matrix{ParticleDA.get_state_eltype(model)}(
        undef, 
		ParticleDA.get_observation_dimension(model),
        ParticleDA.get_state_dimension(model), 
    )
	temp_matrix = Matrix{ParticleDA.get_state_eltype(model)}(
        undef, 
        ParticleDA.get_state_dimension(model), 
        ParticleDA.get_state_dimension(model)
    )
	lmult_by_observation_matrix!(
		observation_matrix, transition_matrix, model
	)
	lmult_by_state_transition_matrix!(transition_matrix, model, 0)
    return KalmanFilter(transition_matrix, observation_matrix, temp_matrix)
end

function pre_and_postmultiply_by_state_transition_matrix!(
    state_covar::Matrix, filter::KalmanFilter, time_index::Int
)
    mul!(filter.temp_matrix, state_covar, filter.transition_matrix')
    mul!(state_covar, filter.transition_matrix, filter.temp_matrix)
end

function pre_and_postmultiply_by_observation_matrix!(
    state_observation_covar::Matrix,
    observation_covar::Matrix,
    state_covar::Matrix,
    filter::KalmanFilter
)
    mul!(state_observation_covar, state_covar, filter.observation_matrix')
    mul!(observation_covar, filter.observation_matrix, state_observation_covar)
end    

"""
    run_kalman_filter(
        model, observation_sequence[, filter_type=KalmanFilter]
    )

Run Kalman filter on a linear-Gaussian state space model `model` with observations
`observation_sequence`. The `filter_type` argument can be used to set the implementation
used for the filtering updates.
"""
function run_kalman_filter(
	model, 
    observation_sequence::Matrix , 
    filter_type::Type{<:AbstractKalmanFilter}=KalmanFilter
)
    state_mean = ParticleDA.get_initial_state_mean(model)
    state_covar = Matrix(ParticleDA.get_covariance_initial_state(model))
    state_mean_sequence = Matrix{ParticleDA.get_state_eltype(model)}(
        undef, 
        ParticleDA.get_state_dimension(model), 
        size(observation_sequence, 2),
    )
    state_var_sequence = Matrix{ParticleDA.get_state_eltype(model)}(
        undef, 
        ParticleDA.get_state_dimension(model), 
        size(observation_sequence, 2),
    )
    observation_mean = Vector{ParticleDA.get_observation_eltype(model)}(
        undef, ParticleDA.get_observation_dimension(model)
    )
    state_observation_covar = Matrix{ParticleDA.get_state_eltype(model)}(
        undef, 
        ParticleDA.get_state_dimension(model), 
        ParticleDA.get_observation_dimension(model)
    )
    observation_covar = Matrix{ParticleDA.get_observation_eltype(model)}(
        undef, 
        ParticleDA.get_observation_dimension(model), 
        ParticleDA.get_observation_dimension(model)
    )
    observation_noise_covar = ParticleDA.get_covariance_observation_noise(model)
    state_noise_covar = ParticleDA.get_covariance_state_noise(model)
	kalman_filter = filter_type(model)
    for (time_index, observation) in enumerate(eachcol(observation_sequence))
        ParticleDA.update_state_deterministic!(
            state_mean, model, time_index
        )
        ParticleDA.get_observation_mean_given_state!(
            observation_mean, state_mean, model
        )
        pre_and_postmultiply_by_state_transition_matrix!(
            state_covar, kalman_filter, time_index
        )
        pdadd!(state_covar, state_noise_covar)
        pre_and_postmultiply_by_observation_matrix!(
            state_observation_covar, observation_covar, state_covar, kalman_filter
        )
        pdadd!(observation_covar, observation_noise_covar)
        chol_observation_covar = cholesky!(Symmetric(observation_covar))
        state_mean .+= state_observation_covar * (
            chol_observation_covar \ (observation - observation_mean)
        )
        state_covar .-= (
            state_observation_covar * (
                chol_observation_covar \ state_observation_covar'
            )
        )
        state_mean_sequence[:, time_index] = state_mean
        state_var_sequence[:, time_index] = diag(state_covar)
    end
	return state_mean_sequence, state_var_sequence
end

end
