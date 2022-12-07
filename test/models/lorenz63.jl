module Lorenz63

using Base.Threads
using Distributions
using FillArrays
using HDF5
using Random
using PDMats
using DifferentialEquations
using SciMLBase
using ParticleDA

Base.@kwdef struct Lorenz63ModelParameters{S <: Real, T <: Real}
    σ::S = 10.
    ρ::S = 28.
    β::S = 8. / 3.
    time_step::S = 0.1
    observed_indices::Union{UnitRange{Int}, StepRange{Int, Int}, Vector{Int}} = 1:3
    initial_state_std::Union{S, Vector{S}} = 0.05
    state_noise_std::Union{S, Vector{S}} = 0.05
    observation_noise_std::Union{T, Vector{T}} = 2.
end

function get_params(
    P::Type{Lorenz63ModelParameters{S, T}}, model_params_dict::Dict
) where {S <: Real, T <: Real}
    return P(; (; (Symbol(k) => v for (k, v) in model_params_dict)...)...)
end

struct Lorenz63Model{S <: Real, T <: Real}
    parameters::Lorenz63ModelParameters{S, T}
    integrators::Vector{<:SciMLBase.AbstractODEIntegrator}
    initial_state_distribution::MvNormal{S}
    state_noise_distribution::MvNormal{S}
    observation_noise_distribution::MvNormal{T}
end

function update_time_derivative!(
    du_dt::Vector{S}, u::Vector{S}, parameters::Lorenz63ModelParameters{S, T}, t::U
) where {S <: Real, T <: Real, U <: Real}
    du_dt[1] = parameters.σ * (u[2] - u[1])
    du_dt[2] = u[1] * (parameters.ρ - u[3]) - u[2]
    du_dt[3] = u[1] * u[2] - parameters.β * u[3]
end

function init(parameters_dict::Dict; S::Type{<:Real}=Float64, T::Type{<:Real}=Float64)
    parameters = get_params(Lorenz63ModelParameters{S, T}, parameters_dict)
    time_span = (0, parameters.time_step)
    integrators = [
        DifferentialEquations.init(
            ODEProblem(update_time_derivative!, u, time_span, parameters), 
            Tsit5();
            save_everystep=false
        ) 
        for u in eachcol(Matrix{S}(undef, 3, nthreads()))
    ]
    state_dimension = 3
    observation_dimension = length(parameters.observed_indices)
    return Lorenz63Model(
        parameters,
        integrators,
        (
            MvNormal(m, isa(s, Vector) ? PDiagMat(s.^2) : ScalMat(length(m), s.^2))
            for (m, s) in (
                (Ones{S}(state_dimension), parameters.initial_state_std), 
                (Zeros{S}(state_dimension), parameters.state_noise_std), 
                (Zeros{T}(observation_dimension), parameters.observation_noise_std), 
            )
        )...
    )
end

ParticleDA.get_state_dimension(::Lorenz63Model) = 3
ParticleDA.get_observation_dimension(model::Lorenz63Model) = length(
    model.parameters.observed_indices
)
ParticleDA.get_state_eltype(::Lorenz63Model{S, T}) where {S, T} = S
ParticleDA.get_observation_eltype(::Lorenz63Model{S, T}) where {S, T} = T

function ParticleDA.sample_initial_state!(
    state::AbstractVector{T},
    model::Lorenz63Model{S, T}, 
    rng::Random.AbstractRNG,
) where {S, T}
    rand!(rng, model.initial_state_distribution, state)
end

function ParticleDA.update_state_deterministic!(
    state::AbstractVector{T}, 
    model::Lorenz63Model{S, T}, 
    time_index::Int,
) where {S, T}
    reinit!(model.integrators[threadid()], state)
    step!(model.integrators[threadid()], model.parameters.time_step, true)
    state .= model.integrators[threadid()].u
end

function ParticleDA.update_state_stochastic!(
    state::AbstractVector{T}, 
    model::Lorenz63Model{S, T}, 
    rng::Random.AbstractRNG,
) where {S, T}
    rand!(rng, state + model.state_noise_distribution, state)
end

function ParticleDA.sample_observation_given_state!(
    observation::AbstractVector{T},
    state::AbstractVector{S}, 
    model::Lorenz63Model{S, T}, 
    rng::Random.AbstractRNG,
) where {S <: Real, T <: Real}
    rand!(
        rng,
        view(state, model.parameters.observed_indices) 
        + model.observation_noise_distribution,
        observation
    )
end

function ParticleDA.get_log_density_observation_given_state(
    observation::AbstractVector{T}, state::AbstractVector{S}, model::Lorenz63Model{S, T}
) where {S <: Real, T <: Real}
    return logpdf(
        view(state, model.parameters.observed_indices) 
        + model.observation_noise_distribution,
        observation
    )
end

function ParticleDA.write_model_metadata(file::HDF5.File, model::Lorenz63Model)
    group_name = "parameters"
    if !haskey(file, group_name)
        group = create_group(file, group_name)
        for field in fieldnames(typeof(model.parameters))
            value = getfield(model.parameters, field)
            attributes(group)[string(field)] = (
                isa(value, AbstractVector) ? collect(value) : value
            )
        end
    else
        @warn "Write failed, group $group_name already exists in  $(file.filename)!"
    end
end

function ParticleDA.get_observation_mean_given_state!(
    observation_mean::AbstractVector{T},
    state::AbstractVector{S},
    model::Lorenz63Model{S, T}
) where {S <: Real, T <: Real}
    observation_mean .= view(state, model.parameters.observed_indices)
end

function ParticleDA.get_covariance_state_noise(model::Lorenz63Model)
    return model.state_noise_distribution.Σ
end

function ParticleDA.get_covariance_state_noise(model::Lorenz63Model, i::Int, j::Int)
    return model.state_noise_distribution.Σ[i, j]
end

function ParticleDA.get_covariance_observation_noise(model::Lorenz63Model)
    return model.observation_noise_distribution.Σ
end

function ParticleDA.get_covariance_observation_noise(
    model::Lorenz63Model, i::Int, j::Int
)
    return model.observation_noise_distribution.Σ[i, j]
end

function ParticleDA.get_covariance_state_observation_given_previous_state(
    model::Lorenz63Model, i::Int, j::Int
)
    return model.state_noise_distribution.Σ[i, model.parameters.observed_indices[j]]
end

function ParticleDA.get_covariance_observation_observation_given_previous_state(
    model::Lorenz63Model, i::Int, j::Int
)
    return (
        model.state_noise_distribution.Σ[
            model.parameters.observed_indices[i], model.parameters.observed_indices[j]
        ]
        + model.observation_noise_distribution.Σ[i, j]
    )
end

function ParticleDA.get_state_indices_correlated_to_observations(model::Lorenz63Model)
    return model.parameters.observed_indices
end

end