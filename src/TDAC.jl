module TDAC

using Random, Distributions, Statistics, MPI, Base.Threads, YAML, GaussianRandomFields, HDF5
import Future
using TimerOutputs
using DelimitedFiles

export tdac

include("params.jl")
include("llw2d.jl")
include("io.jl")

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

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from independent normal pdfs for each observation.
function get_log_weights!(weight::AbstractVector{T},
                          obs::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          obs_noise_std::T) where T

    nobs = size(obs_model,1)
    @assert size(obs,1) == nobs

    weight .= 1.0

    for iobs = 1:nobs
        weight .+= logpdf.(Normal(obs[iobs], obs_noise_std), @view(obs_model[iobs,:]))
    end

end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from a multivariate normal pdf with mean equal to real observations and covariance equal to cov_obs
function get_log_weights!(weight::AbstractVector{T},
                          obs::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          cov_obs::AbstractMatrix{T}) where T

    weight .= Distributions.logpdf(Distributions.MvNormal(obs, cov_obs), obs_model)

end


#
function normalized_exp!(weight::AbstractVector)

    weight .-= maximum(weight)
    @. weight = exp(weight)
    weight ./= sum(weight)

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
                           params::tdac_params) where T

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
        weights = Vector{T}(undef, nprt_total)
    else
        weights = Vector{T}(undef, nprt_per_rank)
    end

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

    return StateVectors(state_particles, state_resampled, state_truth, state_avg, state_var), ObsVectors(obs_truth, obs_model), StationVectors(ist, jst), weights, field_buffer
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

# Return something that can be MPI_Reduced to a mean
function get_parallel_mean!(avg::AbstractArray{T,3}, particles::AbstractArray{T,4}, mpisize::Int) where T

    Statistics.mean!(avg, particles)
    avg ./= mpisize

end

# Return something that can be MPI_Reduced to a variance
function get_parallel_var!(var::AbstractArray{T,3},
                           particles::AbstractArray{T,4},
                           avg::AbstractArray{T,3},
                           mpisize::Int) where T

    var ./= mpisize

end

function tdac(params::tdac_params, rng::AbstractVector{<:Random.AbstractRNG})

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

        # Set up tsunami model
        #TODO: Put these in a data structure
        gg, hh, hm, hn, fm, fn, fe = LLW2d.setup(params.nx,
                                                 params.ny,
                                                 params.bathymetry_setup,
                                                 params.absorber_thickness_fraction,
                                                 params.boundary_damping,
                                                 params.cutoff_depth)

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
        @timeit_debug timer "IO" write_stations(stations.ist, stations.jst, params)
        @timeit_debug timer "IO" write_snapshot(states.truth, states.avg, states.var, weights, 0, params)
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

        @timeit_debug timer "Weights" get_log_weights!(@view(weights[1:nprt_per_rank]),
                                                         observations.truth,
                                                         observations.model,
                                                         params.obs_noise_std)

        # Gather weights to master rank and resample particles.
        # Doing MPI collectives in place to save memory allocations.
        # This style with if statmeents is recommended instead of MPI.Gather_in_place! which is a bit strange.
        # Note that only master_rank allocates memory for all particles. Other ranks only allocate
        # for their chunk of state.
        if my_rank == params.master_rank
            @timeit_debug timer "MPI Gather" MPI.Gather!(nothing,
                                                         weights,
                                                         nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
            @timeit_debug timer "Weights" normalized_exp!(weights)           
            @timeit_debug timer "Resample" resample!(resampling_indices, weights)
            
        else
            @timeit_debug timer "MPI Gather" MPI.Gather!(weights,
                                                         nothing,
                                                         nprt_per_rank,
                                                         params.master_rank,
                                                         MPI.COMM_WORLD)
        end

        # Broadcast resampled particle indices to all ranks
        MPI.Bcast!(resampling_indices, params.master_rank, MPI.COMM_WORLD)

        @timeit_debug timer "State Copy" begin

            # These are the particle indices stored on this rank
            particles_have = my_rank * nprt_per_rank + 1:(my_rank + 1) * nprt_per_rank

            # These are the particle indices this rank should have after resampling
            particles_want = resampling_indices[particles_have]

            # These are the ranks that have the particles this rank should have
            rank_has = floor.(Int, (particles_want .- 1) / nprt_per_rank)

            # We could work out how many sends and receives we have to do and allocate
            # this appropriately but, lazy
            reqs = Vector{MPI.Request}(undef, 0)

            # for i in 1:my_size
            #     if i == my_rank + 1
            #         @show my_rank
            #         @show collect(particles_have)
            #         @show particles_want
            #         @show rank_has
            #     end
            #     MPI.Barrier(MPI.COMM_WORLD) #For debugging
            # end
        
            # Send particles to processes that want them
            for (k,id) in enumerate(resampling_indices)
                rank_wants = floor(Int, (k - 1) / nprt_per_rank)
                #@show rank_wants
                if id in particles_have && rank_wants != my_rank
                    local_id = id - my_rank * nprt_per_rank
                    #println("sending particle ", id, " with local id ", local_id," from rank ",my_rank," to rank ", rank_wants)
                    req = MPI.Isend(@view(states.particles[:,:,:,local_id]), rank_wants, id, MPI.COMM_WORLD)
                    push!(reqs, req)
                end
            end
        
            # Receive particles this rank wants from ranks that have them
            # If I already have them, just do a local copy
            # Receive into a buffer so we dont accidentally overwrite stuff
            for (k,proc,id) in zip(1:nprt_per_rank, rank_has, particles_want)
                if proc == my_rank
                    local_id = id - my_rank * nprt_per_rank
                    # for i in 1:my_size
                    #     if i == my_rank + 1
                    #         println("copying local particle ",id," from local id ",local_id," to local id ",k," on rank ",my_rank)
                    #     end
                    # end
                    @view(states.buffer[:,:,:,k]) .= @view(states.particles[:,:,:,local_id])
                else
                    #println("receiving particle ", id, " on rank ",my_rank," from rank ", proc)
                    req = MPI.Irecv!(@view(states.buffer[:,:,:,k]), proc, id, MPI.COMM_WORLD)
                    push!(reqs,req)
                end
            end

            # Wait for all comms to complete
            MPI.Waitall!(reqs)

            states.particles .= states.buffer
        end

        @timeit_debug timer "Particle Mean" get_parallel_mean!(states.avg, states.particles, my_size)
        @timeit_debug timer "Particle Variance" get_parallel_var!(states.var, states.particles, states.avg, my_size)

        MPI.Reduce!(states.avg, +, params.master_rank, MPI.COMM_WORLD)
        MPI.Reduce!(states.var, +, params.master_rank, MPI.COMM_WORLD)

        if my_rank == params.master_rank && params.verbose

            # Write output
            @timeit_debug timer "IO" write_snapshot(states.truth, states.avg, states.var, weights, it, params)

        end

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

function tdac(path_to_input_file::String, rng::AbstractRNG)

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

    rng_vec = let m = rng
        [m; accumulate(Future.randjump, fill(big(10)^20, nthreads()-1), init=m)]
    end;

    return tdac(params, rng_vec)

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

function tdac(params::tdac_params)

    if !MPI.Initialized()
        MPI.Init()
    end
    
    rng = let m = Random.MersenneTwister(params.random_seed + MPI.Comm_rank(MPI.COMM_WORLD))
        [m; accumulate(Future.randjump, fill(big(10)^20, nthreads()-1), init=m)]
    end;

    return tdac(params, rng)

end

end # module
