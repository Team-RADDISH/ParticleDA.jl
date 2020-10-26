module LLW2d

using ParticleDA

using Random, Distributions, Base.Threads, GaussianRandomFields, HDF5
using ParticleDA.Default_params
using DelimitedFiles
import Future

include("llw2d.jl")

Base.@kwdef struct ModelParameters{T<:AbstractFloat}

    nx::Int = 200
    ny::Int = 200
    x_length::T = 400.0e3
    y_length::T = 400.0e3
    dx::T = x_length / nx
    dy::T = y_length / ny

    n_state_var::Int = 3

    time_step::T = 50.0
    n_integration_step::Int = 50

    random_seed::Int = 12345

    station_filename::String = ""
    nobs::Int = 4
    station_distance_x::T = 20.0e3
    station_distance_y::T = 20.0e3
    station_boundary_x::T = 150.0e3
    station_boundary_y::T = 150.0e3

    source_size::T = 3.0e4
    bathymetry_setup::T = 3.0e4

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

    # TODO: this parameter is also in the filter
    obs_noise_std::T = 1.0

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
    LLW2d.initheight!(@view(states.truth[:, :, 1]), model_matrices, params.dx, params.dy, params.source_size)

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

function init(model_params_dict::Dict, nprt_per_rank::Int, my_rank::Integer, _rng::Union{Random.AbstractRNG,Nothing}=nothing)

    model_params = ParticleDA.get_params(ModelParameters, get(model_params_dict, "llw2d", Dict()))
    states, observations, stations, field_buffer = init_arrays(model_params, nprt_per_rank)

    rng = let
        m = if isnothing(_rng)
            Random.MersenneTwister(model_params.random_seed + my_rank)
        else
            _rng
        end
        [m; accumulate(Future.randjump, fill(big(10)^20, nthreads()-1), init=m)]
    end

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

function ParticleDA.update_truth!(d::ModelData)
    tsunami_update!(@view(d.field_buffer[:, :, 1, 1]),
                    @view(d.field_buffer[:, :, 2, 1]),
                    d.states.truth, d.model_matrices, d.model_params)

    # Get observation from true synthetic wavefield
    get_obs!(d.observations.truth, d.states.truth, d.stations.ist, d.stations.jst, d.model_params)
    return d.observations.truth
end

function ParticleDA.update_particles!(d::ModelData, nprt_per_rank)
    Threads.@threads for ip in 1:nprt_per_rank
        tsunami_update!(@view(d.field_buffer[:, :, 1, threadid()]), @view(d.field_buffer[:, :, 2, threadid()]),
                        @view(d.states.particles[:, :, :, ip]), d.model_matrices, d.model_params)

    end
    add_random_field!(d.states.particles,
                      d.field_buffer,
                      d.background_grf,
                      d.rng,
                      d.model_params.n_state_var,
                      nprt_per_rank)

    # Add process noise, get observations, add observation noise (to particles)
    for ip in 1:nprt_per_rank
        get_obs!(@view(d.observations.model[:,ip]),
                 @view(d.states.particles[:, :, :, ip]),
                 d.stations.ist,
                 d.stations.jst,
                 d.model_params)
        add_noise!(@view(d.observations.model[:,ip]), d.rng[1], d.model_params)
    end
    return d.observations.model
end


### Model IO

function write_params(output_filename, params)

    file = h5open(output_filename, "cw")

    if !exists(file, params.title_params)

        group = g_create(file, params.title_params)

        fields = fieldnames(typeof(params));

        for field in fields

            attrs(group)[string(field)] = getfield(params, field)

        end

    else

        @warn "Write failed, group " * params.title_params * " already exists in " * file.filename * "!"

    end

    close(file)

end

function write_grid(output_filename, params)

    h5open(output_filename, "cw") do file

        if !exists(file, params.title_grid)

            # Write grid axes
            group = g_create(file, params.title_grid)
            x,y = get_axes(params)
            #TODO: use d_write instead of d_create when they fix it in the HDF5 package
            ds_x,dtype_x = d_create(group, "x", collect(x))
            ds_y,dtype_x = d_create(group, "y", collect(x))
            ds_x[1:params.nx] = collect(x)
            ds_y[1:params.ny] = collect(y)
            attrs(ds_x)["Unit"] = "m"
            attrs(ds_y)["Unit"] = "m"

        else

            @warn "Write failed, group " * params.title_grid * " already exists in " * file.filename * "!"

        end

    end

end

function write_stations(output_filename, ist::AbstractVector, jst::AbstractVector, params::ModelParameters) where T

    h5open(output_filename, "cw") do file

        if !exists(file, params.title_stations)
            group = g_create(file, params.title_stations)

            for (dataset_name, index, d) in zip(("x", "y"), (ist, jst), (params.dx, params.dy))
                ds, dtype = d_create(group, dataset_name, index)
                ds[:] = index .* d
                attrs(ds)["Description"] = "Station coordinates"
                attrs(ds)["Unit"] = "m"
            end
        else
            @warn "Write failed, group " * params.title_stations * " already exists in " * file.filename * "!"
        end
    end
end

function write_weights(file::HDF5File, weights::AbstractVector, unit::String, it::Int, params::ModelParameters)

    group_name = "weights"
    dataset_name = "t" * string(it)

    group, subgroup = ParticleDA.create_or_open_group(file, group_name)

    if !exists(group, dataset_name)
        #TODO: use d_write instead of d_create when they fix it in the HDF5 package
        ds,dtype = d_create(group, dataset_name, weights)
        ds[:] = weights
        attrs(ds)["Description"] = "Particle Weights"
        attrs(ds)["Unit"] = unit
        attrs(ds)["Time_step"] = it
        attrs(ds)["Time (s)"] = it * params.time_step
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

    return ParticleDA.write_snapshot(output_filename, d.states.truth, avg, var, weights, it, d.model_params)
end

function write_field(file::HDF5File,
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

    if !exists(subgroup, dataset_name)
        #TODO: use d_write instead of d_create when they fix it in the HDF5 package
        ds,dtype = d_create(subgroup, dataset_name, field)
        ds[:,:] = field
        attrs(ds)["Description"] = description
        attrs(ds)["Unit"] = unit
        attrs(ds)["Time_step"] = it
        attrs(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end
end

end # module
