include("llw2d.jl")

using .LLW2d
using .Default_params

function get_obs!(obs::AbstractVector{T},
                  state::AbstractArray{T,3},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int},
                  params::Parameters) where T

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
                         params::Parameters) where T

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
    buffer::T
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

function get_axes(params::Parameters)

    return get_axes(params.nx, params.ny, params.dx, params.dy)

end

function get_axes(nx::Int, ny::Int, dx::Real, dy::Real)

    x = range(0, length=nx, step=dx)
    y = range(0, length=ny, step=dy)

    return x,y
end

function init_gaussian_random_field_generator(params::Parameters)

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

function add_random_field!(state::AbstractArray{T,4},
                           field_buffer::AbstractArray{T,4},
                           generator::RandomField,
                           rng::AbstractVector{<:Random.AbstractRNG},
                           params::Parameters) where T

    add_random_field!(state, field_buffer, generator, rng, params.n_state_var, params.nprt)

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

function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, params::Parameters) where T

    add_noise!(vec, rng, 0.0, params.obs_noise_std)

end

# Add a (mean, std) normal distributed random number to each element of vec
function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, mean::T, std::T) where T

    d = truncated(Normal(mean, std), 0.0, Inf)
    @. vec += rand((rng,), d)

end


function init_arrays(params::Parameters, nprt_per_rank)

    return init_arrays(params.nx, params.ny, params.n_state_var, params.nobs, nprt_per_rank, params.master_rank)

end

function init_arrays(nx::Int, ny::Int, n_state_var::Int, nobs::Int, nprt_per_rank::Int, master_rank::Int = 0)
    # TODO: ideally this will be an argument of the function, to choose a
    # different datatype.
    T = Float64

    state_avg = zeros(T, nx, ny, n_state_var) # average of particle state vectors
    state_var = zeros(T, nx, ny, n_state_var) # variance of particle state vectors
    state_resampled = Array{T,4}(undef, nx, ny, n_state_var, nprt_per_rank)

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

    return StateVectors(state_particles, state_resampled, state_truth), ObsVectors(obs_truth, obs_model), StationVectors(ist, jst), field_buffer
end

function set_initial_state!(states::StateVectors, model_matrices::LLW2d.Matrices{T},
                            field_buffer::AbstractArray{T, 4},
                            rng::AbstractVector{<:Random.AbstractRNG},
                            nprt_per_rank::Int,
                            params::Parameters) where T

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

function set_stations!(stations::StationVectors, params::Parameters) where T

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

struct ModelData{A,B,C,D,E,F,G}
    states::A
    observations::B
    stations::C
    field_buffer::D
    background_grf::E
    model_matrices::F
    rng::G
end
get_particles(d::ModelData) = d.states.particles
# TODO: we should probably get rid of the next two functions and find other ways
# to pass them around.  `get_truth` is only used as return value of
# `particle_filter`, we may just return the whole `model_data`.
get_buffer(d::ModelData) = d.states.buffer
get_truth(d::ModelData) = d.states.truth
function write_initial_state(d::ModelData, weights, params)
    write_grid(params)
    write_params(params)
    write_stations(d.stations.ist, d.stations.jst, params)
    unpack_statistics!(d.avg_arr, d.var_arr, d.statistics)
    write_snapshot(d.states.truth, d.avg_arr, d.var_arr, weights, 0, params)
end

function init(params::Parameters, rng::AbstractVector{<:Random.AbstractRNG}, nprt_per_rank::Int)
    states, observations, stations, field_buffer = init_arrays(params, nprt_per_rank)

    background_grf = init_gaussian_random_field_generator(params)

    # Set up tsunami model
    model_matrices = LLW2d.setup(params.nx,
                                 params.ny,
                                 params.bathymetry_setup,
                                 params.absorber_thickness_fraction,
                                 params.boundary_damping,
                                 params.cutoff_depth)

    set_stations!(stations, params)

    set_initial_state!(states, model_matrices, field_buffer, rng, nprt_per_rank, params)

    return ModelData(states, observations, stations, field_buffer, background_grf, model_matrices, rng)
end

function update_truth!(d::ModelData, params)
    tsunami_update!(@view(d.field_buffer[:, :, 1, 1]),
                    @view(d.field_buffer[:, :, 2, 1]),
                    d.states.truth, d.model_matrices, params)

    # Get observation from true synthetic wavefield
    get_obs!(d.observations.truth, d.states.truth, d.stations.ist, d.stations.jst, params)
    return d.observations.truth
end

function update_particles!(d::ModelData, nprt_per_rank, params)
    Threads.@threads for ip in 1:nprt_per_rank
        tsunami_update!(@view(d.field_buffer[:, :, 1, threadid()]), @view(d.field_buffer[:, :, 2, threadid()]),
                        @view(d.states.particles[:, :, :, ip]), d.model_matrices, params)

    end
    add_random_field!(d.states.particles,
                      d.field_buffer,
                      d.background_grf,
                      d.rng,
                      params.n_state_var,
                      nprt_per_rank)

    # Add process noise, get observations, add observation noise (to particles)
    for ip in 1:nprt_per_rank
        get_obs!(@view(d.observations.model[:,ip]),
                 @view(d.states.particles[:, :, :, ip]),
                 d.stations.ist,
                 d.stations.jst,
                 params)
    add_noise!(@view(d.observations.model[:,ip]), d.rng[1], params)
    end
    return d.observations.model
end
