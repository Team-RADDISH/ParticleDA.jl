module Model

using ParticleDA

using Random, Distributions, Base.Threads, GaussianRandomFields, HDF5
using ParticleDA.Default_params
using DelimitedFiles

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
* `source_size::AbstractFloat` : Initial condition parameter
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
* `particle_dump_file::String:` file name for dump of particle state vectors
* `particle_dump_time::Int: list of (one more more) time steps to dump particle states`
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
    nobs::Int = 4
    station_distance_x::T = 20.0e3
    station_distance_y::T = 20.0e3
    station_boundary_x::T = 150.0e3
    station_boundary_y::T = 150.0e3

    source_size::T = 3.0e4
    bathymetry_setup::T = 3.0e3
    peak_height = 1.0
    peak_position = [floor(Int, nx / 4) * dx, floor(Int, ny / 4) * dy]

    lambda::T = 1.0e4
    nu::T = 2.5
    sigma::T = 1.0

    padding::Int = 100
    primes::Bool = true

    lambda_initial_state::T = 1.0e4
    nu_initial_state::T = 2.5
    sigma_initial_state::T = 10.0

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

    obs_noise_std::T = 1.0

    particle_dump_file = "particle_dump.h5"
    particle_dump_time = [-1]
end


function get_obs!(obs::AbstractVector{T},
                  state::AbstractArray{T,3},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int},
                  params::ModelParameters) where T

    get_obs!(obs,state,params.nx,ist,jst)

end

# Return observation data at stations from given model state
function get_obs!(obs::AbstractVector{T},
                  state::AbstractArray{T,3},
                  nx::Integer,
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int}) where T
    @assert length(obs) == length(ist) == length(jst)

    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        iptr = (jj - 1) * nx + ii
        obs[i] = state[iptr]
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

struct RandomField{F<:GaussianRandomField,X<:AbstractArray,W<:AbstractArray,Z<:AbstractArray}
    grf::F
    xi::X
    w::W
    z::Z
end

struct StateVectors{T<:AbstractArray, S<:AbstractArray}

    particles::T
    truth::S

end

struct ObsVectors{T<:AbstractArray,S<:AbstractArray}

    truth::T
    model::S

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T

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
function init_gaussian_random_field_generator(lambda::T,
                                              nu::T,
                                              sigma::T,
                                              x::AbstractVector{T},
                                              y::AbstractVector{T},
                                              pad::Int,
                                              primes::Bool) where T

    # Let's limit ourselves to two-dimensional fields
    dim = 2

    cov = CovarianceFunction(dim, Matern(lambda, nu, σ = sigma))
    grf = GaussianRandomField(cov, CirculantEmbedding(), x, y, minpadding=pad, primes=primes)
    v = grf.data[1]
    xi = Array{eltype(grf.cov)}(undef, size(v)..., nthreads())
    w = Array{complex(float(eltype(v)))}(undef, size(v)..., nthreads())
    z = Array{eltype(grf.cov)}(undef, length.(grf.pts)..., nthreads())

    return RandomField(grf, xi, w, z)
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
                           generator::RandomField,
                           rng::AbstractVector{<:Random.AbstractRNG},
                           nvar::Int,
                           nprt::Int) where T

    Threads.@threads for ip in 1:nprt

        for ivar in 1:nvar

            sample_gaussian_random_field!(@view(field_buffer[:, :, 1, threadid()]), generator, rng[threadid()])
            # Add the random field only to the height component.
            @view(state[:, :, ivar, ip]) .+= @view(field_buffer[:, :, 1, threadid()])

        end

    end

end

function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, params::ModelParameters) where T

    add_noise!(vec, rng, 0.0, params.obs_noise_std)

end

# Add a (mean, std) normal distributed random number to each element of vec
function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, mean::T, std::T) where T

    d = truncated(Normal(mean, std), 0.0, Inf)
    @. vec += rand((rng,), d)

end


function init_arrays(params::ModelParameters, nprt_per_rank)

    return init_arrays(params.nx, params.ny, params.n_state_var, params.nobs, nprt_per_rank)

end

function init_arrays(nx::Int, ny::Int, n_state_var::Int, nobs::Int, nprt_per_rank::Int)
    # TODO: ideally this will be an argument of the function, to choose a
    # different datatype.
    T = Float64

    state_avg = zeros(T, nx, ny, n_state_var) # average of particle state vectors
    state_var = zeros(T, nx, ny, n_state_var) # variance of particle state vectors

    # Model vector for data assimilation
    #   state[:, :, 1, :]: tsunami height eta(nx,ny)
    #   state[:, :, 2, :]: vertically integrated velocity Mx(nx,ny)
    #   state[:, :, 3, :]: vertically integrated velocity Mx(nx,ny)
    state_particles = zeros(T, nx, ny, n_state_var, nprt_per_rank)
    state_truth = zeros(T, nx, ny, n_state_var) # model vector: true wavefield (observation)
    obs_truth = Vector{T}(undef, nobs)          # observed tsunami height
    obs_model = Matrix{T}(undef, nobs, nprt_per_rank) # forecasted tsunami height

    # station location in digital grids
    ist = Vector{Int}(undef, nobs)
    jst = Vector{Int}(undef, nobs)

    # Buffer array to be used in the tsunami update
    field_buffer = Array{T}(undef, nx, ny, 2, nthreads())

    return StateVectors(state_particles, state_truth), ObsVectors(obs_truth, obs_model), StationVectors(ist, jst), field_buffer
end

function set_initial_state!(states::StateVectors, model_matrices::LLW2d.Matrices{T},
                            field_buffer::AbstractArray{T, 4},
                            rng::AbstractVector{<:Random.AbstractRNG},
                            nprt_per_rank::Int,
                            params::ModelParameters) where T

    # Set true initial state
    LLW2d.initheight!(@view(states.truth[:, :, 1]), model_matrices, params.dx, params.dy,
                      params.source_size, params.peak_height, params.peak_position)

    # Create generator for the initial random field
    x,y = get_axes(params)
    initial_grf = init_gaussian_random_field_generator(params.lambda_initial_state,
                                                       params.nu_initial_state,
                                                       params.sigma_initial_state,
                                                       x,
                                                       y,
                                                       params.padding,
                                                       params.primes)

    # Since states.particles is initially created as `zeros` we don't need to set it to 0 here
    # to get the default behaviour

    if params.particle_initial_state == "true"
        states.particles .= states.truth
    end

    # Add samples of the initial random field to all particles
    add_random_field!(states.particles, field_buffer, initial_grf, rng, params.n_state_var, nprt_per_rank)

end

function set_stations!(stations::StationVectors, params::ModelParameters) where T

    set_stations!(stations.ist,
                  stations.jst,
                  params.station_filename,
                  params.station_distance_x,
                  params.station_distance_y,
                  params.station_boundary_x,
                  params.station_boundary_y,
                  params.dx,
                  params.dy)

end

function set_stations!(ist::AbstractVector, jst::AbstractVector, filename::String, distance_x::T, distance_y::T, boundary_x::T, boundary_y::T, dx::T, dy::T) where T

    if filename != ""
        coords = readdlm(filename, ',', Float64, '\n'; comments=true, comment_char='#')
        ist .= floor.(Int, coords[:,1] / dx)
        jst .= floor.(Int, coords[:,2] / dy)
    else
        LLW2d.set_stations!(ist,jst,distance_x,distance_y,boundary_x,boundary_y,dx,dy)
    end

end

struct ModelData{A,B,C,D,E,F,G,H}
    model_params::A
    states::B
    observations::C
    stations::D
    field_buffer::E
    background_grf::F
    model_matrices::G
    rng::H
end
ParticleDA.get_particles(d::ModelData) = d.states.particles
# TODO: we should probably get rid of `get_truth`: it is only used as return
# value of `particle_filter`, we may just return the whole `model_data`.
ParticleDA.get_truth(d::ModelData) = d.states.truth
ParticleDA.get_stations(d::ModelData) = (nst = d.model_params.nobs,
                                         ist = d.stations.ist,
                                         jst = d.stations.jst)
ParticleDA.get_obs_noise_std(d::ModelData) = d.model_params.obs_noise_std
ParticleDA.get_model_noise_params(d::ModelData) = (sigma = d.model_params.sigma,
                                                   lambda = d.model_params.lambda,
                                                   nu = d.model_params.nu)

function ParticleDA.set_particles!(d::ModelData, particles::AbstractArray{T}) where T

    d.states.particles .= particles

end
ParticleDA.get_grid_size(d::ModelData) = d.model_params.nx,d.model_params.ny
ParticleDA.get_grid_domain_size(d::ModelData) = d.model_params.x_length,d.model_params.y_length
ParticleDA.get_grid_cell_size(d::ModelData) = d.model_params.dx,d.model_params.dy
ParticleDA.get_n_state_var(d::ModelData) = d.model_params.n_state_var

function init(model_params_dict::Dict, nprt_per_rank::Int, my_rank::Integer, rng::Vector{<:Random.AbstractRNG})

    model_params = ParticleDA.get_params(ModelParameters, get(model_params_dict, "llw2d", Dict()))
    states, observations, stations, field_buffer = init_arrays(model_params, nprt_per_rank)

    background_grf = init_gaussian_random_field_generator(model_params)

    # Set up tsunami model
    model_matrices = LLW2d.setup(model_params.nx,
                                 model_params.ny,
                                 model_params.bathymetry_setup,
                                 model_params.absorber_thickness_fraction,
                                 model_params.boundary_damping,
                                 model_params.cutoff_depth)

    set_stations!(stations, model_params)

    set_initial_state!(states, model_matrices, field_buffer, rng, nprt_per_rank, model_params)

    return ModelData(model_params, states, observations, stations, field_buffer, background_grf, model_matrices, rng)
end

function ParticleDA.update_truth!(d::ModelData, _)
    tsunami_update!(@view(d.field_buffer[:, :, 1, 1]),
                    @view(d.field_buffer[:, :, 2, 1]),
                    d.states.truth, d.model_matrices, d.model_params)

    # Get observation from true synthetic wavefield
    get_obs!(d.observations.truth, d.states.truth, d.stations.ist, d.stations.jst, d.model_params)
    return d.observations.truth
end

function ParticleDA.update_particle_dynamics!(d::ModelData, nprt_per_rank)
    # Update dynamics
    Threads.@threads for ip in 1:nprt_per_rank
        tsunami_update!(@view(d.field_buffer[:, :, 1, threadid()]), @view(d.field_buffer[:, :, 2, threadid()]),
                        @view(d.states.particles[:, :, :, ip]), d.model_matrices, d.model_params)
    end
end

function ParticleDA.update_particle_noise!(d::ModelData, nprt_per_rank)
    # Add process noise
    add_random_field!(d.states.particles,
                      d.field_buffer,
                      d.background_grf,
                      d.rng,
                      d.model_params.n_state_var,
                      nprt_per_rank)
end

function ParticleDA.get_particle_observations!(d::ModelData, nprt_per_rank)
    # get observations
    for ip in 1:nprt_per_rank
        get_obs!(@view(d.observations.model[:,ip]),
                 @view(d.states.particles[:, :, :, ip]),
                 d.stations.ist,
                 d.stations.jst,
                 d.model_params)
    end
    return d.observations.model
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

function write_stations(output_filename, ist::AbstractVector, jst::AbstractVector, params::ModelParameters) where T

    h5open(output_filename, "cw") do file

        if !haskey(file, params.title_stations)
            group = create_group(file, params.title_stations)

            for (dataset_name, val) in zip(("x", "y"), (ist .* params.dx, jst .* params.dy))
                ds, dtype = create_dataset(group, dataset_name, val)
                ds[:] = val
                attributes(ds)["Description"] = "Station coordinates"
                attributes(ds)["Unit"] = "m"
            end
        else
            @warn "Write failed, group " * params.title_stations * " already exists in " * file.filename * "!"
        end
    end
end

function write_weights(file::HDF5.File, weights::AbstractVector, unit::String, it::Int, params::ModelParameters)

    group_name = "weights"
    dataset_name = "t" * string(it)

    group, subgroup = ParticleDA.create_or_open_group(file, group_name)

    if !haskey(group, dataset_name)
        #TODO: use d_write instead of create_dataset when they fix it in the HDF5 package
        ds,dtype = create_dataset(group, dataset_name, weights)
        ds[:] = weights
        attributes(ds)["Description"] = "Particle Weights"
        attributes(ds)["Unit"] = unit
        attributes(ds)["Time_step"] = it
        attributes(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end

end

function ParticleDA.write_snapshot(output_filename::AbstractString,
                                   truth::AbstractArray{T,3},
                                   avg::AbstractArray{T,3},
                                   var::AbstractArray{T,3},
                                   weights::AbstractVector{T},
                                   it::Int,
                                   params::ModelParameters) where T

    println("Writing output at timestep = ", it)

    h5open(output_filename, "cw") do file

        dset_height = "height"
        dset_vx = "vx"
        dset_vy = "vy"

        desc_height = "Ocean surface height"
        desc_vx = "Ocean surface velocity x-component"
        desc_vy = "Ocean surface velocity y-component"

        write_field(file, @view(truth[:,:,1]), it, "m", params.title_syn, dset_height, desc_height, params)
        write_field(file, @view(avg[:,:,1]), it, "m"  , params.title_avg, dset_height, desc_height, params)
        write_field(file, @view(var[:,:,1]), it, "m^2", params.title_var, dset_height, desc_height, params)

        write_field(file, @view(truth[:,:,2]), it, "m/s",   params.title_syn, dset_vx, desc_vx, params)
        write_field(file, @view(avg[:,:,2]), it, "m/s"  ,   params.title_avg, dset_vx, desc_vx, params)
        write_field(file, @view(var[:,:,2]), it, "m^2/s^2", params.title_var, dset_vx, desc_vx, params)

        write_field(file, @view(truth[:,:,3]), it, "m/s",   params.title_syn, dset_vy, desc_vy, params)
        write_field(file, @view(avg[:,:,3]), it, "m/s"  ,   params.title_avg, dset_vy, desc_vy, params)
        write_field(file, @view(var[:,:,3]), it, "m^2/s^2", params.title_var, dset_vy, desc_vy, params)

        write_weights(file, weights, "", it, params)
    end

end

function write_particles(output_filename::AbstractString,
                         particles::AbstractArray{T,4},
                         it::Int,
                         params::ModelParameters) where T

    println("Writing particle states at timestep = ", it)
    nprt = size(particles,4)

    h5open(output_filename, "cw") do file

        dset_height = "height"
        dset_vx = "vx"
        dset_vy = "vy"

        desc_height = "Ocean surface height"
        desc_vx = "Ocean surface velocity x-component"
        desc_vy = "Ocean surface velocity y-component"

        for iprt = 1:nprt
            group_name = "particle" * string(iprt)

            write_field(file, @view(particles[:,:,1,iprt]), it, "m", group_name, dset_height, desc_height, params)
            write_field(file, @view(particles[:,:,2,iprt]), it, "m/s", group_name, dset_vx, desc_vx, params)
            write_field(file, @view(particles[:,:,3,iprt]), it, "m/s", group_name, dset_vy, desc_vy, params)

        end

    end

end

function ParticleDA.write_snapshot(output_filename::AbstractString,
                                   d::ModelData,
                                   avg::AbstractArray{T,3},
                                   var::AbstractArray{T,3},
                                   weights::AbstractVector{T},
                                   it::Int) where T

    if it == 0
        # These are written only at the initial state it == 0
        write_grid(output_filename, d.model_params)
        write_params(output_filename, d.model_params)
        write_stations(output_filename, d.stations.ist, d.stations.jst, d.model_params)
    end

    if any(d.model_params.particle_dump_time .== it)
        write_particles(d.model_params.particle_dump_file, d.states.particles, it, d.model_params)
    end

    return ParticleDA.write_snapshot(output_filename, d.states.truth, avg, var, weights, it, d.model_params)
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
    subgroup_name = "t" * string(it)
    dataset_name = dataset

    group, subgroup = ParticleDA.create_or_open_group(file, group_name, subgroup_name)

    if !haskey(subgroup, dataset_name)
        #TODO: use d_write instead of create_dataset when they fix it in the HDF5 package
        ds,dtype = create_dataset(subgroup, dataset_name, field)
        ds[:,:] = field
        attributes(ds)["Description"] = description
        attributes(ds)["Unit"] = unit
        attributes(ds)["Time_step"] = it
        attributes(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end
end

end # module
