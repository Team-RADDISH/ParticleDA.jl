module LLW2d

using ParticleDA

using LinearAlgebra, Random, Distributions, Base.Threads, GaussianRandomFields, HDF5
using DelimitedFiles
using PDMats

include("llw2d_timestepping.jl")

"""
    LLW2dModelParameters()

Parameters for the linear long wave two-dimensional (LLW2d) model. Keyword arguments:

* `nx::Int` : Number of grid points in the x direction
* `ny::Int` : Number of grid points in the y direction
* `x_length::AbstractFloat` : Domain size in metres in the x direction
* `y_length::AbstractFloat` : Domain size in metres in the y direction
* `dx::AbstractFloat` : Distance in metres between grid points in the x direction
* `dy::AbstractFloat` : Distance in metrtes between grid points in the y direction
* `station_filename::String` : Name of input file for station coordinates
* `n_stations_x::Int` : Number of observation stations in the x direction (if using regular grid)
* `n_stations_y::Int` : Number of observation stations in the y direction (if using regular grid)
* `station_distance_x::Float` : Distance in metres between stations in the x direction (if using regular grid)
* `station_distance_y::Float` : Distance in metres between stations in the y direction (if using regular grid)
* `station_boundary_x::Float` : Distance in metres between bottom left edge of box and first station in the x direction (if using regular grid)
* `station_boundary_y::Float` : Distance in metres between bottom left edge of box and first station in the y direction (if using regular grid)
* `n_integration_step::Int` : Number of sub-steps to integrate the forward model per time step
* `time_step::AbstractFloat` : Time step length in seconds
* `peak_position::Vector{AbstractFloat}` : The `[x, y] coordinates in metres of the initial wave peak
* `peak_height::AbstractFloat` : The height in metres of the initial wave peak
* `source_size::AbstractFloat` : Cutoff distance in metres from the peak for the initial wave
* `bathymetry_setup::AbstractFloat` : Bathymetry set-up
* `lambda::AbstractFloat` : Length scale for Matérn covariance kernel in background noise
* `nu::AbstractFloat` : Smoothess parameter for Matérn covariance kernel in background noise
* `sigma::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel in background noise
* `lambda_initial_state::AbstractFloat` : Length scale for Matérn covariance kernel in initial state of particles
* `nu_initial_state::AbstractFloat` : Smoothess parameter for Matérn covariance kernel in initial state of particles
* `sigma_initial_state::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel in initial state of particles
* `padding::Int` : Min padding for circulant embedding gaussian random field generator
* `primes::Int`: Whether the size of the minimum circulant embedding of the covariance matrix can be written as a product of small primes (2, 3, 5 and 7). Default is `true`.
* `use_peak_initial_state_mean::Bool`: Whether to set mean of initial height field to a wave peak (true) or to all zeros (false). 
  In both cases the initial mean of the other state variables is zero.
* `absorber_thickness_fraction::Float` : Thickness of absorber for sponge absorbing boundary conditions, fraction of grid size
* `boundary_damping::Float` : Damping for boundaries
* `cutoff_depth::Float` : Shallowest water depth
* `obs_noise_std::Vector`: Standard deviations of noise added to observations of the true state
* `observed_state_var_indices::Vector`: Vector containing the indices of the observed state variables (1: height, 2: velocity x-component, 3: velocity y-component)
"""
Base.@kwdef struct LLW2dModelParameters{T<:AbstractFloat}

    nx::Int = 41
    ny::Int = 41
    x_length::T = 400.0e3
    y_length::T = 400.0e3
    dx::T = x_length / (nx - 1)
    dy::T = y_length / (ny - 1)

    time_step::T = 50.0
    n_integration_step::Int = 50

    station_filename::String = ""
    n_stations_x::Int = 4
    n_stations_y::Int = 4
    station_distance_x::T = 20.0e3
    station_distance_y::T = 20.0e3
    station_boundary_x::T = 150.0e3
    station_boundary_y::T = 150.0e3
    obs_noise_std::Vector{T} = [1.0]
    # Observed indices
    observed_state_var_indices::Vector{Int} = [1]

    source_size::T = 3.0e4
    bathymetry_setup::T = 3.0e3
    peak_height = 1.0
    peak_position = [floor(Int, nx / 4) * dx, floor(Int, ny / 4) * dy]

    lambda::Vector{T} = [1.0e4, 1.0e4, 1.0e4]
    nu::Vector{T} = [2.5, 2.5, 2.5]
    sigma::Vector{T} = [1.0, 1.0, 1.0]

    lambda_initial_state::Vector{T} = [1.0e4, 1.0e4, 1.0e4]
    nu_initial_state::Vector{T} = [2.5, 2.5, 2.5]
    sigma_initial_state::Vector{T} = [10.0, 10.0, 10.0]
    
    padding::Int = 100
    primes::Bool = true

    use_peak_initial_state_mean::Bool = false

    absorber_thickness_fraction::T = 0.1
    boundary_damping::T = 0.015
    cutoff_depth::T = 10.0

end

# Number of state variables in model
const n_state_var = 3

get_float_eltype(::Type{<:LLW2dModelParameters{T}}) where {T} = T
get_float_eltype(p::LLW2dModelParameters) = get_float_eltype(typeof(p))

struct RandomField{T<:Real, F<:GaussianRandomField}
    grf::F
    xi::Array{T, 3}
    w::Array{Complex{T}, 3}
    z::Array{T, 3}
end

struct LLW2dModel{T <: Real, U <: Real, G <: GaussianRandomField}
    parameters::LLW2dModelParameters{T}
    station_grid_indices::Matrix{Int}
    field_buffer::Array{T, 4}
    observation_buffer::Matrix{U}
    initial_state_grf::Vector{RandomField{T, G}}
    state_noise_grf::Vector{RandomField{T, G}}
    model_matrices::Matrices{T}
end

function ParticleDA.get_params(T::Type{LLW2dModelParameters}, user_input_dict::Dict)

    for key in ("lambda", "nu", "sigma", "lambda_initial_state", "nu_initial_state", "sigma_initial_state")
        if haskey(user_input_dict, key) && !isa(user_input_dict[key], Vector)
            user_input_dict[key] = fill(user_input_dict[key], 3)
        end
    end
    
    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = T(;user_input...)

end

function flat_state_to_fields(state::AbstractArray, params::LLW2dModelParameters)
    if ndims(state) == 1
        return reshape(state, (params.nx, params.ny, n_state_var))
    else
        return reshape(state, (params.nx, params.ny, n_state_var, :))
    end
end


function get_grid_axes(params::LLW2dModelParameters)
    x = range(0, length=params.nx, step=params.dx)
    y = range(0, length=params.ny, step=params.dy)
    return x, y
end


# Initialize a gaussian random field generating function using the Matern covariance kernel
# and circulant embedding generation method
# TODO: Could generalise this
function init_gaussian_random_field_generator(
    lambda::Vector{T},
    nu::Vector{T},
    sigma::Vector{T},
    x::AbstractVector{T},
    y::AbstractVector{T},
    pad::Int,
    primes::Bool,
    n_tasks::Int,
) where T

    # Let's limit ourselves to two-dimensional fields
    dim = 2

    function _generate(l, n, s)
        cov = CovarianceFunction(dim, Matern(l, n, σ = s))
        grf = GaussianRandomField(cov, CirculantEmbedding(), x, y, minpadding=pad, primes=primes)
        v = grf.data[1]
        xi = Array{eltype(grf.cov)}(undef, size(v)..., n_tasks)
        w = Array{complex(float(eltype(v)))}(undef, size(v)..., n_tasks)
        z = Array{eltype(grf.cov)}(undef, length.(grf.pts)..., n_tasks)
        RandomField(grf, xi, w, z)
    end

    return [_generate(l, n, s) for (l, n, s) in zip(lambda, nu, sigma)]
end

# Get a random sample from random_field_generator using random number generator rng
function sample_gaussian_random_field!(
    field::AbstractMatrix{T},
    random_field_generator::RandomField,
    rng::Random.AbstractRNG,
    task_index::Integer=1
) where T

    randn!(rng, selectdim(random_field_generator.xi, 3, task_index))
    sample_gaussian_random_field!(
        field,
        random_field_generator,
        selectdim(random_field_generator.xi, 3, task_index),
        task_index
    )

end

# Get a random sample from random_field_generator using random_numbers
function sample_gaussian_random_field!(
    field::AbstractMatrix{T},
    random_field_generator::RandomField,
    random_numbers::AbstractArray{T},
    task_index::Integer=1
) where T
    field .= GaussianRandomFields._sample!(
        selectdim(random_field_generator.w, 3, task_index),
        selectdim(random_field_generator.z, 3, task_index),
        random_field_generator.grf,
        random_numbers
    )
end

function add_random_field!(
    state_fields::AbstractArray{T, 3},
    field_buffer::AbstractMatrix{T},
    generators::Vector{<:RandomField},
    rng::Random.AbstractRNG,
    task_index::Integer
) where T
    for (field, generator) in zip(eachslice(state_fields, dims=3), generators)
        sample_gaussian_random_field!(field_buffer, generator, rng, task_index)
        field .+= field_buffer
    end
end

function ParticleDA.get_initial_state_mean!(
    state_mean::AbstractVector{T},
    model::LLW2dModel,
) where {T <: Real}
    state_mean_fields = flat_state_to_fields(state_mean, model.parameters)
    if model.parameters.use_peak_initial_state_mean
        initheight!(
            selectdim(state_mean_fields, 3, 1), 
            model.model_matrices, 
            model.parameters.dx, 
            model.parameters.dy,
            model.parameters.source_size, 
            model.parameters.peak_height, 
            model.parameters.peak_position
        )
        state_mean_fields[:, :, 2:3] .= 0
    else
        state_mean_fields .= 0
    end
    return state_mean
end

function ParticleDA.sample_initial_state!(
    state::AbstractVector{T},
    model::LLW2dModel, 
    rng::Random.AbstractRNG,
    task_index::Integer=1
) where T
    ParticleDA.get_initial_state_mean!(state, model)
    # Add samples of the initial random field to all particles
    add_random_field!(
        flat_state_to_fields(state, model.parameters), 
        view(model.field_buffer, :, :, 1, task_index), 
        model.initial_state_grf, 
        rng,
        task_index
    )
    return state
end

function get_station_grid_indices(params::LLW2dModelParameters)
    if params.station_filename != ""
        return get_station_grid_indices(
            params.station_filename,
            params.dx,
            params.dy,
        )
    else
        return get_station_grid_indices(
            params.n_stations_x,
            params.n_stations_y,
            params.station_distance_x,
            params.station_distance_y,
            params.station_boundary_x,
            params.station_boundary_y,
            params.dx,
            params.dy,
        )
    end

end

function get_station_grid_indices(
    filename::String,
    dx::T,
    dy::T,
) where T
    coords = readdlm(filename, ',', Float64, '\n'; comments=true, comment_char='#')
    return floor.(Int, coords ./ [dx dy]) .+ 1
end

function get_station_grid_indices(
    n_stations_x::Integer,
    n_stations_y::Integer,
    station_distance_x::T,
    station_distance_y::T,
    station_boundary_x::T,
    station_boundary_y::T,
    dx::T,
    dy::T
) where T
    # synthetic station locations
    station_grid_indices = Matrix{Int}(undef, n_stations_x * n_stations_y, 2)
    n = 0
    @inbounds for i in 1:n_stations_x, j in 1:n_stations_y
        n += 1
        station_grid_indices[n, 1] = round(
            Int, (station_boundary_x + (i - 1) * station_distance_x) / dx + 1
        )
        station_grid_indices[n, 2] = round(
            Int, (station_boundary_y + (j - 1) * station_distance_y) / dy + 1
        )
    end
    return station_grid_indices
end


ParticleDA.get_state_dimension(model::LLW2dModel) = (
    model.parameters.nx * model.parameters.ny * n_state_var
)

ParticleDA.get_observation_dimension(model::LLW2dModel) = (
    size(model.station_grid_indices, 1) * length(model.parameters.observed_state_var_indices)
)

ParticleDA.get_state_eltype(::Type{<:LLW2dModel{T, U, G}}) where {T, U, G} = T
ParticleDA.get_state_eltype(model::LLW2dModel) = ParticleDA.get_state_eltype(typeof(model))

ParticleDA.get_observation_eltype(::Type{<:LLW2dModel{T, U, G}}) where {T, U, G} = U
ParticleDA.get_observation_eltype(model::LLW2dModel) = ParticleDA.get_observation_eltype(typeof(model))

function ParticleDA.get_covariance_observation_noise(
    model::LLW2dModel, state_index_1::CartesianIndex, state_index_2::CartesianIndex
)
    x_index_1, y_index_1, var_index_1 = state_index_1.I
    x_index_2, y_index_2, var_index_2 = state_index_2.I

    if (x_index_1 == x_index_2 && y_index_1 == y_index_2 && var_index_1 == var_index_2)
        return (model.parameters.obs_noise_std[var_index_1]^2)
    else
        return 0.
    end
end

function ParticleDA.get_covariance_observation_noise(
    model::LLW2dModel, state_index_1::Int, state_index_2::Int
)
    return ParticleDA.get_covariance_observation_noise(
        model,
        flat_state_index_to_cartesian_index(model.parameters, state_index_1),
        flat_state_index_to_cartesian_index(model.parameters, state_index_2),
    )
end

function ParticleDA.get_covariance_observation_noise(model::LLW2dModel)
    observation_dimension = ParticleDA.get_observation_dimension(model)
    return PDiagMat(
        [
            ParticleDA.get_covariance_observation_noise(model, i, i) 
            for i in 1:observation_dimension
        ]
    )
end

function flat_state_index_to_cartesian_index(
    parameters::LLW2dModelParameters, flat_index::Integer
)
    n_grid = parameters.nx * parameters.ny
    state_var_index, flat_grid_index = fldmod1(flat_index, n_grid)
    grid_y_index, grid_x_index = fldmod1(flat_grid_index, parameters.nx)
    return CartesianIndex(grid_x_index, grid_y_index, state_var_index)
end

function grid_index_to_grid_point(
    parameters::LLW2dModelParameters, grid_index::Tuple{T, T}
) where {T <: Integer}
    return [
        (grid_index[1] - 1) * parameters.dx, (grid_index[2] - 1) * parameters.dy
    ]
end

function observation_index_to_cartesian_state_index(
    parameters::LLW2dModelParameters, station_grid_indices::AbstractMatrix, observation_index::Integer
)
    n_station = size(station_grid_indices,1)
    state_var_index, station_index = fldmod1(observation_index, n_station)
    return CartesianIndex(
        station_grid_indices[station_index, :]..., state_var_index
    )
end

function get_covariance_gaussian_random_fields(
    gaussian_random_fields::Vector{RandomField{T, G}},
    model_parameters::LLW2dModelParameters,
    state_index_1::CartesianIndex,
    state_index_2::CartesianIndex
) where {T <: Real, G <: GaussianRandomField}
    x_index_1, y_index_1, var_index_1 = state_index_1.I
    x_index_2, y_index_2, var_index_2 = state_index_2.I
    if var_index_1 == var_index_2
        grid_point_1 = grid_index_to_grid_point(
            model_parameters, (x_index_1, y_index_1)
        )
        grid_point_2 = grid_index_to_grid_point(
            model_parameters, (x_index_2, y_index_2)
        )
        covariance_structure = gaussian_random_fields[var_index_1].grf.cov.cov
        return apply(
            covariance_structure, abs.(grid_point_1 .- grid_point_2)
        )
    else
        return 0.
    end
end

function ParticleDA.get_covariance_state_noise(
    model::LLW2dModel, state_index_1::CartesianIndex, state_index_2::CartesianIndex
)
    return get_covariance_gaussian_random_fields(
        model.state_noise_grf, model.parameters, state_index_1, state_index_2,
    )
end

function ParticleDA.get_covariance_state_noise(
    model::LLW2dModel, state_index_1::Integer, state_index_2::Integer
)
    return get_covariance_gaussian_random_fields(
        model.state_noise_grf,
        model.parameters,
        flat_state_index_to_cartesian_index(model.parameters, state_index_1),
        flat_state_index_to_cartesian_index(model.parameters, state_index_2),
    )
end

function ParticleDA.get_covariance_initial_state(
    model::LLW2dModel, state_index_1::Integer, state_index_2::Integer
)
    return get_covariance_gaussian_random_fields(
        model.initial_state_grf,
        model.parameters,
        flat_state_index_to_cartesian_index(model.parameters, state_index_1),
        flat_state_index_to_cartesian_index(model.parameters, state_index_2),
    )
end

function ParticleDA.get_covariance_observation_observation_given_previous_state(
    model::LLW2dModel, observation_index_1::Integer, observation_index_2::Integer
)
    observation_1 = observation_index_to_cartesian_state_index(
            model.parameters, 
            model.station_grid_indices, 
            observation_index_1
        )

    observation_2 = observation_index_to_cartesian_state_index(
        model.parameters, 
            model.station_grid_indices, 
            observation_index_2
    )
    return ParticleDA.get_covariance_state_noise(
        model,
        observation_1,
        observation_2,
    ) + ParticleDA.get_covariance_observation_noise(
        model, observation_1, observation_2
    )
end

function ParticleDA.get_covariance_state_observation_given_previous_state(
    model::LLW2dModel, state_index::Integer, observation_index::Integer
)
    return ParticleDA.get_covariance_state_noise(
        model,
        flat_state_index_to_cartesian_index(model.parameters, state_index),
        observation_index_to_cartesian_state_index(
            model.parameters, model.station_grid_indices, observation_index
        ),
    )
end
                                                         
function ParticleDA.get_state_indices_correlated_to_observations(model::LLW2dModel)
    n_grid = model.parameters.nx * model.parameters.ny
    return vcat(
        (
            (i - 1) * n_grid + 1 : i * n_grid 
            for i in model.parameters.observed_state_var_indices
        )...
    )
end

function init(parameters_dict::Dict, n_tasks::Int=1)

    parameters = ParticleDA.get_params(
        LLW2dModelParameters, get(parameters_dict, "llw2d", Dict())
    )
    
    station_grid_indices = get_station_grid_indices(parameters)
     
    T = get_float_eltype(parameters)
    n_stations = size(station_grid_indices, 1)
    n_observations = n_stations * length(parameters.observed_state_var_indices)
    
    # Buffer array to be used in the tsunami update
    field_buffer = Array{T}(undef, parameters.nx, parameters.ny, 2, n_tasks)
    
    # Buffer array to be used in computing observation mean
    observation_buffer = Array{T}(undef, n_observations, n_tasks)
    
    # Gaussian random fields for generating intial state and state noise
    x, y = get_grid_axes(parameters)
    initial_state_grf = init_gaussian_random_field_generator(
        parameters.lambda_initial_state,
        parameters.nu_initial_state,
        parameters.sigma_initial_state,
        x,
        y,
        parameters.padding,
        parameters.primes,
        n_tasks,
    )
    state_noise_grf = init_gaussian_random_field_generator(
        parameters.lambda,
        parameters.nu,
        parameters.sigma,
        x,
        y,
        parameters.padding,
        parameters.primes,
        n_tasks
    )

    # Set up tsunami model
    model_matrices = setup(
        parameters.nx,
        parameters.ny,
        parameters.bathymetry_setup,
        parameters.absorber_thickness_fraction,
        parameters.boundary_damping,
        parameters.cutoff_depth
    )

    return LLW2dModel(
        parameters, 
        station_grid_indices, 
        field_buffer,
        observation_buffer,
        initial_state_grf,
        state_noise_grf, 
        model_matrices
    )
end

function ParticleDA.get_observation_mean_given_state!(
    observation_mean::AbstractVector,
    state::AbstractVector,
    model::LLW2dModel,
    task_index::Integer=1
)
    state_fields = flat_state_to_fields(state, model.parameters)
    n = 1
    for k in model.parameters.observed_state_var_indices
        for (i, j) in eachrow(model.station_grid_indices)
            observation_mean[n] = state_fields[i, j, k]
            n += 1
        end
    end
end

function ParticleDA.sample_observation_given_state!(
    observation::AbstractVector{S},
    state::AbstractVector{T},
    model::LLW2dModel,
    rng::AbstractRNG,
    task_index::Integer=1,
) where{S, T}
    ParticleDA.get_observation_mean_given_state!(observation, state, model, task_index)
    observation .+= rand(
        rng, MvNormal(ParticleDA.get_covariance_observation_noise(model))
    )
    return observation
end

function ParticleDA.get_log_density_observation_given_state(
    observation::AbstractVector, 
    state::AbstractVector, 
    model::LLW2dModel,
    task_index::Integer=1
)
    observation_mean = selectdim(model.observation_buffer, 2, task_index)
    ParticleDA.get_observation_mean_given_state!(observation_mean, state, model, task_index)
    return -invquad(
        ParticleDA.get_covariance_observation_noise(model), 
        observation - observation_mean
    ) / 2 
end

function ParticleDA.update_state_deterministic!(
    state::AbstractVector, model::LLW2dModel, time_index::Integer, task_index::Integer=1
)
    # Parts of state vector are aliased to tsunami height and velocity component fields
    state_fields = flat_state_to_fields(state, model.parameters)
    height_field = selectdim(state_fields, 3, 1)
    velocity_x_field = selectdim(state_fields, 3, 2)
    velocity_y_field = selectdim(state_fields, 3, 3)
    dx_buffer = view(model.field_buffer, :, :, 1, task_index)
    dy_buffer = view(model.field_buffer, :, :, 2, task_index)
    dt = model.parameters.time_step / model.parameters.n_integration_step
    for _ in 1:model.parameters.n_integration_step
        # Update tsunami wavefield with LLW2d.timestep in-place
        timestep!(
            dx_buffer, 
            dy_buffer, 
            height_field, 
            velocity_x_field,
            velocity_y_field,
            height_field, 
            velocity_x_field, 
            velocity_y_field, 
            model.model_matrices,
            model.parameters.dx,
            model.parameters.dy, 
            dt
        )
    end
end

function ParticleDA.update_state_stochastic!(
    state::AbstractVector, model::LLW2dModel, rng::AbstractRNG, task_index::Integer=1
)
    # Add state noise
    add_random_field!(
        flat_state_to_fields(state, model.parameters),
        view(model.field_buffer, :, :, 1, task_index),
        model.state_noise_grf,
        rng,
        task_index
    )
end

### Model IO

function write_parameters(group::HDF5.Group, params::LLW2dModelParameters)
    fields = fieldnames(typeof(params))
    for field in fields
        attributes(group)[string(field)] = getfield(params, field)
    end
end

function write_coordinates(group::HDF5.Group, x::AbstractVector, y::AbstractVector)
    for (dataset_name, val) in zip(("x", "y"), (x, y))
        dataset, _ = create_dataset(group, dataset_name, val)
        dataset[:] = val
        attributes(dataset)["Description"] = "$dataset_name coordinate"
        attributes(dataset)["Unit"] = "m"
    end
end

function ParticleDA.write_model_metadata(file::HDF5.File, model::LLW2dModel)
    parameters = model.parameters
    grid_x, grid_y = map(collect, get_grid_axes(parameters))
    stations_x = (model.station_grid_indices[:, 1] .- 1) .* parameters.dx
    stations_y = (model.station_grid_indices[:, 2] .- 1) .* parameters.dy
    for (group_name, write_group) in [
        ("parameters", group -> write_parameters(group, parameters)),
        ("grid_coordinates", group -> write_coordinates(group, grid_x, grid_y)),
        ("station_coordinates", group -> write_coordinates(group, stations_x, stations_y)),
    ]
        if !haskey(file, group_name)
            group = create_group(file, group_name)
            write_group(group)
        else
            @warn "Write failed, group $group_name already exists in  $(file.filename)!"
        end
    end
end    

function ParticleDA.write_state(
    file::HDF5.File,
    state::AbstractVector{T},
    time_index::Int,
    group_name::String,
    model::LLW2dModel
) where T
    parameters = model.parameters
    subgroup_name = ParticleDA.time_index_to_hdf5_key(time_index)
    _, subgroup = ParticleDA.create_or_open_group(file, group_name, subgroup_name)
    state_fields = flat_state_to_fields(state, parameters)
    state_fields_metadata = [
        (name="height", unit="m", description="Ocean surface height"),
        (name="vx", unit="m/s", description="Ocean surface velocity x-component"),
        (name="vy", unit="m/s", description="Ocean surface velocity y-component")
    ]
    for (field, metadata) in zip(eachslice(state_fields, dims=3), state_fields_metadata)
        if !haskey(subgroup, metadata.name)
            subgroup[metadata.name] = field
            dataset_attributes = attributes(subgroup[metadata.name])
            dataset_attributes["Description"] = metadata.description
            dataset_attributes["Unit"] = metadata.unit
            dataset_attributes["Time index"] = time_index
            dataset_attributes["Time (s)"] = time_index * parameters.time_step
        else
            @warn "Write failed, dataset $(metadata.name) already exists in $(subgroup)!"
        end
    end
end

end # module
