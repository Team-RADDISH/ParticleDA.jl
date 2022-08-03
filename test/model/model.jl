module Model

using ParticleDA

using LinearAlgebra, Random, Distributions, Base.Threads, GaussianRandomFields, HDF5
using ParticleDA.Default_params
using DelimitedFiles
using FieldMetadata
using PDMats

include("llw2d.jl")
using .LLW2d

"""
    ModelParameters()

Parameters for the model. Keyword arguments:

* `nx::Int` : Number of grid points in the x direction
* `ny::Int` : Number of grid points in the y direction
* `x_length::AbstractFloat` : Domain size (m) in the x direction
* `y_length::AbstractFloat` : Domain size (m) in the y direction
* `dx::AbstractFloat` : Distance (m) between grid points in the x direction
* `dy::AbstractFloat` : Distance (m) between grid points in the y direction
* `n_state_var::Int`: Number of variables in the state vector
* `nobs::Int` : Number of observation stations
* `station_filename::String` : Name of input file for station coordinates
* `station_distance_x::Float` : Distance between stations in the x direction [m]
* `station_distance_y::Float` : Distance between stations in the y direction [m]
* `station_boundary_x::Float` : Distance between bottom left edge of box and first station in the x direction [m]
* `station_boundary_y::Float` : Distance between bottom left edge of box and first station in the y direction [m]
* `n_integration_step::Int` : Number of sub-steps to integrate the forward model per time step.
* `time_step::AbstractFloat` : Time step length (s)
* `state_prefix::String` : Prefix of the time slice data groups in output
* `title_da::String` : Suffix of the data assimilated data group in output
* `title_syn::String` : Suffix of the true state data group in output
* `title_grid::String` : Name of the grid data group in output
* `title_stations::String` : Name of the station coordinates data group in output
* `title_params::String` : Name of the parameters data group in output
* `peak_position::Vector{AbstractFloat}` : The [x,y] coordinates (m) of the initial wave peak
* `peak_height::AbstractFloat` : The height (m) of the initial wave peak
* `source_size::AbstractFloat` : Cutoff distance (m) from the peak for the initial wave
* `bathymetry_setup::AbstractFloat` : Bathymetry set-up.
* `lambda::AbstractFloat` : Length scale for Matérn covariance kernel in background noise
* `nu::AbstractFloat` : Smoothess parameter for Matérn covariance kernel in background noise
* `sigma::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel in background noise
* `lambda_initial_state::AbstractFloat` : Length scale for Matérn covariance kernel in initial state of particles
* `nu_initial_state::AbstractFloat` : Smoothess parameter for Matérn covariance kernel in initial state of particles
* `sigma_initial_state::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel in initial state of particles
* `padding::Int` : Min padding for circulant embedding gaussian random field generator
* `primes::Int`: Whether the size of the minimum circulant embedding of the covariance matrix can be written as a product of small primes (2, 3, 5 and 7). Default is `true`.
* `particle_initial_state::String` : Initial state of the particles before noise is added. Possible options are
  * "zero" : initialise height and velocity to 0 everywhere
  * "true" : copy the true initial state
* `absorber_thickness_fraction::Float` : Thickness of absorber for sponge absorbing boundary conditions, fraction of grid size
* `boundary_damping::Float` : damping for boundaries
* `cutoff_depth::Float` : Shallowest water depth
* `obs_noise_std::Float`: Standard deviation of noise added to observations of the true state
* `observed_indices::Vector`: Vector containing the indices of the observed values in the state vector
* `particle_dump_file::String`: file name for dump of particle state vectors
* `particle_dump_time::Int`: list of (one more more) time steps to dump particle states
"""
Base.@kwdef struct ModelParameters{T<:AbstractFloat}

    nx::Int = 200
    ny::Int = 200
    x_length::T = 400.0e3
    y_length::T = 400.0e3
    dx::T = x_length / (nx - 1)
    dy::T = y_length / (ny - 1)

    n_state_var::Int = 3

    time_step::T = 50.0
    n_integration_step::Int = 50

    station_filename::String = ""
    n_stations_x::Int = 4
    n_stations_y::Int = 4
    station_distance_x::T = 20.0e3
    station_distance_y::T = 20.0e3
    station_boundary_x::T = 150.0e3
    station_boundary_y::T = 150.0e3
    obs_noise_std::T = 1.0
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

    particle_initial_state::String = "zero"

    absorber_thickness_fraction::T = 0.1
    boundary_damping::T = 0.015
    cutoff_depth::T = 10.0

    state_prefix::String = "data"
    title_avg::String = "avg"
    title_var::String = "var"
    title_syn::String = "syn"
    title_grid::String = "grid"
    title_stations::String = "stations"
    title_params::String = "params"

    particle_dump_file = "particle_dump.h5"
    particle_dump_time = [-1]
end

get_float_eltype(::Type{<:ModelParameters{T}}) where {T} = T
get_float_eltype(p::ModelParameters) = get_float_eltype(typeof(p))

struct RandomField{F<:GaussianRandomField,X<:AbstractArray,W<:AbstractArray,Z<:AbstractArray}
    grf::F
    xi::X
    w::W
    z::Z
end

@metadata name ("","","") NTuple{3, String}
@metadata unit ("","","") NTuple{3, String}
@metadata description ("","","") NTuple{3, String}

@name @description @unit struct StateVectors{T<:AbstractArray, S<:AbstractArray}

    particles::T | ("height","vx","vy") | ("Ocean surface height","Ocean surface velocity x-component","Ocean surface velocity y-component") | ("m","m/s","m/s")
    truth::S | ("height","vx","vy") | ("Ocean surface height","Ocean surface velocity x-component","Ocean surface velocity y-component") | ("m","m/s","m/s")

end

struct ModelData{A,B,C,D,E,F,G,H,I}
    model_params::A
    states::B
    observations::C
    station_grid_indices::D
    field_buffer::E
    observation_buffer::F
    state_noise_grf::G
    model_matrices::H
    rng::I
end

function ParticleDA.get_params(T::Type{ModelParameters}, user_input_dict::Dict)

    for key in ("lambda", "nu", "sigma", "lambda_initial_state", "nu_initial_state", "sigma_initial_state")
        if haskey(user_input_dict, key) && !isa(user_input_dict[key], Vector)
            user_input_dict[key] = fill(user_input_dict[key], 3)
        end
    end
    
    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = T(;user_input...)

end

function get_obs!(
    observations::AbstractVector{T},
    state::AbstractArray{T, 3},
    params::ModelParameters,
    station_grid_indices::AbstractMatrix,
) where T
    get_obs!(
        observations, state, params.observed_state_var_indices, station_grid_indices
    )
end

# Return observation data at stations from given model state
function get_obs!(
    observations::AbstractVector{T},
    state::AbstractArray{T, 3},
    observed_state_var_indices::AbstractVector{Int},
    station_grid_indices::AbstractMatrix{Int},
) where T
    @assert (
        length(observations) 
        == size(station_grid_indices, 1) * length(observed_state_var_indices) 
    )
    n = 1
    for k in observed_state_var_indices
        for (i, j) in eachrow(station_grid_indices)
            observations[n] = state[i, j, k]
            n += 1
        end
    end
end

function tsunami_update!(dx_buffer::AbstractMatrix{T},
                         dy_buffer::AbstractMatrix{T},
                         state::AbstractArray{T,3},
                         model_matrices::LLW2d.Matrices{T},
                         params::ModelParameters) where T

    tsunami_update!(dx_buffer, dy_buffer, state, params.n_integration_step,
                    params.dx, params.dy, params.time_step, model_matrices)

end

# Update tsunami wavefield with LLW2d in-place.
function tsunami_update!(dx_buffer::AbstractMatrix{T},
                         dy_buffer::AbstractMatrix{T},
                         state::AbstractArray{T,3},
                         nt::Int,
                         dx::Real,
                         dy::Real,
                         time_interval::Real,
                         model_matrices::LLW2d.Matrices{T}) where T

    eta_a = @view(state[:, :, 1])
    mm_a  = @view(state[:, :, 2])
    nn_a  = @view(state[:, :, 3])
    eta_f = @view(state[:, :, 1])
    mm_f  = @view(state[:, :, 2])
    nn_f  = @view(state[:, :, 3])

    dt = time_interval / nt

    for it in 1:nt
        # Parts of model vector are aliased to tsunami heiht and velocities
        LLW2d.timestep!(dx_buffer, dy_buffer, eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, model_matrices, dx, dy, dt)
    end

end

function get_axes(params::ModelParameters)

    return get_axes(params.nx, params.ny, params.dx, params.dy)

end

function get_axes(nx::Int, ny::Int, dx::Real, dy::Real)

    x = range(0, length=nx, step=dx)
    y = range(0, length=ny, step=dy)

    return x,y
end

function init_gaussian_random_field_generator(params::ModelParameters)

    x, y = get_axes(params)
    return init_gaussian_random_field_generator(params.lambda,params.nu, params.sigma, x, y, params.padding, params.primes)

end

# Initialize a gaussian random field generating function using the Matern covariance kernel
# and circulant embedding generation method
# TODO: Could generalise this
function init_gaussian_random_field_generator(lambda::Vector{T},
                                              nu::Vector{T},
                                              sigma::Vector{T},
                                              x::AbstractVector{T},
                                              y::AbstractVector{T},
                                              pad::Int,
                                              primes::Bool) where T

    # Let's limit ourselves to two-dimensional fields
    dim = 2

    function _generate(l, n, s)
        cov = CovarianceFunction(dim, Matern(l, n, σ = s))
        grf = GaussianRandomField(cov, CirculantEmbedding(), x, y, minpadding=pad, primes=primes)
        v = grf.data[1]
        xi = Array{eltype(grf.cov)}(undef, size(v)..., nthreads())
        w = Array{complex(float(eltype(v)))}(undef, size(v)..., nthreads())
        z = Array{eltype(grf.cov)}(undef, length.(grf.pts)..., nthreads())
        RandomField(grf, xi, w, z)
    end

    return [_generate(l, n, s) for (l, n, s) in zip(lambda, nu, sigma)]
end

# Get a random sample from random_field_generator using random number generator rng
function sample_gaussian_random_field!(field::AbstractMatrix{T},
                                       random_field_generator::RandomField,
                                       rng::Random.AbstractRNG) where T

    @. @view(random_field_generator.xi[:,:,threadid()]) = randn((rng,), T)
    sample_gaussian_random_field!(field, random_field_generator, @view(random_field_generator.xi[:,:,threadid()]))

end

# Get a random sample from random_field_generator using random_numbers
function sample_gaussian_random_field!(field::AbstractMatrix{T},
                                       random_field_generator::RandomField,
                                       random_numbers::AbstractArray{T}) where T

    field .= GaussianRandomFields._sample!(@view(random_field_generator.w[:,:,threadid()]),
                                           @view(random_field_generator.z[:,:,threadid()]),
                                           random_field_generator.grf,
                                           random_numbers)

end

# Add a gaussian random field to the height in the state vector of all particles
function add_random_field!(state::AbstractArray{T,4},
                           field_buffer::AbstractArray{T,4},
                           generators::Vector{<:RandomField},
                           rng::Random.AbstractRNG,
                           nvar::Int,
                           nprt::Int) where T

    Threads.@threads for ip in 1:nprt

        for ivar in 1:nvar

            sample_gaussian_random_field!(@view(field_buffer[:, :, 1, threadid()]), generators[ivar], rng)
            @view(state[:, :, ivar, ip]) .+= @view(field_buffer[:, :, 1, threadid()])

        end

    end

end

function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, cov::AbstractPDMat{T}) where T
    vec .+= rand(rng, MvNormal(cov))
end

function set_initial_state!(
    states::StateVectors, 
    model_matrices::LLW2d.Matrices{T},
    field_buffer::AbstractArray{T, 4},
    rng::Random.AbstractRNG,
    nprt_per_rank::Int,
    params::ModelParameters
) where T

    # Set true initial state
    LLW2d.initheight!(
        @view(states.truth[:, :, 1]), 
        model_matrices, 
        params.dx, 
        params.dy,
        params.source_size, 
        params.peak_height, 
        params.peak_position
    )

    # Create generator for the initial random field
    x, y = get_axes(params)
    initial_grf = init_gaussian_random_field_generator(
        params.lambda_initial_state,
        params.nu_initial_state,
        params.sigma_initial_state,
        x,
        y,
        params.padding,
        params.primes
    )

    # Since states.particles is initially created as `zeros` we don't need to set it to 0 here
    # to get the default behaviour
    if params.particle_initial_state == "true"
        states.particles .= states.truth
    end

    # Add samples of the initial random field to all particles
    add_random_field!(
        states.particles, 
        field_buffer, 
        initial_grf, 
        rng, 
        params.n_state_var, 
        nprt_per_rank
    )

end

function get_station_grid_indices(params::ModelParameters)
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
    return floor(Int, coords ./ [dx dy]) .+ 1
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

ParticleDA.get_state_dimension(d::ModelData) = (
    d.model_params.nx * d.model_params.ny * d.model_params.n_state_var
)

ParticleDA.get_observation_dimension(d::ModelData) = (
    size(d.station_grid_indices, 1) * length(d.model_params.observed_state_var_indices)
)

ParticleDA.get_state_eltype(d::ModelData) = get_float_eltype(d.model_params)
ParticleDA.get_observation_eltype(d::ModelData) = get_float_eltype(d.model_params)

ParticleDA.get_particles(d::ModelData) = reshape(
    d.states.particles, (ParticleDA.get_state_dimension(d), :)
)
# TODO: we should probably get rid of `get_truth`: it is only used as return
# value of `particle_filter`, we may just return the whole `model_data`.
ParticleDA.get_truth(d::ModelData) = reshape(
    d.states.truth, ParticleDA.get_state_dimension(d),
)

function ParticleDA.get_covariance_observation_noise(
    d::ModelData, observation_index_1::Integer, observation_index_2::Integer
)
    return (
        observation_index_1 == observation_index_2 ? d.model_params.obs_noise_std^2 : 0.
    )
end

function ParticleDA.get_covariance_observation_noise(d::ModelData)
    return ScalMat(
        ParticleDA.get_observation_dimension(d), d.model_params.obs_noise_std^2
    )
end

function flat_state_index_to_cartesian_index(
    model_params::ModelParameters, flat_index::Integer
)
    n_grid = model_params.nx * model_params.ny
    state_var_index, flat_grid_index = fldmod1(flat_index, n_grid)
    grid_y_index, grid_x_index = fldmod1(flat_grid_index, model_params.nx)
    return CartesianIndex(grid_x_index, grid_y_index, state_var_index)
end

function grid_index_to_grid_point(
    model_params::ModelParameters, grid_index::Tuple{T, T}
) where {T <: Integer}
    return [
        (grid_index[1] - 1) * model_params.dx, (grid_index[2] - 1) * model_params.dy
    ]
end

function observation_index_to_cartesian_state_index(
    model_params::ModelParameters, station_grid_indices::AbstractMatrix, observation_index::Integer
)
    n_station = model_params.n_stations_x * model_params.n_stations_y
    state_var_index, station_index = fldmod1(observation_index, n_station)
    return CartesianIndex(
        station_grid_indices[station_index]..., state_var_index
    )
end

function ParticleDA.get_covariance_state_noise(
    model_data::ModelData, state_index_1::Integer, state_index_2::Integer
)
    return ParticleDA.get_covariance_state_noise(
        model_data, 
        flat_state_index_to_cartesian_index(model_data.model_params, state_index_1),
        flat_state_index_to_cartesian_index(model_data.model_params, state_index_2),
    )
end

function ParticleDA.get_covariance_state_noise(
    model_data::ModelData, state_index_1::CartesianIndex, state_index_2::CartesianIndex
)
    x_index_1, y_index_1, var_index_1 = state_index_1.I
    x_index_2, y_index_2, var_index_2 = state_index_2.I
    if var_index_1 == var_index_2
        grid_point_1 = grid_index_to_grid_point(
            model_data.model_params, (x_index_1, y_index_1)
        )
        grid_point_2 = grid_index_to_grid_point(
            model_data.model_params, (x_index_2, y_index_2)
        )
        covariance_structure = d.state_noise_grf[var_index_1].grf.cov.cov
        return covariance_structure.σ^2 * apply(
            covariance_structure, abs.(grid_point_1 .- grid_point_2)
        )
    else
        return 0.
    end
end

function ParticleDA.get_covariance_observation_observation_given_previous_state(
    model_data::ModelData, observation_index_1::Integer, observation_index_2::Integer
)
    return ParticleDA.get_covariance_state_noise(
        model_data,
        observation_index_to_cartesian_state_index(
            model_data.model_params, 
            model_data.station_grid_indices, 
            observation_index_1
        ),
        observation_index_to_cartesian_state_index(
            model_data.model_params, 
            model_data.station_grid_indices, 
            observation_index_2
        ),
    ) + ParticleDA.get_covariance_observation_noise(
        model_data, observation_index_1, observation_index_2
    )
end

function ParticleDA.get_covariance_state_observation_given_previous_state(
    model_data::ModelData, state_index::Integer, observation_index::Integer
)
    return ParticleDA.get_covariance_state_noise(
        model_data,
        flat_state_index_to_cartesian_index(model_data.model_params, state_index),
        observation_index_to_cartesian_state_index(
            model_data.model_params, model_data.station_grid_indices, observation_index
        ),
    )
end
                                                         
function ParticleDA.get_state_indices_correlated_to_observations(model_data::ModelData)
    n_grid = model_data.model_params.nx * model_data.model_params.ny
    return vcat(
        (
            (i - 1) * n_grid + 1 : i * n_grid 
            for i in model_data.model_params.observed_state_var_indices
        )...
    )
end

function ParticleDA.set_particles!(
    model_data::ModelData, particles::AbstractArray{T}
) where T
    model_params = model_data.model_params
    model_data.states.particles .= reshape(
        particles, (model_params.nx, model_params.ny, model_params.n_state_var, :)
    )
end

function init(model_params_dict::Dict, nprt_per_rank::Int, my_rank::Integer, rng::Random.AbstractRNG)

    model_params = ParticleDA.get_params(
        ModelParameters, get(model_params_dict, "llw2d", Dict())
    )
    
    station_grid_indices = get_station_grid_indices(model_params)
     
    T = get_float_eltype(params)
    n_stations = size(station_grid_indices, 1)
    n_observations = n_stations * length(model_params.observed_state_var_indices)

    states = StateVectors(
        zeros(T, nx, ny, n_state_var, nprt_per_rank), 
        zeros(T, nx, ny, n_state_var)
    )
    
    observations = Vector{T}(undef, n_observations)
    
    # Buffer array to be used in the tsunami update
    field_buffer = Array{T}(undef, model_params.nx, model_params.ny, 2, nthreads())
    
    # Buffer array to be used in computing observation mean
    observation_buffer = Array{T}(undef, n_observations, nthreads())
    
    # Gaussian random fields for generating state noise
    state_noise_grf = init_gaussian_random_field_generator(model_params)

    # Set up tsunami model
    model_matrices = LLW2d.setup(
        model_params.nx,
        model_params.ny,
        model_params.bathymetry_setup,
        model_params.absorber_thickness_fraction,
        model_params.boundary_damping,
        model_params.cutoff_depth
    )

    set_initial_state!(
        states, model_matrices, field_buffer, rng, nprt_per_rank, model_params
    )

    return ModelData(
        model_params, 
        states, 
        observations, 
        station_grid_indices, 
        field_buffer,
        observation_buffer,
        state_noise_grf, 
        model_matrices, 
        rng
    )
end

function ParticleDA.update_truth!(model_data::ModelData)
    tsunami_update!(
        @view(model_data.field_buffer[:, :, 1, 1]),
        @view(model_data.field_buffer[:, :, 2, 1]),
        model_data.states.truth, 
        model_data.model_matrices,
        model_data.model_params
    )
    # Get observation from true synthetic wavefield
    get_obs!(
        model_data.observations, 
        model_data.states.truth, 
        model_data.model_params, 
        model_data.station_grid_indices
    )
    return model_data.observations
end

function ParticleDA.get_observation_mean_given_state!(
    state::AbstractVector, model_data::ModelData
)
    return get_obs!(
        model_data.observation_buffer[:, threadid()], 
        reshape(
            state, 
            (
                model_data.model_params.nx, 
                model_data.model_params.ny, 
                model_data.model_params.n_state_var
            )
        ), 
        model_data.model_params, 
        model_data.station_grid_indices
    )
end

function ParticleDA.sample_observations_given_particles!(
    simulated_observations::AbstractMatrix, model_data::ModelData
)
    Threads.@threads for p in 1:size(simulated_observations, 2)
        simulated_observations[:, p] = ParticleDA.get_observation_mean_given_state(
            @view(model_data.states.particles[:, :, :, p]),
            model_data
        )
        add_noise!(
            @view(simulated_observations[:, p]), 
            model_data.rng, 
            model_data.cov_observation_noise,
        )
    end
    return simulated_observations
end

function ParticleDA.get_log_density_observation_given_state(
    observation::AbstractVector, 
    state::AbstractVector, 
    model_data::ModelData,
)
    observation_mean = ParticleDA.get_observation_mean_given_state!(state, model_data)
    return -invquad(model_data.cov_observation_noise, observation - observation_mean) / 2 
end

function ParticleDA.get_log_density_observation_given_previous_state(
    observation::AbstractVector,
    previous_state::AbstractVector,
    model_data::ModelData,
)
    observation_mean = ParticleDA.get_observation_mean_given_state!(previous_state, model_data)
    return -invquad(
        model_data.cov_observation_observation_given_previous_state, 
        observation - observation_mean
    ) / 2 
end


function ParticleDA.update_particle_dynamics!(model_data::ModelData, nprt_per_rank)
    # Update dynamics
    Threads.@threads for p in 1:nprt_per_rank
        tsunami_update!(
            @view(model_data.field_buffer[:, :, 1, threadid()]), 
            @view(model_data.field_buffer[:, :, 2, threadid()]),
            @view(model_data.states.particles[:, :, :, particle_index]), 
            model_data.model_matrices, 
            model_data.model_params
        )
    end
end

function ParticleDA.update_particle_noise!(model_data::ModelData, nprt_per_rank)
    # Add state noise
    add_random_field!(
        model_data.states.particles,
        model_data.field_buffer,
        model_data.state_noise_grf,
        model_datad.rng,
        model_data.model_params.n_state_var,
        nprt_per_rank
    )
end

### Model IO

function write_params(output_filename, params)

    file = h5open(output_filename, "cw")

    if !haskey(file, params.title_params)

        group = create_group(file, params.title_params)

        fields = fieldnames(typeof(params));

        for field in fields

            attributes(group)[string(field)] = getfield(params, field)

        end

    else

        @warn "Write failed, group " * params.title_params * " already exists in " * file.filename * "!"

    end

    close(file)

end

function write_grid(output_filename, params)

    h5open(output_filename, "cw") do file

        if !haskey(file, params.title_grid)

            # Write grid axes
            group = create_group(file, params.title_grid)
            x,y = get_axes(params)
            #TODO: use d_write instead of create_dataset when they fix it in the HDF5 package
            ds_x,dtype_x = create_dataset(group, "x", collect(x))
            ds_y,dtype_x = create_dataset(group, "y", collect(x))
            ds_x[1:params.nx] = collect(x)
            ds_y[1:params.ny] = collect(y)
            attributes(ds_x)["Unit"] = "m"
            attributes(ds_y)["Unit"] = "m"

        else

            @warn "Write failed, group " * params.title_grid * " already exists in " * file.filename * "!"

        end

    end

end

function write_stations(
    output_filename, station_grid_indices::AbstractMatrix, params::ModelParameters
) where T

    h5open(output_filename, "cw") do file

        if !haskey(file, params.title_stations)
            group = create_group(file, params.title_stations)
            x = (station_grid_indices[:, 1] .- 1) .* params.dx
            y = (station_grid_indices[:, 2] .- 1) .* params.dy
            for (dataset_name, val) in zip(("x", "y"), (x, y))
                ds, dtype = create_dataset(group, dataset_name, val)
                ds[:] = val
                attributes(ds)["Description"] = "Station "*dataset_name*" coordinate"
                attributes(ds)["Unit"] = "m"
            end
        else
            @warn "Write failed, group " * params.title_stations * " already exists in " * file.filename * "!"
        end
    end
end

function write_weights(file::HDF5.File, weights::AbstractVector, unit::String, it::Int, params::ModelParameters)

    group_name = "weights"
    dataset_name = "t" * lpad(string(it),4,'0')

    group, subgroup = ParticleDA.create_or_open_group(file, group_name)

    if !haskey(group, dataset_name)
        #TODO: use d_write instead of create_dataset when they fix it in the HDF5 package
        ds,dtype = create_dataset(group, dataset_name, weights)
        ds[:] = weights
        attributes(ds)["Description"] = "Particle Weights"
        attributes(ds)["Unit"] = unit
        attributes(ds)["Time step"] = it
        attributes(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end

end

function ParticleDA.write_snapshot(output_filename::AbstractString,
                                   model_data::ModelData,
                                   avg::AbstractArray{T},
                                   var::AbstractArray{T},
                                   weights::AbstractVector{T},
                                   it::Int) where T

    if it == 0
        # These are written only at the initial state it == 0
        write_grid(output_filename, model_data.model_params)
        write_params(output_filename, model_data.model_params)
        write_stations(
            output_filename, model_data.station_grid_indices, model_data.model_params
        )
    end

    if any(d.model_params.particle_dump_time .== it)
        write_particles(
            model_data.model_params.particle_dump_file, 
            model_data.states, 
            it, 
            model_data.model_params
        )
    end

    return ParticleDA.write_snapshot(
        output_filename, model_data.states, avg, var, weights, it, model_data.model_params
    )
end

function ParticleDA.write_snapshot(output_filename::AbstractString,
                                   states::StateVectors,
                                   avg::AbstractArray{T},
                                   var::AbstractArray{T},
                                   weights::AbstractVector{T},
                                   it::Int,
                                   params::ModelParameters) where T

    println("Writing output at timestep = ", it)
    
    truth = reshape(states.truth, (params.nx, params.ny, params.n_state_var, :))
    avg = reshape(avg, (params.nx, params.ny, params.n_state_var, :))
    var = reshape(var, (params.nx, params.ny, params.n_state_var, :))

    h5open(output_filename, "cw") do file

        for (i,(name,desc,unit)) in enumerate(zip(name(states, :truth), description(states, :truth), unit(states, :truth)))

            write_field(file, @view(truth[:,:,i]), it, unit, params.title_syn, name, desc, params)
            write_field(file, @view(avg[:,:,i]), it, unit, params.title_avg, name, desc, params)
            write_field(file, @view(var[:,:,i]), it, "("*unit*")^2", params.title_var, name, desc, params)

        end

        write_weights(file, weights, "", it, params)
    end

end

function write_particles(output_filename::AbstractString,
                         states::StateVectors,
                         it::Int,
                         params::ModelParameters) where T

    println("Writing particle states at timestep = ", it)
    nprt = size(states.particles,4)

    h5open(output_filename, "cw") do file

        for iprt = 1:nprt
            group_name = "particle" * string(iprt)

            for (i,(name,desc,unit)) in enumerate(zip(name(states, :particles), description(states, :particles), unit(states, :particles)))

                write_field(file, @view(states.particles[:,:,i,iprt]), it, unit, group_name, name, desc, params)

            end

        end

    end

end

function write_field(file::HDF5.File,
                     field::AbstractMatrix{T},
                     it::Int,
                     unit::String,
                     group::String,
                     dataset::String,
                     description::String,
                     params::ModelParameters) where T

    group_name = params.state_prefix * "_" * group
    subgroup_name = "t" * lpad(string(it),4,'0')
    dataset_name = dataset

    group, subgroup = ParticleDA.create_or_open_group(file, group_name, subgroup_name)

    if !haskey(subgroup, dataset_name)
        #TODO: use d_write instead of create_dataset when they fix it in the HDF5 package
        ds,dtype = create_dataset(subgroup, dataset_name, field)
        ds[:,:] = field
        attributes(ds)["Description"] = description
        attributes(ds)["Unit"] = unit
        attributes(ds)["Time step"] = it
        attributes(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end
end

end # module
