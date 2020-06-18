module TDAC

using Random, Distributions, Statistics, MPI, Base.Threads, YAML, GaussianRandomFields, HDF5
import Future
using TimerOutputs
using DelimitedFiles

export tdac

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

#
function normalized_exp!(weight::AbstractVector)

    weight .-= maximum(weight)
    @. weight = exp(weight)
    weight ./= sum(weight)

end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from independent normal pdfs for each observation.
function get_weights!(weight::AbstractVector{T},
                      obs::AbstractVector{T},
                      obs_model::AbstractMatrix{T},
                      obs_noise_std::T) where T

    nobs = size(obs_model,1)
    @assert size(obs,1) == nobs

    weight .= 1.0

    for iobs = 1:nobs
        weight .+= logpdf.(Normal(obs[iobs], obs_noise_std), @view(obs_model[iobs,:]))
    end

    normalized_exp!(weight)

end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from a multivariate normal pdf with mean equal to real observations and covariance equal to cov_obs
function get_weights!(weight::AbstractVector{T},
                      obs::AbstractVector{T},
                      obs_model::AbstractMatrix{T},
                      cov_obs::AbstractMatrix{T}) where T

    weight .= Distributions.logpdf(Distributions.MvNormal(obs, cov_obs), obs_model)

    normalized_exp!(weight)

end

# Resample particles from given weights using Stochastic Universal Sampling
function resample!(resampled_indices::AbstractVector{Int}, weight::AbstractVector{T}) where T

    nprt = length(weight)
    nprt_inv = 1.0 / nprt
    k = 1

    #TODO: Do we need to sort state by weight here?

    weight_cdf = cumsum(weight)
    u0 = nprt_inv * Random.rand(T)

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

function copy_resampled_state!(state::AbstractArray{T,4}, state_buffer::AbstractArray{T,4}, indices::AbstractVector{Int}) where T

    nprt = size(state, 4)
    @assert length(indices) == nprt

    for ip in 1:nprt
        for is in CartesianIndices(@view(state[:, :, :, 1]))
            state_buffer[CartesianIndex(is, ip)] = state[CartesianIndex(is, indices[ip])]
        end
    end

    state .= state_buffer
    return state

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

function add_random_field!(state::AbstractArray{T,4},
                           field_buffer::AbstractArray{T,4},
                           grf::RandomField,
                           rng::AbstractVector{<:Random.AbstractRNG},
                           params::tdac_params) where T

    add_random_field!(state, field_buffer, grf, rng, params.n_state_var, params.nprt)

end

# Add a gaussian random field to the height in the state vector of all particles
function add_random_field!(state::AbstractArray{T,4},
                           field_buffer::AbstractArray{T,4},
                           grf::RandomField,
                           rng::AbstractVector{<:Random.AbstractRNG},
                           nvar::Int,
                           nprt::Int) where T

    Threads.@threads for ip in 1:nprt

        for ivar in 1:nvar

            sample_gaussian_random_field!(@view(field_buffer[:, :, 1, threadid()]), grf, rng[threadid()])
            # Add the random field only to the height component.
            @view(state[:, :, ivar, ip]) .+= @view(field_buffer[:, :, 1, threadid()])

        end

    end

end

function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, params::tdac_params) where T

    add_noise!(vec, rng, 0.0, params.obs_noise_std)

end

# Add a (mean, std) normal distributed random number to each element of vec
function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, mean::T, std::T) where T

    d = truncated(Normal(mean, std), 0.0, Inf)
    @. vec += rand((rng,), d)

end

function init_tdac(params::tdac_params)

    return init_tdac(params.nx, params.ny, params.n_state_var, params.nobs, params.nprt, params.master_rank)

end

struct StateVectors{T<:AbstractArray, S<:AbstractArray}

    particles::T
    buffer::T
    truth::S
    avg::S
    var::S

end

struct ObsVectors{T<:AbstractArray,S<:AbstractArray}

    truth::T
    model::S

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T

end

function init_tdac(nx::Int, ny::Int, n_state_var::Int, nobs::Int, nprt_total::Int, master_rank::Int = 0)

    # TODO: ideally this will be an argument of the function, to choose a
    # different datatype.
    T = Float64

    nprt_per_rank = Int(nprt_total / MPI.Comm_size(MPI.COMM_WORLD))

    # Do memory allocations

    if MPI.Comm_rank(MPI.COMM_WORLD) == master_rank
        # Model vector for data assimilation
        #   state[:, 1]: tsunami height eta(nx,ny)
        #   state[:, 2]: vertically integrated velocity Mx(nx,ny)
        #   state[:, 3]: vertically integrated velocity Mx(nx,ny)
        state_particles = zeros(T, nx, ny, n_state_var, nprt_total) # model state vectors for particles
        state_avg = zeros(T, nx, ny, n_state_var) # average of particle state vectors
        state_var = zeros(T, nx, ny, n_state_var) # variance of particle state vectors
        state_resampled = Array{T,4}(undef, nx, ny, n_state_var, nprt_total)
        weights = Vector{T}(undef, nprt_total)
    else
        state_particles = zeros(T, nx, ny, n_state_var, nprt_per_rank)

        # The below arrays are not needed on non-master ranks. However, to fit them in the
        # data structures, we define them as 0-size Vectors
        state_avg = Array{T,3}(undef, 0, 0, 0)
        state_var = Array{T,3}(undef, 0, 0, 0)
        state_resampled = Array{T,4}(undef, 0, 0, 0, 0)
        weights = Vector{T}(undef, nprt_per_rank)
    end

    state_truth = zeros(T, nx, ny, n_state_var) # model vector: true wavefield (observation)
    obs_truth = Vector{T}(undef, nobs)          # observed tsunami height
    obs_model = Matrix{T}(undef, nobs, nprt_per_rank) # forecasted tsunami height

    # station location in digital grids
    ist = Vector{Int}(undef, nobs)
    jst = Vector{Int}(undef, nobs)

    # Buffer array to be used in the tsunami update
    field_buffer = Array{T}(undef, nx, ny, 2, nthreads())

    return StateVectors(state_particles, state_resampled, state_truth, state_avg, state_var), ObsVectors(obs_truth, obs_model), StationVectors(ist, jst), weights, field_buffer
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

function write_stations(stations::StationVectors, params::tdac_params) where T

    h5open(params.output_filename, "cw") do file

        if !exists(file, params.title_stations)
            group = g_create(file, params.title_stations)

            for (dataset_name, index, d) in zip(("x", "y"), (stations.ist, stations.jst), (params.dx, params.dy))
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


function write_snapshot(states::StateVectors, weights::AbstractVector{T}, it::Int, params::tdac_params) where T

    if params.verbose
        println("Writing output at timestep = ", it)
    end

    h5open(params.output_filename, "cw") do file

        write_surface_height(file, states.truth, "m", it, params.title_syn, params)
        write_surface_height(file, states.avg, "m", it, params.title_avg, params)
        write_surface_height(file, states.var, "m^2", it, params.title_var, params)
        write_weights(file, weights, "", it, params)
    end

end

function write_weights(file::HDF5File, weights::AbstractVector, unit::String, it::Int, params::tdac_params)

    group_name = "weights"
    dataset_name = "t" * string(it)

    if !exists(file, group_name)
        group = g_create(file, group_name)
    else
        group = g_open(file, group_name)
    end

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

function write_surface_height(file::HDF5File, state::AbstractArray{T,3}, unit::String, it::Int, title::String, params::tdac_params) where T

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
        attrs(ds)["Unit"] = unit
        attrs(ds)["Time_step"] = it
        attrs(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end

end



function write_timers(length::Int, size::Int, chars::AbstractVector{Char}, params::tdac_params)

    write_timers(length, size, chars, params.output_filename)

end

function write_timers(length::Int, size::Int, chars::AbstractVector{Char}, filename::String)

    group_name = "timer"

    h5open(filename, "cw") do file

        if !exists(file, group_name)
            group = g_create(file, group_name)
        else
            group = g_open(file, group_name)
        end

        for i in 1:size
            timer_string = String(chars[(i - 1) * length + 1 : i * length])
            dataset_name = "rank" * string(i-1)

            if !exists(group, dataset_name)
                ds,dtype = d_create(group, dataset_name, timer_string)
                write(ds,timer_string)
            else
                @warn "Write failed, dataset " * group_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
            end
        end
    end
end

function set_initial_state!(states::StateVectors, hh::AbstractMatrix, field_buffer::AbstractArray{T, 4}, rng::AbstractVector{<:Random.AbstractRNG}, nprt_per_rank::Int, params::tdac_params) where T

    # Set true initial state
    LLW2d.initheight!(@view(states.truth[:, :, 1]), hh, params.dx, params.dy, params.source_size)

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

function set_stations!(stations::StationVectors, params::tdac_params) where T

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

function tdac(params::tdac_params)

    if !MPI.Initialized()
        MPI.Init()
    end

    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    my_size = MPI.Comm_size(MPI.COMM_WORLD)

    # For now, assume that the particles can be evenly divided between ranks
    @assert mod(params.nprt, my_size) == 0

    nprt_per_rank = Int(params.nprt / my_size)

    if params.enable_timers
        TimerOutputs.enable_debug_timings(TDAC)
    end
    timer = TimerOutput()

    @timeit_debug timer "Initialization" begin

        states, observations, stations, weights, field_buffer = init_tdac(params)

        background_grf = init_gaussian_random_field_generator(params)

        rng = let m = Random.MersenneTwister(params.random_seed)
            [m; accumulate(Future.randjump, fill(big(10)^20, nthreads()-1), init=m)]
        end;

        # Set up tsunami model
        #TODO: Put these in a data structure
        gg, hh, hm, hn, fm, fn, fe = LLW2d.setup(params.nx, params.ny, params.bathymetry_setup)

        set_stations!(stations, params)

        set_initial_state!(states, hh, field_buffer, rng, nprt_per_rank, params)

        resampling_indices = Vector{Int}(undef,params.nprt)

    end

    # Write initial state + metadata
    if(params.verbose && my_rank == params.master_rank)
        @timeit_debug timer "Particle Mean" Statistics.mean!(states.avg, states.particles)
        @timeit_debug timer "Particle Variance" Statistics.varm!(states.var, states.particles, states.avg)

        @timeit_debug timer "IO" write_grid(params)
        @timeit_debug timer "IO" write_params(params)
        @timeit_debug timer "IO" write_stations(stations, params)
        @timeit_debug timer "IO" write_snapshot(states, weights, 0, params)
    end

    for it in 1:params.n_time_step

        # integrate true synthetic wavefield
        @timeit_debug timer "True State Update" tsunami_update!(@view(field_buffer[:, :, 1, 1]),
                                                                @view(field_buffer[:, :, 2, 1]),
                                                                states.truth, hm, hn, fn, fm, fe, gg, params)

        # Get observation from true synthetic wavefield
        @timeit_debug timer "Observations" get_obs!(observations.truth, states.truth, stations.ist, stations.jst, params)

        # Forecast: Update tsunami forecast and get observations from it
        # Parallelised with threads.

        @timeit_debug timer "Particle State Update" Threads.@threads for ip in 1:nprt_per_rank

            tsunami_update!(@view(field_buffer[:, :, 1, threadid()]), @view(field_buffer[:, :, 2, threadid()]),
                            @view(states.particles[:, :, :, ip]), hm, hn, fn, fm, fe, gg, params)

        end


        @timeit_debug timer "Process Noise" add_random_field!(states.particles,
                                                              field_buffer,
                                                              background_grf,
                                                              rng,
                                                              params.n_state_var,
                                                              nprt_per_rank)

        # Add process noise, get observations, add observation noise (to particles)
        @timeit_debug timer "Observations" for ip in 1:nprt_per_rank
            get_obs!(@view(observations.model[:,ip]),
                     @view(states.particles[:, :, :, ip]),
                     stations.ist,
                     stations.jst,
                     params)
            add_noise!(@view(observations.model[:,ip]), rng[1], params)
        end

        @timeit_debug timer "Weights" get_weights!(@view(weights[1:nprt_per_rank]),
                                                         observations.truth,
                                                         observations.model,
                                                         params.obs_noise_std)

        # Gather all particles and weights to master rank
        # Doing MPI collectives in place to save memory allocations.
        # This style with if statmeents is recommended instead of MPI.Gather_in_place! which is a bit strange.
        # Note that only master_rank allocates memory for all particles. Other ranks only allocate
        # for their chunk of state.
        if my_rank == params.master_rank
            @timeit_debug timer "MPI Gather" MPI.Gather!(nothing,
                                                         @view(states.particles[:]),
                                                         params.nx * params.ny * params.n_state_var * nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
            @timeit_debug timer "MPI Gather" MPI.Gather!(nothing,
                                                         weights,
                                                         nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)

        else
            @timeit_debug timer "MPI Gather" MPI.Gather!(@view(states.particles[:]),
                                                         nothing,
                                                         params.nx * params.ny * params.n_state_var * nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
            @timeit_debug timer "MPI Gather" MPI.Gather!(weights,
                                                         nothing,
                                                         nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
        end

        if my_rank == params.master_rank

            # Weigh and resample particles
            @timeit_debug timer "Resample" resample!(resampling_indices, weights)
            @timeit_debug timer "State Copy" copy_resampled_state!(states.particles, states.buffer, resampling_indices)

            # Scatter the new particles to all ranks. In place similar to gather above.
            @timeit_debug timer "MPI Scatter" MPI.Scatter!(@view(states.particles[:]),
                                                           nothing,
                                                           params.nx * params.ny * params.n_state_var * nprt_per_rank,
                                                           params.master_rank,
                                                           MPI.COMM_WORLD)

            # Calculate statistical quantities
            @timeit_debug timer "Particle Mean" Statistics.mean!(states.avg, states.particles)
            @timeit_debug timer "Particle Variance" Statistics.varm!(states.var, states.particles, states.avg)

            # Write output
            if params.verbose
                @timeit_debug timer "IO" write_snapshot(states, weights, it, params)
            end

        else
            @timeit_debug timer "MPI Scatter" MPI.Scatter!(nothing,
                                                           @view(states.particles[:]),
                                                           params.nx * params.ny * params.n_state_var * nprt_per_rank,
                                                           params.master_rank,
                                                           MPI.COMM_WORLD)
        end
    end

    if my_rank == params.master_rank && params.enable_timers

    end

    if params.enable_timers

        if my_rank == params.master_rank
            print_timer(timer)
        end

        if params.verbose
            # Gather string representations of timers from all ranks and write them on master
            str_timer = string(timer)

            # Assume the length of the timer string on master is the longest (because master does more stuff)
            if my_rank == params.master_rank
                length_timer = length(string(timer))
            else
                length_timer = nothing
            end

            length_timer = MPI.bcast(length_timer, params.master_rank, MPI.COMM_WORLD)

            chr_timer = Vector{Char}(rpad(str_timer,length_timer))

            timer_chars = MPI.Gather(chr_timer, params.master_rank, MPI.COMM_WORLD)

            if my_rank == params.master_rank
                write_timers(length_timer, my_size, timer_chars, params)
            end
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

    if !MPI.Initialized()
        MPI.Init()
    end

    # Do I/O on rank 0 only and then broadcast params
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0

        params = get_params(path_to_input_file)

    else

        params = nothing

    end

    params = MPI.bcast(params, 0, MPI.COMM_WORLD)

    return tdac(params)

end

end # module
