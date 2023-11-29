module LinearGaussian

using Distributions
using FillArrays
using HDF5
using Random
using PDMats
using ParticleDA

Base.@kwdef struct LinearGaussianModelParameters{
    S <: Real,
    T <: Real,
    TM <: AbstractMatrix{S},
    OM <: AbstractMatrix{T},
    IV <: AbstractVector{S},
    ICM <: AbstractMatrix{S},
    SCM <: AbstractMatrix{S},
    OCM <: AbstractMatrix{T}
}
    state_transition_matrix::TM
    observation_matrix::OM
    initial_state_mean::IV
    initial_state_covar::ICM
    state_noise_covar::SCM
    observation_noise_covar::OCM
end

struct LinearGaussianModel{S <: Real, T <: Real}
    state_dimension::Int
    observation_dimension::Int
    parameters::LinearGaussianModelParameters{S, T}
    initial_state_distribution::MvNormal{S}
    state_noise_distribution::MvNormal{S}
    observation_noise_distribution::MvNormal{T}
end

function diagonal_linear_gaussian_model_parameters(
    state_dimension=3,
    state_transition_coefficient=0.8,
    observation_coefficient=1.0,
    initial_state_std=1.0,
    state_noise_std=0.6,
    observation_noise_std=0.5,
)
    return Dict(
        :state_transition_matrix => ScalMat(
            state_dimension, state_transition_coefficient
        ),
        :observation_matrix => ScalMat(
            state_dimension, observation_coefficient
        ),
        :initial_state_mean => Zeros(state_dimension),
        :initial_state_covar => ScalMat(
            state_dimension, initial_state_std^2
        ),
        :state_noise_covar => ScalMat(
            state_dimension, state_noise_std^2
        ),
        :observation_noise_covar => ScalMat(
            state_dimension, observation_noise_std^2
        ),
    )
end

function stochastically_driven_dsho_model_parameters(
    δ=0.2,
    ω=1.,
    Q=2.,
    σ=0.5,
)    
    β = sqrt(Q^2 - 1 / 4)
    return Dict(
        :state_transition_matrix => exp(-ω * δ / 2Q) * [
            [
                cos(ω * β * δ / Q) + sin(ω * β * δ / Q) / 2β,
                Q * sin(ω * β * δ / Q) / (ω * β)
            ]';
            [
                -Q * ω * sin(ω * δ * β / Q) / β,
                cos(ω * δ * β / Q) - sin(ω * δ * β / Q) / 2β
            ]'
        ],
        :observation_matrix => ScalMat(2, 1.),
        :initial_state_mean => Zeros(2),
        :initial_state_covar => ScalMat(2, 1.),
        :state_noise_covar => PDMat(
            Q * exp(-ω * δ / Q) * [
                [
                    (
                        (cos(2ω * δ * β / Q) - 1) 
                        - 2β * sin(2ω * δ * β / Q) 
                        + 4β^2 * (exp(ω * δ / Q) - 1)
                    ) / (8ω^3 * β^2),
                    Q * sin(ω * δ * β / Q)^2 / (2ω^2 * β^2)
                ]';
                [
                    Q * sin(ω * δ * β / Q)^2 / (2ω^2 * β^2),
                    (
                        (cos(2ω * δ * β / Q) - 1) 
                        + 2β * sin(2ω * δ * β / Q) 
                        + 4β^2 * (exp(ω * δ / Q) - 1)
                    ) / (8ω * β^2),                    
                ]'
            ]
        ),
        :observation_noise_covar => ScalMat(2, σ^2)    
    )
end

function init(parameters_dict::Dict, n_tasks::Int=1)
    parameters = LinearGaussianModelParameters(; parameters_dict...)
    (observation_dimension, state_dimension) = size(
        parameters.observation_matrix
    )
    return LinearGaussianModel(
        state_dimension,
        observation_dimension,
        parameters,
        (
            MvNormal(m, c)
            for (m, c) in (
                (parameters.initial_state_mean, parameters.initial_state_covar), 
                (Zeros(state_dimension), parameters.state_noise_covar), 
                (Zeros(observation_dimension), parameters.observation_noise_covar), 
            )
        )...
    )
end

ParticleDA.get_state_dimension(model::LinearGaussianModel) = model.state_dimension
ParticleDA.get_observation_dimension(model::LinearGaussianModel) = model.observation_dimension
ParticleDA.get_state_eltype(::LinearGaussianModel{S, T}) where {S, T} = S
ParticleDA.get_observation_eltype(::LinearGaussianModel{S, T}) where {S, T} = T

function ParticleDA.sample_initial_state!(
    state::AbstractVector{T},
    model::LinearGaussianModel{S, T}, 
    rng::Random.AbstractRNG,
    task_index::Integer=1,
) where {S, T}
    rand!(rng, model.initial_state_distribution, state)
end

function ParticleDA.update_state_deterministic!(
    state::AbstractVector{T}, 
    model::LinearGaussianModel{S, T}, 
    time_index::Int,
    task_index::Integer=1,
) where {S, T}
    state .= model.parameters.state_transition_matrix * state
end

function ParticleDA.update_state_stochastic!(
    state::AbstractVector{T}, 
    model::LinearGaussianModel{S, T}, 
    rng::Random.AbstractRNG,
    task_index::Integer=1,
) where {S, T}
    rand!(rng, state + model.state_noise_distribution, state)
end

function ParticleDA.sample_observation_given_state!(
    observation::AbstractVector{T},
    state::AbstractVector{S}, 
    model::LinearGaussianModel{S, T}, 
    rng::Random.AbstractRNG,
    task_index::Integer=1,
) where {S <: Real, T <: Real}
    rand!(
        rng,
        (model.parameters.observation_matrix * state)
        + model.observation_noise_distribution,
        observation
    )
end

function ParticleDA.get_log_density_observation_given_state(
    observation::AbstractVector{T},
    state::AbstractVector{S},
    model::LinearGaussianModel{S, T},
    task_index::Integer=1,
) where {S <: Real, T <: Real}
    return logpdf(
        (model.parameters.observation_matrix * state)
        + model.observation_noise_distribution,
        observation
    )
end

function ParticleDA.write_model_metadata(file::HDF5.File, model::LinearGaussianModel)
    group_name = "parameters"
    if !haskey(file, group_name)
        group = create_group(file, group_name)
        for field in fieldnames(typeof(model.parameters))
            value = getfield(model.parameters, field)
            attributes(group)[string(field)] = (
                isa(value, AbstractArray) ? collect(value) : value
            )
        end
    else
        @warn "Write failed, group $group_name already exists in  $(file.filename)!"
    end
end

function ParticleDA.get_observation_mean_given_state!(
    observation_mean::AbstractVector{T},
    state::AbstractVector{S},
    model::LinearGaussianModel{S, T},
    task_index::Integer=1,
) where {S <: Real, T <: Real}
    observation_mean .= model.parameters.observation_matrix * state
end

function ParticleDA.get_initial_state_mean(model::LinearGaussianModel)
    return collect(model.initial_state_distribution.μ)
end

function ParticleDA.get_covariance_initial_state(model::LinearGaussianModel)
    return model.initial_state_distribution.Σ
end

function ParticleDA.get_covariance_state_noise(model::LinearGaussianModel)
    return model.state_noise_distribution.Σ
end

function ParticleDA.get_covariance_state_noise(model::LinearGaussianModel, i::Int, j::Int)
    return model.state_noise_distribution.Σ[i, j]
end

function ParticleDA.get_covariance_observation_noise(model::LinearGaussianModel)
    return model.observation_noise_distribution.Σ
end

function ParticleDA.get_covariance_observation_noise(
    model::LinearGaussianModel, i::Int, j::Int
)
    return model.observation_noise_distribution.Σ[i, j]
end

function ParticleDA.get_covariance_state_observation_given_previous_state(
    model::LinearGaussianModel, i::Int, j::Int
)
    return model.state_noise_distribution.Σ[i, j]
end

function ParticleDA.get_covariance_observation_observation_given_previous_state(
    model::LinearGaussianModel, i::Int, j::Int
)
    return (
        model.state_noise_distribution.Σ[i, j]
        + model.observation_noise_distribution.Σ[i, j]
    )
end

function ParticleDA.get_state_indices_correlated_to_observations(model::LinearGaussianModel)
    return 1:ParticleDA.get_state_dimension(model)
end

end
