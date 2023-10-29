module Lorenz96

using Base.Threads
using Distributions
using FillArrays
using HDF5
using Random
using PDMats
using OrdinaryDiffEq
using SciMLBase
using ParticleDA


Base.@kwdef struct Lorenz96ModelParameters{S <: Real, T <: Real}
    F::S = 8.0
    time_step::S = 0.05
    N::Int = 40
    num_observed_indices::S = 10
    state_dimension::Int = 40
    observed_indices::Vector{Int} = collect(1:(state_dimension/num_observed_indices):state_dimension)
    initial_state_std::Union{S, Vector{S}} = 0.1
    state_noise_std::Union{S, Vector{S}} = 0.1
    observation_noise_std::Union{T, Vector{T}} = 0.1
    operator_type::String = "linear"
end

function get_params(
    P::Type{Lorenz96ModelParameters{S, T}}, model_params_dict::Dict
) where {S <: Real, T <: Real}
    return P(; (; (Symbol(k) => v for (k, v) in model_params_dict)...)...)
end

struct Lorenz96Model{S <: Real, T <: Real}
    parameters::Lorenz96ModelParameters{S, T}
    integrators::Vector{<:SciMLBase.AbstractODEIntegrator}
    initial_state_distribution::MvNormal{S}
    state_noise_distribution::MvNormal{S}
    observation_noise_distribution::MvNormal{T}
end

function update_time_derivative!(
    dx_dt::Vector{S}, x::Vector{S}, parameters::Lorenz96ModelParameters{S, T}, t::U
) where {S <: Real, T <: Real, U <: Real}

    for i in 1:parameters.N
        if i == 1
            dx_dt[i] = (x[i+1] - x[parameters.N-1])*x[parameters.N] - x[i] + parameters.F
        elseif i == 2
            dx_dt[i] = (x[i+1] - x[parameters.N])*x[i-1] - x[i] + parameters.F
        elseif i == parameters.N
            dx_dt[i] = (x[1] - x[i-2])*x[i-1] - x[i] + parameters.F
        else
            dx_dt[i] = (x[i+1] - x[i-2])x[i-1] - x[i] + parameters.F

        end
    end
end

function init(parameters_dict::Dict; S::Type{<:Real}=Float64, T::Type{<:Real}=Float64)
    parameters = get_params(Lorenz96ModelParameters{S, T}, parameters_dict)
    time_span = (0, parameters.time_step)
    integrators = [
        OrdinaryDiffEq.init(
            ODEProblem(update_time_derivative!, x, time_span, parameters), 
            Tsit5();
            save_everystep=false
        ) 
        for x in eachcol(Matrix{S}(undef, 40, nthreads()))
    ]
    state_dimension = parameters.state_dimension
    observation_dimension = length(parameters.observed_indices)

    return Lorenz96Model(
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

ParticleDA.get_state_dimension(::Lorenz96Model) = 40
ParticleDA.get_observation_dimension(model::Lorenz96Model) = length(
    model.parameters.observed_indices
)
ParticleDA.get_state_eltype(::Lorenz96Model{S, T}) where {S, T} = S
ParticleDA.get_observation_eltype(::Lorenz96Model{S, T}) where {S, T} = T

function ParticleDA.sample_initial_state!(
    state::AbstractVector{T},
    model::Lorenz96Model{S, T}, 
    rng::Random.AbstractRNG,
) where {S, T}
    rand!(rng, model.initial_state_distribution, state)
end

function ParticleDA.update_state_deterministic!(
    state::AbstractVector{T}, 
    model::Lorenz96Model{S, T}, 
    time_index::Int,
) where {S, T}
    reinit!(model.integrators[threadid()], state)
    step!(model.integrators[threadid()], model.parameters.time_step, true)
    state .= model.integrators[threadid()].u
end

function ParticleDA.update_state_stochastic!(
    state::AbstractVector{T}, 
    model::Lorenz96Model{S, T}, 
    rng::Random.AbstractRNG,
) where {S, T}
    rand!(rng, state + model.state_noise_distribution, state)
end


function observation_operator!(
    observation::AbstractVector{T},
    operator_type::String
) where {T <: Real}
    if operator_type == "log"
        observation .= log.(abs.(observation))
    elseif operator_type == "square"
        observation .= (observation).^2
    else
        observation .= observation
    end
end


function ParticleDA.sample_observation_given_state!(
    observation::AbstractVector{T},
    state::AbstractVector{S}, 
    model::Lorenz96Model{S, T}, 
    rng::Random.AbstractRNG,
) where {S <: Real, T <: Real}

    observation .= view(state, model.parameters.observed_indices)

    rand!(
        rng,
        observation_operator!(observation, model.parameters.operator_type)
        + model.observation_noise_distribution,
        observation
    )

end

function ParticleDA.get_log_density_observation_given_state(
    observation::AbstractVector{T}, state::AbstractVector{S}, model::Lorenz96Model{S, T}
) where {S <: Real, T <: Real}

    obs_given_state = (view(state, model.parameters.observed_indices) + model.observation_noise_distribution)
    observation_operator!(obs_given_state.μ, model.parameters.operator_type)

    return logpdf(
        obs_given_state,
        observation
    )
end

function ParticleDA.write_model_metadata(file::HDF5.File, model::Lorenz96Model)
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

function ParticleDA.get_covariance_state_noise(model::Lorenz96Model)
    return model.state_noise_distribution.Σ
end

function ParticleDA.get_covariance_state_noise(model::Lorenz96Model, i::Int, j::Int)
    return model.state_noise_distribution.Σ[i, j]
end

function ParticleDA.get_covariance_observation_noise(model::Lorenz96Model)
    return model.observation_noise_distribution.Σ
end

function ParticleDA.get_covariance_observation_noise(
    model::Lorenz96Model, i::Int, j::Int
)
    return model.observation_noise_distribution.Σ[i, j]
end

function ParticleDA.get_covariance_state_observation_given_previous_state(
    model::Lorenz96Model, i::Int, j::Int
)
    return model.state_noise_distribution.Σ[i, model.parameters.observed_indices[j]]
end

function ParticleDA.get_covariance_observation_observation_given_previous_state(
    model::Lorenz96Model, i::Int, j::Int
)
    return (
        model.state_noise_distribution.Σ[
            model.parameters.observed_indices[i], model.parameters.observed_indices[j]
        ]
        + model.observation_noise_distribution.Σ[i, j]
    )
end

function ParticleDA.get_state_indices_correlated_to_observations(model::Lorenz96Model)
    return model.parameters.observed_indices
end

end
