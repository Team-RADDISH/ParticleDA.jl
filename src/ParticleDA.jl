module ParticleDA

using Random
using Distributions
using Statistics
using MPI
using Base.Threads
using YAML
using HDF5
using TimerOutputs
using EllipsisNotation
using LinearAlgebra
using PDMats
using StructArrays

export run_particle_filter, simulate_observations_from_model, BootstrapFilter, OptimalFilter

include("params.jl")
include("io.jl")

using .Default_params

# Functions to extend in the model - required for all filters

"""
    ParticleDA.get_state_dimension(model_data) -> Integer
    
Return the positive integer dimension of the state vector which is assumed to be fixed
for all time steps.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function get_state_dimension end

"""
    ParticleDA.get_observation_dimension(model_data) -> Integer
    
Return the positive integer dimension of the observation vector which is assumed to be
fixed for all time steps.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function get_observation_dimension end

"""
    ParticleDA.get_state_eltype(model_data) -> Type

Return the element type of the state vector which is assumed to be fixed for all time
steps.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function get_state_eltype end

"""
    ParticleDA.get_observation_eltype(model_data) -> Type

Return the element type of the observation vector which is assumed to be fixed for all
time steps.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function get_observation_eltype end

"""
    ParticleDA.sample_initial_state!(state, model_data, rng)
    
Sample value for state vector from its initial distribution for model described by 
`model_data` using random number generator `rng` to generate random draws and writing
to `state` argument. 

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function sample_initial_state! end

"""
    ParticleDA.update_state_deterministic!(state, model_data, time_index)

Apply the deterministic component of the state time update at discrete time index 
`time_index` for the model described by `model_data` for the state vector `state`
writing the updated state back to the `state` argument.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function update_state_deterministic! end

"""
    ParticleDA.update_state_stochastic!(state, model_data, rng)

Apply the stochastic component of the state time update for the model described by
`model_data` for the state vector `state`, using random number generator `rng` to
generate random draws and writing the updated state back to the `state` argument.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function update_state_stochastic! end

"""
    ParticleDA.sample_observation_given_state!(observation, state, model_data, rng)

Simulate noisy observations of the state `state` of model described by `model_data`
and write to `observation` array using `rng` to generate any random draws.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function sample_observation_given_state! end

"""
    ParticleDA.get_log_density_observation_given_state(
        observation, state, model_data
    ) -> Real
    
Return the logarithm of the probability density of an observation vector `observation`
given a state vector `state` for the model associated with `model_data`. Any additive 
terms that are constant with respect to the state may be neglected.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function get_log_density_observation_given_state end

"""
    ParticleDA.write_model_metadata(file::HDF5.File, model_data)

Write metadata for with the model described by `model_data` to the HDF5 file `file`.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function write_model_metadata end

# Functions to extend in the model - required only for optimal proposal filter

"""
    ParticleDA.get_observation_mean_given_state!(observation_mean, state, model_data)
    
Compute the mean of the multivariate normal distribution on the observations given
the current state and write to the first argument.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`. Only required for filtering conditionally Gaussian models with 
the optimal proposal filter implementation in [`OptimalFilter`](@ref).
"""
function get_observation_mean_given_state! end

"""
    ParticleDA.get_covariance_state_noise(model_data, i, j) -> Real

Return covariance `cov(U[i], U[j])` between components of the zero-mean Gaussian state 
noise vector `U`.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`. Only required for filtering conditionally Gaussian models with 
the optimal proposal filter implementation in [`OptimalFilter`](@ref).
"""
function get_covariance_state_noise end

"""
    ParticleDA.get_covariance_observation_noise(model_data, i, j) -> Real

Return covariance `cov(V[i], V[j])` between components of the zero-mean Gaussian 
observation noise vector `V`.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`. Only required for filtering conditionally Gaussian models with 
the optimal proposal filter implementation in [`OptimalFilter`](@ref).
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

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`. Only required for filtering conditionally Gaussian models with 
the optimal proposal filter implementation in [`OptimalFilter`](@ref).
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

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`. Only required for filtering conditionally Gaussian models with 
the optimal proposal filter implementation in [`OptimalFilter`](@ref).
"""
function get_covariance_observation_observation_given_previous_state end

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
    ParticleDA.get_covariance_state_noise(model_data) -> AbstractPDMat

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
    ParticleDA.get_covariance_state_observation_given_previous_state(
        model_data
    ) -> AbstractMatrix
    
Return the covariance matrix `cov(X, Y)` between the state vector `X = F(x) + U` and 
observation vector `Y = H * X + V` where `H` is the linear  observation operator, `F` 
the (potentially non-linear) forward operator describing the  deterministic 
state dynamics, `U` is a zero-mean Gaussian state noise vector, `V` is a 
zero-mean Gaussian observation noise vector and `x` is the state at the previous 
observation time. The indices `i` here are those returned by 
[`get_state_indices_correlated_to_observations`](@ref) which can be used to avoid
computing and storing blocks of `cov(X, Y)` which will always be zero. 
"""
function get_covariance_state_observation_given_previous_state(model_data)
    state_indices = get_state_indices_correlated_to_observations(model_data)
    observation_dimension = get_observation_dimension(model_data)
    cov = Matrix{get_state_eltype(model_data)}(
        undef, length(state_indices), observation_dimension
    )
    for (i, state_index) in enumerate(state_indices)
        for j in 1:observation_dimension
            cov[i, j] = get_covariance_state_observation_given_previous_state(
                model_data, state_index, j
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

# Additional IO methods for models. These may be optionally extended by the user for a 
# specific `model_data` type, for example to write out arrays in a more useful format.

time_index_to_hdf5_key(time_index::Int) = "t" * lpad(string(time_index), 4, "0")
hdf5_key_to_time_index(key::String) = parse(Int, key[2:end])

function write_array(
    group::HDF5.Group,
    dataset_name::String,
    array::AbstractArray,
    dataset_attributes::Union{Dict{String, Any}, Nothing}=nothing
)
    if !haskey(group, dataset_name)
        group[dataset_name] = array
        if !isnothing(dataset_attributes)
            for (key, value) in pairs(dataset_attributes)
                attributes(group[dataset_name])[key] = value
            end
        end
    else
        @warn "Write failed, dataset $dataset_name already exists in $group"
    end
end

"""
    ParticleDA.write_observation(
        file::HDF5.File,
        observation::AbstractVector,
        time_index::Int,
        model_data
    )

Write the observations at time index `time_index` represented by the vector
`observation` to the HDF5 file `file` for the model represented by `model_data`.
"""
function write_observation(
    file::HDF5.File, observation::AbstractVector, time_index::Int, model_data
)
    time_stamp = time_index_to_hdf5_key(time_index)
    group, _ = create_or_open_group(file, "observations")
    attributes = Dict("Description" => "Observations", "Time index" => time_index)
    write_array(group, time_stamp, observation, attributes)
end

"""
    ParticleDA.write_state(
        file::HDF5.File,
        state::AbstractVector{T},
        time_index::Int,
        group_name::String,
        model_data
    )

Write the model state at time index `time_index` represented by the vector `state` to 
the HDF5 file `file` with `group_name` for the model represented by `model_data`.
"""
function write_state(
    file::HDF5.File,
    state::AbstractVector,
    time_index::Int,
    group_name::String,
    model_data
)
    time_stamp = time_index_to_hdf5_key(time_index)
    group, _ = create_or_open_group(file, group_name)
    attributes = Dict("Description" => "Model state", "Time index" => time_index)
    write_array(group, time_stamp, state, attributes)
end

"""
    ParticleDA.write_weights(
        file::HDF5.File,
        weights::AbstractVector{T},
        time_index::Int,
        model_data
    )

Write the particle weights at time index `time_index` represented by the vector 
`weights` to the HDF5 file `file` for the model represented by `model_data`.
"""
function write_weights(
    file::HDF5.File,
    weights::AbstractVector,
    time_index::Int,
    model_data
)
    time_stamp = time_index_to_hdf5_key(time_index)
    group, _ = create_or_open_group(file, "weights")
    attributes = Dict("Description" => "Particle weights", "Time index" => time_index)
    write_array(group, time_stamp, weights, attributes)
end

"""
    ParticleDA.write_snapshot(
        output_filename, model_data, filter_data, states, time_index, save_states
    )

Write a snapshot of the model and filter states to the HDF5 file `output_filename` for
the model and filters described by `model_data` and `filter_data` respectively at time
index `time_index`, optionally saving the current ensemble of state particles
represented by the two-dimensional array `states` (first axis state component, second
particle index) if `save_states == true`. `time_index == 0` corresponds to the initial
model and filter states before any updates and non-time dependent model data will be
written out when called with this value of `time_index`.
"""
function write_snapshot(
    output_filename::AbstractString,
    model_data,
    filter_data::NamedTuple,
    states::AbstractMatrix{T},
    time_index::Int,
    save_states::Bool,
) where T
    println("Writing output at timestep = ", time_index)
    h5open(output_filename, "cw") do file
        time_index == 0 && write_model_metadata(file, model_data)
        for name in keys(filter_data.unpacked_statistics)
            write_state(
                file, 
                filter_data.unpacked_statistics[name],
                time_index,
                "state_$name",
                model_data
            )
        end
        write_weights(file, filter_data.weights, time_index, model_data)
        if save_states
            println("Writing particle states at timestep = ", time_index)
            for (index, state) in enumerate(eachcol(states))
                group_name = "state_particle_$index"
                write_state(file, state, time_index, group_name, model_data)
            end
        end
    end
end

abstract type AbstractSummaryStat{T} end
abstract type AbstractSumReductionSummaryStat{T} <: AbstractSummaryStat{T} end
abstract type AbstractCustomReductionSummaryStat{T} <: AbstractSummaryStat{T} end

struct NaiveMeanSummaryStat{T} <: AbstractSumReductionSummaryStat{T}
    sum::T
    n::Int
end

compute_statistic(::Type{<:NaiveMeanSummaryStat}, x::AbstractVector) = (
    NaiveMeanSummaryStat(sum(x), length(x))
)

statistic_names(::Type{<:NaiveMeanSummaryStat}) = (:avg,)

unpack(S::NaiveMeanSummaryStat) = (; avg=S.sum / S.n)

struct NaiveMeanAndVarSummaryStat{T} <: AbstractSumReductionSummaryStat{T}
    sum::T
    sum_sq::T
    n::Int
end

compute_statistic(::Type{<:NaiveMeanAndVarSummaryStat}, x::AbstractVector) = (
    NaiveMeanAndVarSummaryStat(sum(x), sum(abs2, x), length(x))
)

statistic_names(::Type{<:NaiveMeanAndVarSummaryStat}) = (:avg, :var)

unpack(S::NaiveMeanAndVarSummaryStat) = (
    avg=S.sum / S.n, var=(S.sum_sq - S.sum^2 / S.n) / (S.n - 1)
)

function init_statistics(
    S::Type{<:AbstractSumReductionSummaryStat}, T::Type, dimension::Int
)
    return StructVector{S{T}}(undef, dimension)
end

function update_statistics!(
    statistics::StructVector{S}, states::AbstractMatrix{T}, master_rank::Int,
) where {T, S <: AbstractSumReductionSummaryStat{T}}
    Threads.@threads for i in eachindex(statistics)
        statistics[i] = compute_statistic(S, selectdim(states, 1, i))
    end
    for name in fieldnames(S)
        MPI.Reduce!(getproperty(statistics, name), +, master_rank, MPI.COMM_WORLD)
    end
end

function unpack_statistics!(
    unpacked_statistics::NamedTuple, statistics::StructVector{S}
) where {T, S <: AbstractSumReductionSummaryStat{T}}
        Threads.@threads for i in eachindex(statistics)
        for (name, val) in pairs(unpack(statistics[i]))
            unpacked_statistics[name][i] = val
        end
    end     
end

struct MeanSummaryStat{T} <: AbstractCustomReductionSummaryStat{T}
    avg::T
    n::Int
end

compute_statistic(::Type{<:MeanSummaryStat}, x::AbstractVector) = (
    MeanSummaryStat(mean(x), length(x))
)

statistic_names(::Type{<:MeanSummaryStat}) = (:avg,)

function combine_statistics(s1::MeanSummaryStat, s2::MeanSummaryStat)
    n = s1.n + s2.n
    m = (s1.avg * s1.n + s2.avg * s2.n) / n
    MeanSummaryStat(m, n)
end

struct MeanAndVarSummaryStat{T} <: AbstractCustomReductionSummaryStat{T}
    avg::T
    var::T
    n::Int
end

function compute_statistic(::Type{<:MeanAndVarSummaryStat}, x::AbstractVector)
    m = mean(x)
    v = varm(x, m, corrected=true)
    n = length(x)
    MeanAndVarSummaryStat(m, v, n)
end

statistic_names(::Type{<:MeanAndVarSummaryStat}) = (:avg, :var)

function combine_statistics(s1::MeanAndVarSummaryStat, s2::MeanAndVarSummaryStat)
    n = s1.n + s2.n
    m = (s1.avg * s1.n + s2.avg * s2.n) / n
    # Calculate pooled unbiased sample variance of two groups.
    # From https://stats.stackexchange.com/q/384951
    # Can be found in https://www.tandfonline.com/doi/abs/10.1080/00031305.2014.966589
    v = (
        (s1.n - 1) * s1.var 
        + (s2.n - 1) * s2.var 
        + s1.n * s2.n / n * (s2.avg - s1.avg)^2
    ) / (n - 1)
    MeanAndVarSummaryStat(m, v, n)
end

function init_statistics(
    S::Type{<:AbstractCustomReductionSummaryStat}, T::Type, dimension::Int
)
    return Array{S{T}}(undef, dimension)
end

function update_statistics!(
    statistics::AbstractVector{S}, states::AbstractMatrix{T}, master_rank::Int,
) where {T, S <: AbstractCustomReductionSummaryStat{T}}
    Threads.@threads for i in eachindex(statistics)
        statistics[i] = compute_statistic(S, selectdim(states, 1, i))
    end
    MPI.Reduce!(statistics, combine_statistics, master_rank, MPI.COMM_WORLD)
end

function unpack_statistics!(
    unpacked_statistics::NamedTuple, statistics::AbstractVector{S}
) where {T, S <: AbstractCustomReductionSummaryStat{T}}
    Threads.@threads for i in eachindex(statistics)
        for name in statistic_names(S)
            unpacked_statistics[name][i] = getfield(statistics[i], name)
        end
    end     
end

"""
    ParticleFilter

Abstract type for the particle filter to use.  Currently used subtypes are:
* [`BootstrapFilter`](@ref)
* [`OptimalFilter`](@ref)
"""
abstract type ParticleFilter end

"""
    ParticleDA.init_filter(filter_params, model_data, nprt_per_rank, ::T) -> NamedTuple

Initialise any data structures required by filter of type `T`, with filtering specific
parameters specified by `filter_params`, state space model to perform filtering with
described by `model_data` and `nprt_per_rank` particles per MPI rank.

New filter implementations should extend this method specifying `T` as the appropriate
singleton type for the new filter.
"""
function init_filter end

"""
    ParticleDA.sample_proposal_and_compute_log_weights!(
        states, log_weights, observation, model_data, filter_data, ::T, rng
    )
    
Sample new values for two-dimensional array of state vectors `states` from proposal
distribution writing in-place to `states` array and compute logarithm of unnormalized 
particle weights writing to `log_weights` given observation vector `observation`, with
state space model described by `model_data`, named tuple of filter specific data
structures `filter_data`, filter type `T` and random number generator `rng` used to
generate any random draws.

New filter implementations should extend this method specifying `T` as the appropriate
singleton type for the new filter.
"""
function sample_proposal_and_compute_log_weights! end

"""
    BootstrapFilter()

Instantiate the singleton type `BootstrapFilter`.  This can be used as argument
of [`run_particle_filter`](@ref) to select the bootstrap filter.
"""
struct BootstrapFilter <: ParticleFilter end
struct OptimalFilter <: ParticleFilter end

# Initialize arrays used by the filter
function init_filter(
    filter_params::FilterParameters, 
    model_data, 
    nprt_per_rank::Int, 
    ::Type{BootstrapFilter}, 
    summary_stat_type::Type{<:AbstractSummaryStat}
)
    state_dimension = get_state_dimension(model_data)
    state_eltype = get_state_eltype(model_data)
    if MPI.Comm_rank(MPI.COMM_WORLD) == filter_params.master_rank
        weights = Vector{state_eltype}(undef, filter_params.nprt)
    else
        weights = Vector{state_eltype}(undef, nprt_per_rank)
    end
    resampling_indices = Vector{Int}(undef, filter_params.nprt)
    statistics = init_statistics(summary_stat_type, state_eltype, state_dimension)
    unpacked_statistics = (;
        (
            name => Array{state_eltype}(undef, state_dimension) 
            for name in statistic_names(summary_stat_type)
        )...
    )
    # Memory buffer used during copy of the states
    copy_buffer = Array{state_eltype, 2}(undef, state_dimension, nprt_per_rank)
    return (; weights, resampling_indices, statistics, unpacked_statistics, copy_buffer)
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
function init_offline_matrices(model_data)
    return OfflineMatrices(
        get_covariance_state_observation_given_previous_state(model_data), 
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

# Initialize arrays used by the filter
function init_filter(
    filter_params::FilterParameters, 
    model_data, 
    nprt_per_rank::Int, 
    ::Type{OptimalFilter}, 
    summary_stat_type::Type{<:AbstractSummaryStat}
)
    filter_data = init_filter(
        filter_params, model_data, nprt_per_rank, BootstrapFilter, summary_stat_type
    )
    offline_matrices = init_offline_matrices(model_data)
    online_matrices = init_online_matrices(model_data, nprt_per_rank)
    observation_dimension = get_observation_dimension(model_data)
    observation_eltype = get_observation_eltype(model_data)
    observation_mean_buffer = Array{observation_eltype, 2}(
        undef, observation_dimension, nthreads()
    )
    return (; filter_data..., offline_matrices, online_matrices, observation_mean_buffer)
end

function sample_proposal_and_compute_log_weights!(
    states::AbstractMatrix,
    log_weights::AbstractVector,
    observation::AbstractVector,
    time_index::Integer,
    model_data,
    ::NamedTuple,
    ::Type{BootstrapFilter},
    rng::Random.AbstractRNG,
)
    num_particle = size(states, 2)
    Threads.@threads :static for p in 1:num_particle
        update_state_deterministic!(selectdim(states, 2, p), model_data, time_index)
        update_state_stochastic!(selectdim(states, 2, p), model_data, rng)
        log_weights[p] = get_log_density_observation_given_state(
            observation, selectdim(states, 2, p), model_data
        )
    end
end

function get_log_density_observation_given_previous_state(
    observation::AbstractVector{T},
    pre_noise_state::AbstractVector{S},
    model_data,
    filter_data::NamedTuple,
) where {S, T}
    observation_mean = view(filter_data.observation_mean_buffer, :, threadid())
    get_observation_mean_given_state!(observation_mean, pre_noise_state, model_data)
    return -invquad(
        filter_data.offline_matrices.cov_Y_Y, observation - observation_mean
    ) / 2 
end

# ldiv! not currently defined for PDMat so define here
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

function sample_proposal_and_compute_log_weights!(
    states::AbstractMatrix,
    log_weights::AbstractVector,
    observation::AbstractVector,
    time_index::Integer,
    model_data,
    filter_data::NamedTuple,
    ::Type{OptimalFilter},
    rng::Random.AbstractRNG,
)
    num_particle = size(states, 2)
    Threads.@threads :static for p in 1:num_particle
        update_state_deterministic!(selectdim(states, 2, p), model_data, time_index)
        # Particle weights for optimal proposal _do not_ depend on state noise values
        # therefore we calculate them using states after applying deterministic part of
        # time update but before adding state noise
        log_weights[p] = get_log_density_observation_given_previous_state(
            observation, selectdim(states, 2, p), model_data, filter_data
        )
        update_state_stochastic!(selectdim(states, 2, p), model_data, rng)
    end
    # Update to account for conditioning on observations can be performed using matrix-
    # matrix level 3 BLAS operations therefore perform outside of threaded loop over
    # particles 
    update_states_given_observations!(states, observation, model_data, filter_data, rng)
end

#
function normalized_exp!(weight::AbstractVector)

    weight .-= maximum(weight)
    @. weight = exp(weight)
    weight ./= sum(weight)

end

# Resample particles from given weights using Stochastic Universal Sampling
function resample!(
    resampled_indices::AbstractVector{Int}, 
    weights::AbstractVector{T}, 
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
) where T

    nprt = length(weights)
    nprt_inv = 1.0 / nprt
    k = 1

    weight_cdf = cumsum(weights)
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

function init_states(model_data, nprt_per_rank::Int, rng::AbstractRNG)
    state_el_type = ParticleDA.get_state_eltype(model_data)
    state_dimension = ParticleDA.get_state_dimension(model_data)
    states = Matrix{state_el_type}(undef, state_dimension, nprt_per_rank)
    Threads.@threads :static for p in 1:nprt_per_rank
        sample_initial_state!(selectdim(states, 2, p), model_data, rng)
    end
    return states
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

"""
    simulate_observations_from_model(init_model, input_file_path, output_file_path)
    
Simulate observations from the state space model initialised by the `init_model`
function with parameters specified by the `model` key in the input YAML file at 
`input_file_path` and save the simulated observation and state sequences to a HDF5 file
at `output_file_path`.

The input YAML file at `input_file_path` should have a `simulate_observations` key
with value a dictionary with keys `seed` and `n_time_step` corresponding to respectively
the number of time steps to generate observations for from the model and the seed to
use to initialise the state of the random number generator used to simulate the
observations. 
"""
function simulate_observations_from_model(
    init_model,
    input_file_path::String,
    output_file_path::String; 
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    input_dict = read_input_file(input_file_path)
    model_dict = get(input_dict, "model", Dict())
    model_data = init_model(model_dict)
    simulate_observations_dict = get(input_dict, "simulate_observations", Dict())
    n_time_step = get(simulate_observations_dict, "n_time_step", 1)
    seed = get(simulate_observations_dict, "seed", nothing)
    Random.seed!(rng, seed)
    h5open(output_file_path, "cw") do output_file
        return simulate_observations_from_model(
            model_data, n_time_step; output_file, rng
        )
    end
end

function simulate_observations_from_model(
    model_data, 
    num_time_step::Integer;
    output_file::Union{Nothing, HDF5.File}=nothing,
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    state = Vector{get_state_eltype(model_data)}(undef, get_state_dimension(model_data))
    observation_sequence = Matrix{get_observation_eltype(model_data)}(
        undef, get_observation_dimension(model_data), num_time_step
    )
    sample_initial_state!(state, model_data, rng)
    if !isnothing(output_file)
        write_state(output_file, state, 0, "state", model_data)
    end
    for (time_index, observation) in enumerate(eachcol(observation_sequence))
        update_state_deterministic!(state, model_data, time_index)
        update_state_stochastic!(state, model_data, rng)
        sample_observation_given_state!(observation, state, model_data, rng)
        if !isnothing(output_file)
            write_state(output_file, state, time_index, "state", model_data)
            write_observation(output_file, observation, time_index, model_data)
        end
    end
    return observation_sequence
end

function run_particle_filter(
    init_model, 
    filter_params::FilterParameters, 
    model_params_dict::Dict,
    observation_sequence::AbstractMatrix,
    filter_type::Type{<:ParticleFilter},
    summary_stat_type::Type{<:AbstractSummaryStat};
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)

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
    @timeit_debug timer "Model initialization" model_data = init_model(model_params_dict)
    
    @timeit_debug timer "State initialization" states = init_states(
        model_data, nprt_per_rank, rng
    )

    @timeit_debug timer "Filter initialization" filter_data = init_filter(
        filter_params, model_data, nprt_per_rank, filter_type, summary_stat_type
    )

    @timeit_debug timer "Summary statistics" update_statistics!(
        filter_data.statistics, states, filter_params.master_rank
    )

    # Write initial state (time = 0) + metadata
    if(filter_params.verbose && my_rank == filter_params.master_rank)
        @timeit_debug timer "IO" begin
            unpack_statistics!(
                filter_data.unpacked_statistics, filter_data.statistics
            )
            write_snapshot(
                filter_params.output_filename,
                model_data,
                filter_data,
                states,
                0,
                0 in filter_params.particle_save_time_indices,
            )
        end
    end

    for (time_index, observation) in enumerate(eachcol(observation_sequence))

        # Sample updated values for particles from proposal distribution and compute
        # unnormalized log weights for each particle in ensemble given observations
        # for current time step
        @timeit_debug timer "Proposals and weights" sample_proposal_and_compute_log_weights!(
            states, 
            @view(filter_data.weights[1:nprt_per_rank]),
            observation,
            time_index,
            model_data, 
            filter_data, 
            filter_type, 
            rng
        )

        # Gather weights to master rank and resample particles.
        # Doing MPI collectives in place to save memory allocations.
        # This style with if statmeents is recommended instead of MPI.Gather_in_place! which is a bit strange.
        # Note that only master_rank allocates memory for all particles. Other ranks only allocate
        # for their chunk of state.
        if my_rank == filter_params.master_rank
            @timeit_debug timer "MPI Gather" MPI.Gather!(
                MPI.IN_PLACE,
                UBuffer(filter_data.weights, nprt_per_rank),
                filter_params.master_rank,
                MPI.COMM_WORLD
            )
            @timeit_debug timer "Normalize weights" normalized_exp!(filter_data.weights)
            @timeit_debug timer "Resample" resample!(
                filter_data.resampling_indices, filter_data.weights, rng
            )

        else
            @timeit_debug timer "MPI Gather" MPI.Gather!(filter_data.weights,
                                                         nothing,
                                                         filter_params.master_rank,
                                                         MPI.COMM_WORLD)
        end

        # Broadcast resampled particle indices to all ranks
        MPI.Bcast!(filter_data.resampling_indices, filter_params.master_rank, MPI.COMM_WORLD)
    
        @timeit_debug timer "State Copy" copy_states!(
            states,
            filter_data.copy_buffer,
            filter_data.resampling_indices,
            my_rank,
            nprt_per_rank
        )
                                                      
        if filter_params.verbose
            @timeit_debug timer "Summary statistics" update_statistics!(
                filter_data.statistics, states, filter_params.master_rank
            )
        end

        if my_rank == filter_params.master_rank && filter_params.verbose

            @timeit_debug timer "IO" begin
                unpack_statistics!(
                    filter_data.unpacked_statistics, filter_data.statistics
                )
                write_snapshot(
                    filter_params.output_filename,
                    model_data,
                    filter_data,
                    states,
                    time_index,
                    time_index in filter_params.particle_save_time_indices,
                )
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
    
    if !filter_params.verbose
        # Do final update and unpack of statistics if not performed in filtering loop
        update_statistics!(
            filter_data.statistics, states, filter_params.master_rank
        )
        if my_rank == filter_params.master_rank
            unpack_statistics!(filter_data.unpacked_statistics, filter_data.statistics)
        end
    end

    return states, filter_data.unpacked_statistics
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

function read_observation_sequence(observation_file::HDF5.File)
    observation_group = observation_file["observations"]
    time_keys = sort(keys(observation_group), by=hdf5_key_to_time_index)
    @assert Set(map(hdf5_key_to_time_index, time_keys)) == Set(
        hdf5_key_to_time_index(time_keys[1]):hdf5_key_to_time_index(time_keys[end])
    ) "Observations in $observation_file_path are at non-contiguous time indices"
    observation = observation_group[time_keys[1]]
    observation_dimension = length(observation)
    observation_sequence = Matrix{eltype(observation)}(
        undef, observation_dimension, length(time_keys)
    )
    for (time_index, key) in enumerate(time_keys)
        observation_sequence[:, time_index] .= read(observation_group[key])
    end
    return observation_sequence
end 

"""
    run_particle_filter(
        init_model,
        input_file_path,
        observation_file_path,
        filter_type,
        summary_stat_type;
        rng
    )

Run particle filter. `init_model` is the function which initialise the model,
`input_file_path` is the path to the YAML file with the input parameters.
`observation_file_path` is the path to the HDF5 file containing the observation
sequence to perform filtering for. `filter_type` is the particle filter type to use.  
See [`ParticleFilter`](@ref) for the possible values. `summary_stat_type` is a type 
specifying the summary statistics of the particles to compute at each time step.
"""
function run_particle_filter(
    init_model,
    input_file_path::String,
    observation_file_path::String,
    filter_type::Type{<:ParticleFilter}=BootstrapFilter,
    summary_stat_type::Type{<:AbstractSummaryStat}=MeanAndVarSummaryStat;
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    MPI.Init()
    # Do I/O on rank 0 only and then broadcast
    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    if my_rank == 0
        input_dict = read_input_file(input_file_path)
        observation_sequence = h5open(
            read_observation_sequence, observation_file_path, "r"
        )
    else
        input_dict = nothing
        observation_sequence = nothing
    end
    input_dict = MPI.bcast(input_dict, 0, MPI.COMM_WORLD)
    observation_sequence = MPI.bcast(observation_sequence, 0, MPI.COMM_WORLD)
    filter_params = get_params(FilterParameters, get(input_dict, "filter", Dict()))
    if !isnothing(filter_params.seed)
        # Use a linear congruential generator to generate different seeds for each rank
        seed = UInt64(filter_params.seed)
        multiplier, increment = 0x5851f42d4c957f2d, 0x14057b7ef767814f
        for _ in 1:my_rank
            # As seed is UInt64 operations will be modulo 2^64
            seed = multiplier * seed + increment  
        end
        # Seed per-rank random number generator
        Random.seed!(rng, seed)
    end
    model_params_dict = get(input_dict, "model", Dict())
    return run_particle_filter(
        init_model, 
        filter_params, 
        model_params_dict,
        observation_sequence,
        filter_type,
        summary_stat_type; 
        rng
    )
end

end # module
