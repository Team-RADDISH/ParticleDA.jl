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