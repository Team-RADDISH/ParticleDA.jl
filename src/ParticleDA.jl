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

export run_particle_filter, BootstrapFilter, OptimalFilter

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
    ParticleDA.update_state_deterministic!(state, model_data)

Apply the deterministic component of the state time update for the model described by
`model_data` for the state vector `state`, writing the updated state back to the
`state` argument.

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
    ParticleDA.write_snapshot(
        output_filename, model_data, states, state_mean, state_var, weights, time_step
    )

Write a snapshot of the particle ensemble to the HDF5 file `output_filename` for the
model described by `model_data`. `states` is a two-dimensional array containing the
current state particle values (first axis state component, second particle index), 
`state_mean` is a one-dimensional array containing the current estimate of the mean
of the state given the observations up to the current time step, `state_var` is a 
one-dimensional array containing the current estimate of the variance of the state given
the observations up to the current time step, `weights` is a one-dimensional array of
the normalized weights associated with each state particle (these weights together with
the state vectors in `states` define an empirical distribution which approximates the
distribution of the model state at the current time step given the observations up to
that time step) and `time_step` is an integer index indicating the current time step
with `time_step == 0` corresponding to the initial model state before any updates.

This method is intended to be extended by the user with the above signature, specifying
the type of `model_data`.
"""
function write_snapshot end

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
    filter_params::FilterParameters, model_data, nprt_per_rank::Int, ::BootstrapFilter
)
    state_dimension = get_state_dimension(model_data)
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
    return (; weights, resampling_indices, statistics, avg_arr, var_arr, copy_buffer)
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

# Initialize arrays used by the filter
function init_filter(
    filter_params::FilterParameters, model_data, nprt_per_rank::Int, ::OptimalFilter
)
    filter_data = init_filter(filter_params, model_data, nprt_per_rank, BootstrapFilter())
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
    model_data,
    ::NamedTuple,
    ::BootstrapFilter,
    rng::Random.AbstractRNG,
)
    num_particle = size(states, 2)
    Threads.@threads :static for p in 1:num_particle
        update_state_deterministic!(selectdim(states, 2, p), model_data)
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
    model_data,
    filter_data::NamedTuple,
    ::OptimalFilter,
    rng::Random.AbstractRNG,
)
    num_particle = size(states, 2)
    Threads.@threads :static for p in 1:num_particle
        update_state_deterministic!(selectdim(states, 2, p), model_data)
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

    #TODO: Do we need to sort state by weight here?

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
    simulate_observations_from_model(init_model, path_to_input_file::String)

Initialise the truth model and extract observations. `init_model` is the function which initialise the model,
`path_to_input_file` is the path to the YAML file with the truth model input parameters. See [`ParticleFilter`](@ref) for
the possible values.
"""
function simulate_observations_from_model(
    init_model, 
    path_to_input_file::String,
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    user_input_dict = read_input_file(path_to_input_file)
    filter_params = get_params(FilterParameters, get(user_input_dict, "filter", Dict()))
    model_params_dict = get(user_input_dict, "model", Dict())
    model_data = init_model(model_params_dict)

    return simulate_observations_from_model(
        model_data, 
        filter_params.n_time_step, 
        rng
    )
end

function simulate_observations_from_model(
    model_data, num_time_step::Integer, rng::AbstractRNG
)
    state = Vector{get_state_eltype(model_data)}(undef, get_state_dimension(model_data))
    observation_sequence = Matrix{get_observation_eltype(model_data)}(
        undef, get_observation_dimension(model_data), num_time_step
    )
    sample_initial_state!(state, model_data, rng)
    for observation in eachcol(observation_sequence)
        update_state_deterministic!(state, model_data)
        update_state_stochastic!(state, model_data, rng)
        sample_observation_given_state!(observation, state, model_data, rng)
    end
    return observation_sequence 
end

function run_particle_filter(
    init_model, 
    filter_params::FilterParameters, 
    model_params_dict::Dict, 
    filter_type;
    observation_sequence=nothing,
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
    
    if isnothing(observation_sequence)
        @timeit_debug timer "Simulating observations" begin
            if my_rank == filter_params.master_rank
                if filter_params.truth_param_file != ""
                    observation_sequence = simulate_observations_from_model(
                        init_model, filter_params.truth_param_file, rng
                    )
                else
                    observation_sequence = simulate_observations_from_model(
                    model_data, filter_params.n_time_step, rng
                    )
                end
            end
            observation_sequence = MPI.bcast(
                observation_sequence, filter_params.master_rank, MPI.COMM_WORLD
            )
        end 
    end
    
    @timeit_debug timer "State initialization" states = init_states(
        model_data, nprt_per_rank, rng
    )

    @timeit_debug timer "Filter initialization" filter_data = init_filter(
        filter_params, model_data, nprt_per_rank, filter_type
        )

    @timeit_debug timer "Mean and Var" get_mean_and_var!(
        filter_data.statistics, states, filter_params.master_rank
    )

    # Write initial state (time = 0) + metadata
    if(filter_params.verbose && my_rank == filter_params.master_rank)
        @timeit_debug timer "IO" begin
            unpack_statistics!(
                filter_data.avg_arr, filter_data.var_arr, filter_data.statistics
            )
            write_snapshot(
                filter_params.output_filename,
                model_data,
                states,
                filter_data.avg_arr,
                filter_data.var_arr,
                filter_data.weights,
                0
            )
        end
    end

    for (time_step, observation) in enumerate(eachcol(observation_sequence))

        # Sample updated values for particles from proposal distribution and compute
        # unnormalized log weights for each particle in ensemble given observations
        # for current time step
        @timeit_debug timer "Proposals and weights" sample_proposal_and_compute_log_weights!(
            states, 
            @view(filter_data.weights[1:nprt_per_rank]),
            observation, 
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

            @timeit_debug timer "Mean and Var" get_mean_and_var!(
                filter_data.statistics, states, filter_params.master_rank
            )
            
        end

        if my_rank == filter_params.master_rank && filter_params.verbose

            @timeit_debug timer "IO" begin
                unpack_statistics!(
                    filter_data.avg_arr, filter_data.var_arr, filter_data.statistics
                )
                write_snapshot(
                    filter_params.output_filename,
                    model_data,
                    states,
                    filter_data.avg_arr,
                    filter_data.var_arr,
                    filter_data.weights,
                    time_step,
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

    unpack_statistics!(filter_data.avg_arr, filter_data.var_arr, filter_data.statistics)

    return states, filter_data.avg_arr, filter_data.var_arr
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
    run_particle_filter(init_model, path_to_input_file::String, filter_type::ParticleFilter)

Run the particle filter. `init_model` is the function which initialise the model,
`path_to_input_file` is the path to the YAML file with the input parameters.
`filter_type` is the particle filter to use.  See [`ParticleFilter`](@ref) for
the possible values.
"""
function run_particle_filter(
    init_model,
    path_to_input_file::String,
    filter_type::ParticleFilter;
    observation_sequence=nothing,
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    MPI.Init()
    # Do I/O on rank 0 only and then broadcast params
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0
        user_input_dict = read_input_file(path_to_input_file)
    else
        user_input_dict = nothing
    end
    user_input_dict = MPI.bcast(user_input_dict, 0, MPI.COMM_WORLD)
    return run_particle_filter(
        init_model, 
        user_input_dict, 
        filter_type; 
        observation_sequence, 
        rng
    )
end

"""
    run_particle_filter(init_model, user_input_dict::Dict, filter_type::ParticleFilter)

Run the particle filter. `init_model` is the function which initialise the model,
`user_input_dict` is the list of input parameters, as a `Dict`.  `filter_type`
is the particle filter to use.  See [`ParticleFilter`](@ref) for the possible
values.
"""
function run_particle_filter(
    init_model, 
    user_input_dict::Dict, 
    filter_type::ParticleFilter;
    observation_sequence=nothing,
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    filter_params = get_params(FilterParameters, get(user_input_dict, "filter", Dict()))
    model_params_dict = get(user_input_dict, "model", Dict())
    return run_particle_filter(
        init_model, 
        filter_params, 
        model_params_dict, 
        filter_type; 
        observation_sequence, 
        rng
    )
end

end # module
