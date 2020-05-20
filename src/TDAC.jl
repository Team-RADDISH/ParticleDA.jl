module TDAC

using Random, Distributions, Statistics, Base.Threads, YAML, GaussianRandomFields, HDF5
using TimerOutputs

export tdac, main

include("params.jl")
include("llw2d.jl")

using .Default_params
using .LLW2d

# grid-to-grid distance
get_distance(i0, j0, i1, j1, dx, dy) =
    sqrt((float(i0 - i1) * dx) ^ 2 + (float(j0 - j1) * dy) ^ 2)

function get_obs!(obs::AbstractVector{T},
                  state::AbstractArray{T,3},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int},
                  params::tdac_params) where T

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

function get_obs_covariance(ist::AbstractVector{Int},
                            jst::AbstractVector{Int},
                            params::tdac_params)

    return get_obs_covariance(params.nobs, params.inv_rr, params.dx, params.dy, ist, jst)

end

# Observation covariance matrix based on simple exponential decay
function get_obs_covariance(nobs::Int,
                            inv_rr::Real,
                            dx::Real,
                            dy::Real,
                            ist::AbstractVector{Int},
                            jst::AbstractVector{Int})

    @assert nobs == length(ist) == length(jst)
    mu_boo = Matrix{Float64}(undef, nobs, nobs)

    # Estimate background error between stations
    for j in 1:nobs, i in 1:nobs
        # Gaussian correlation function
        dist = get_distance(ist[i], jst[i], ist[j], jst[j], dx, dy)
        mu_boo[i, j] = exp(-(dist * inv_rr) ^ 2)
    end

    return mu_boo
end

function tsunami_update!(dx_buffer::AbstractMatrix{T},
                         dy_buffer::AbstractMatrix{T},
                         state::AbstractArray{T,3},
                         hm::AbstractMatrix{T},
                         hn::AbstractMatrix{T},
                         fm::AbstractMatrix{T},
                         fn::AbstractMatrix{T},
                         fe::AbstractMatrix{T},
                         gg::AbstractMatrix{T},
                         params::tdac_params) where T

    tsunami_update!(dx_buffer, dy_buffer, state, params.n_integration_step,
                    params.dx, params.dy, params.time_step, hm, hn, fm, fn, fe, gg)

end

# Update tsunami wavefield with LLW2d in-place.
function tsunami_update!(dx_buffer::AbstractMatrix{T},
                         dy_buffer::AbstractMatrix{T},
                         state::AbstractArray{T,3},
                         nt::Int,
                         dx::Real,
                         dy::Real,
                         time_interval::Real,
                         hm::AbstractMatrix{T},
                         hn::AbstractMatrix{T},
                         fm::AbstractMatrix{T},
                         fn::AbstractMatrix{T},
                         fe::AbstractMatrix{T},
                         gg::AbstractMatrix{T}) where T

    eta_a = @view(state[:, :, 1])
    mm_a  = @view(state[:, :, 2])
    nn_a  = @view(state[:, :, 3])
    eta_f = @view(state[:, :, 1])
    mm_f  = @view(state[:, :, 2])
    nn_f  = @view(state[:, :, 3])

    dt = time_interval / nt

    for it in 1:nt
        # Parts of model vector are aliased to tsunami heiht and velocities
        LLW2d.timestep!(dx_buffer, dy_buffer, eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, hm, hn, fn, fm, fe, gg, dx, dy, dt)
    end

end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from a multivariate normal pdf with mean equal to real observations and covariance equal to observation covariance
function get_weights!(weight::AbstractVector{T},
                      obs::AbstractVector{T},
                      obs_model::AbstractMatrix{T},
                      cov_obs::AbstractMatrix{T}) where T

    weight .= Distributions.pdf(Distributions.MvNormal(obs, cov_obs), obs_model) # TODO: Verify that this works

    weight ./= sum(weight)

end

# Resample particles from given weights using Stochastic Universal Sampling
function resample!(state_resampled::AbstractArray{T,4}, state::AbstractArray{T,4}, weight::AbstractVector{S}) where {T,S}

    nprt = size(state, 4)
    @assert length(weight) == nprt

    nprt_inv = 1.0 / nprt
    k = 1

    #TODO: Do we need to sort state by weight here?

    weight_cdf = cumsum(weight)
    u0 = nprt_inv * Random.rand(S)

    # Note: To parallelise this loop, updates to k and u have to be atomic.
    # TODO: search for better parallel implementations
    for ip in 1:nprt

        u = u0 + (ip - 1) * nprt_inv

        while(u > weight_cdf[k])
            k += 1
        end

        for is in CartesianIndices(@view(state[:, :, :, 1]))
            state_resampled[CartesianIndex(is, ip)] = state[CartesianIndex(is, k)]
        end

    end

end

function get_axes(params::tdac_params)

    return get_axes(params.nx, params.ny, params.dx, params.dy)

end

function get_axes(nx::Int, ny::Int, dx::Real, dy::Real)

    x = range(0, length=nx, step=dx)
    y = range(0, length=ny, step=dy)

    return x,y
end

struct RandomField{F<:GaussianRandomField,X<:AbstractArray,W<:AbstractArray,Z<:AbstractArray}
    grf::F
    xi::X
    w::W
    z::Z
end

function init_gaussian_random_field_generator(params::tdac_params)

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
    xi = Array{eltype(grf.cov)}(undef, size(v))
    w = Array{complex(float(eltype(v)))}(undef, size(v))
    z = Array{eltype(grf.cov)}(undef, length.(grf.pts))

    return RandomField(grf, xi, w, z)
end

# Get a random sample from gaussian random field grf using random number generator rng
function sample_gaussian_random_field!(field::AbstractMatrix{T},
                                       grf::RandomField,
                                       rng::Random.AbstractRNG) where T

    @. grf.xi = randn((rng,), T)
    sample_gaussian_random_field!(field, grf, grf.xi)

end

# Get a random sample from gaussian random field grf using random_numbers
function sample_gaussian_random_field!(field::AbstractMatrix{T},
                                       grf::RandomField,
                                       random_numbers::AbstractArray{T}) where T

    field .= GaussianRandomFields._sample!(grf.w, grf.z, grf.grf, random_numbers)

end

function add_random_field!(state::AbstractArray{T,3},
                           field_buffer::AbstractMatrix{T},
                           grf::RandomField,
                           rng::Random.AbstractRNG,
                           params::tdac_params) where T

    add_random_field!(state, field_buffer, grf, rng, params.n_state_var, params.nx, params.ny)

end

# Add a gaussian random field to each variable in the state vector of one particle
function add_random_field!(state::AbstractArray{T,3},
                           field_buffer::AbstractMatrix{T},
                           grf::RandomField,
                           rng::Random.AbstractRNG,
                           nvar::Int,
                           nx::Int,
                           ny::Int) where T

    for ivar in 1:nvar

        sample_gaussian_random_field!(field_buffer, grf, rng)
        @view(state[:, :, nvar]) .+= field_buffer

    end

end

function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, params::tdac_params) where T

    add_noise!(vec, rng, params.obs_noise_amplitude)

end

# Add a (0,1) normal distributed random number, scaled by amplitude, to each element of vec
function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, amplitude::T) where T

    @. vec += amplitude * randn((rng,), T)

end

function init_tdac(params::tdac_params)

    return init_tdac(params.nx, params.ny, params.n_state_var, params.nobs, params.nprt)

end

struct StateVectors{T<:AbstractArray, S<:AbstractArray}

    particles::T
    truth::S
    avg::S
    var::S
    resampled::T

end

struct ObsVectors{T<:AbstractArray,S<:AbstractArray}

    truth::T
    model::S

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T

end

function init_tdac(nx::Int, ny::Int, n_state_var::Int, nobs::Int, nprt::Int)

    # Do memory allocations

    # Model vector for data assimilation
    #   state[:, 1]: tsunami height eta(nx,ny)
    #   state[:, 2]: vertically integrated velocity Mx(nx,ny)
    #   state[:, 3]: vertically integrated velocity Mx(nx,ny)
    state_particles = zeros(Float64, nx, ny, n_state_var, nprt) # model state vectors for particles
    state_truth = zeros(Float64, nx, ny, n_state_var) # model vector: true wavefield (observation)
    state_avg = zeros(Float64, nx, ny, n_state_var) # average of particle state vectors
    state_var = zeros(Float64, nx, ny, n_state_var) # variance of particle state vectors
    state_resampled = Array{Float64,4}(undef, nx, ny, n_state_var, nprt)

    obs_truth = Vector{Float64}(undef, nobs)        # observed tsunami height
    obs_model = Matrix{Float64}(undef, nobs, nprt) # forecasted tsunami height

    # station location in digital grids
    ist = Vector{Int}(undef, nobs)
    jst = Vector{Int}(undef, nobs)

    weights = Vector{Float64}(undef, nprt)

    return StateVectors(state_particles, state_truth, state_avg, state_var, state_resampled), ObsVectors(obs_truth, obs_model), StationVectors(ist, jst), weights
end

function write_params(params)

    file = h5open(params.output_filename, "cw")

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

function write_grid(params)

    h5open(params.output_filename, "cw") do file

        if !exists(file, params.title_grid)

            # Write grid axes
            x,y = get_axes(params)
            group = g_create(file, params.title_grid)
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

function write_snapshot(states::StateVectors, it::Int, params::tdac_params) where T

    if params.verbose
        println("Writing output at timestep = ", it)
    end

    h5open(params.output_filename, "cw") do file

        write_surface_height(file, states.truth, it, params.title_syn, params)
        write_surface_height(file, states.avg, it, params.title_avg, params)
        write_surface_height(file, states.var, it, params.title_var, params)

    end

end

function write_surface_height(file::HDF5File, state::AbstractArray{T,3}, it::Int, title::String, params::tdac_params) where T

    group_name = params.state_prefix * "_" * title
    subgroup_name = "t" * string(it)
    dataset_name = "height"

    if !exists(file, group_name)
        group = g_create(file, group_name)
    else
        group = g_open(file, group_name)
    end

    if !exists(group, subgroup_name)
        subgroup = g_create(group, subgroup_name)
    else
        subgroup = g_open(group, subgroup_name)
    end

    if !exists(subgroup, dataset_name)
        #TODO: use d_write instead of d_create when they fix it in the HDF5 package
        ds,dtype = d_create(subgroup, dataset_name, @view(state[:, :, 1]))
        ds[:, :] = @view(state[:, :, 1])
        attrs(ds)["Description"] = "Ocean surface height"
        attrs(ds)["Unit"] = "m"
        attrs(ds)["Time_step"] = it
        attrs(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end

end

function tdac(params::tdac_params)

    if params.enable_timers
        TimerOutputs.enable_debug_timings(TDAC)
    end
    timer = TimerOutput()

    if(params.verbose)
        @timeit_debug timer "IO" write_grid(params)
        @timeit_debug timer "IO" write_params(params)
    end

    @timeit_debug timer "Initialization" begin

        states, observations, stations, weights = init_tdac(params)

        background_grf = init_gaussian_random_field_generator(params)

        rng = Random.MersenneTwister(params.random_seed)

        #TODO: Put all llw2d setup in one function
        # Set up tsunami model
        #TODO: Put these in a data structure
        gg, hh, hm, hn, fm, fn, fe = LLW2d.setup(params.nx, params.ny, params.bathymetry_setup)

        # obtain initial tsunami height
        eta = @view(states.truth[:, :, 1])
        LLW2d.initheight!(eta, hh, params.dx, params.dy, params.source_size)

        # set station positions
        LLW2d.set_stations!(stations.ist,
                            stations.jst,
                            params.station_separation,
                            params.station_boundary,
                            params.station_dx,
                            params.station_dy,
                            params.dx,
                            params.dy)

        cov_obs = get_obs_covariance(stations.ist, stations.jst, params)

        # Buffer arrays to be used in the tsunami update
        field_buffer_1 = Array{Float64}(undef, params.nx, params.ny, nthreads())
        field_buffer_2 = Array{Float64}(undef, params.nx, params.ny, nthreads())

        # Initialize all particles to the true initial state + noise
        states.particles .= states.truth
        for ip in 1:params.nprt
            add_random_field!(@view(states.particles[:, :, :, ip]), @view(field_buffer_1[:,:,1]), background_grf, rng, params)
        end

    end

    # Write initial state
    if params.verbose
        @timeit_debug timer "IO" write_snapshot(states, 0, params)
    end
    for it in 1:params.n_time_step

        # integrate true synthetic wavefield
        @timeit_debug timer "True State Update" tsunami_update!(@view(field_buffer_1[:, :, 1]), @view(field_buffer_2[:, :, 1]),
                                                                states.truth, hm, hn, fn, fm, fe, gg, params)

        # Forecast: Update tsunami forecast and get observations from it
        # Parallelised with threads.


        @timeit_debug timer "Particle State Update" Threads.@threads for ip in 1:params.nprt

            tsunami_update!(@view(field_buffer_1[:, :, threadid()]), @view(field_buffer_2[:, :, threadid()]),
                            @view(states.particles[:, :, :, ip]), hm, hn, fn, fm, fe, gg, params)

        end

        # Get observation from true synthetic wavefield
        @timeit_debug timer "Observations" get_obs!(observations.truth, states.truth, stations.ist, stations.jst, params)

        # Add process noise, get observations, add observation noise (to particles)
        for ip in 1:params.nprt
            @timeit_debug timer "Process Noise" add_random_field!(@view(states.particles[:, :, :, ip]),
                                                                  @view(field_buffer_1[:,:,1]),
                                                                  background_grf,
                                                                  rng,
                                                                  params)
            @timeit_debug timer "Observations" get_obs!(@view(observations.model[:,ip]),
                                                        @view(states.particles[:, :, :, ip]),
                                                        stations.ist,
                                                        stations.jst,
                                                        params)
            @timeit_debug timer "Observation Noise" add_noise!(@view(observations.model[:,ip]), rng, params)
        end

        # Weigh and resample particles
        @timeit_debug timer "Weights" get_weights!(weights, observations.truth, observations.model, cov_obs)
        @timeit_debug timer "Resample" resample!(states.resampled, states.particles, weights)
        @timeit_debug timer "State Copy" states.particles .= states.resampled

        # Calculate statistical values
        @timeit_debug timer "Particle Mean" Statistics.mean!(states.avg, states.particles)
        @timeit_debug timer "Particle Variance" states.var .= dropdims(Statistics.var(states.particles; dims=4), dims=4)

        # Write output
        if params.verbose
            @timeit_debug timer "IO" write_snapshot(states, it, params)
        end

    end

    if params.enable_timers
        print_timer(timer)
        if params.verbose
            h5write(params.output_filename, "timer/rank0", string(timer))
        end
    end

    return states.truth, states.avg, states.var
end

# Initialise params struct with user-defined dict of values.
function get_params(user_input_dict::Dict)

    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = tdac_params(;user_input...)

end

# Initialise params struct with default values
get_params() = tdac_params()

function get_params(path_to_input_file::String)

    # Read input provided in a yaml file. Overwrite default input parameters with the values provided.
    if isfile(path_to_input_file)
        user_input_dict = YAML.load_file(path_to_input_file)
        params = get_params(user_input_dict)
        if params.verbose
            println("Read input parameters from ",path_to_input_file)
        end
    else
        @warn "Input file " * path_to_input_file * " not found, using default parameters"
        params = get_params()
    end
    return params

end

function tdac(path_to_input_file::String = "")

    params = get_params(path_to_input_file)

    return tdac(params)

end

end # module
