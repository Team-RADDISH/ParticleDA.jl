module ParticleDA

using Distributions, Statistics, MPI, Base.Threads, YAML, HDF5
using TimerOutputs

export run_particle_filter, BootstrapFilter

include("params.jl")
include("io.jl")

using .Default_params

# Functions to extend in the model
"""
    ParticleDA.get_particle(model_data) -> particles

Return the vector of particles.  This method is intended to be extended by the
user with the above signature, specifying the type of `model_data`.
"""
function get_particles end

"""
    ParticleDA.get_truth(model_data) -> truth_observations

Return the vector of true observations.  This method is intended to be extended
by the user with the above signature, specifying the type of `model_data`.
"""
function get_truth end

"""
    ParticleDA.update_truth!(model_data, nprt_per_rank::Int) -> truth_observations

Update the true observations using the dynamic of the model and return the
vector of the true observations.  `nprt_per_rank` is the number of particles per
each MPI rank.  This method is intended to be extended by the user with the
above signature, specifying the type of `model_data`.
"""
function update_truth! end

"""
    ParticleDA.update_particles!(model_data, nprt_per_rank::Int) -> particles_observations

Update the particles using the dynamic of the model and return the vector of the
particles.  `nprt_per_rank` is the number of particles per each MPI rank.  This
method is intended to be extended by the user with the above signature,
specifying the type of `model_data`.
"""
function update_particles! end

"""
    ParticleDA.write_snapshot(output_filename, model_data, avg_arr, var_arr, weights, it)

Write a snapshot of the data after an update of the particles to the HDF5 file
`output_filename`.  `avg_arr` is the array of the mean of the particles,
`var_arr` is the array of the standard deviation of the particles, `weights` is
the array of the weigths of the particles, `it` is the index of the time step
(`it==0` is the initial state, before moving forward the model for the first
time).  This method is intended to be extended by the user with the above
signature, specifying the type of `model_data`.
"""
function write_snapshot end

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from independent normal pdfs for each observation.
function get_log_weights!(weight::AbstractVector{T},
                          obs::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          weight_std::T) where T

    nobs = size(obs_model,1)
    @assert size(obs,1) == nobs

    weight .= 1.0

    for iobs = 1:nobs
        weight .+= logpdf.(Normal(obs[iobs], weight_std), @view(obs_model[iobs,:]))
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
    u0 = nprt_inv * rand(T)

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

function get_mean_and_var!(statistics::Array{SummaryStat{T},3},
                           particles::AbstractArray{T,4},
                           master_rank::Int) where T

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

function copy_states!(particles::AbstractArray{T,4},
                      buffer::AbstractArray{T,4},
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
            req = MPI.Isend(@view(particles[:,:,:,local_id]), rank_wants, id, MPI.COMM_WORLD)
            push!(reqs, req)
        end
    end

    # Receive particles this rank wants from ranks that have them
    # If I already have them, just do a local copy
    # Receive into a buffer so we dont accidentally overwrite stuff
    for (k,proc,id) in zip(1:nprt_per_rank, rank_has, particles_want)
        if proc == my_rank
            local_id = id - my_rank * nprt_per_rank
            @view(buffer[:,:,:,k]) .= @view(particles[:,:,:,local_id])
        else
            req = MPI.Irecv!(@view(buffer[:,:,:,k]), proc, id, MPI.COMM_WORLD)
            push!(reqs,req)
        end
    end

    # Wait for all comms to complete
    MPI.Waitall!(reqs)

    particles .= buffer

end

struct BootstrapFilter end

function run_particle_filter(init, filter_params::FilterParameters, model_params_dict::Dict, ::Type{BootstrapFilter})

    if !MPI.Initialized()
        MPI.Init()
    end

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
    @timeit_debug timer "Model initialization" model_data = init(model_params_dict, nprt_per_rank, my_rank)

    # TODO: put the body of this block in a function
    @timeit_debug timer "Filter initialization" begin
        # TODO: ideally this will be an argument of the function, to choose a
        # different datatype.
        T = Float64

        if MPI.Comm_rank(MPI.COMM_WORLD) == filter_params.master_rank
            weights = Vector{T}(undef, filter_params.nprt)
        else
            weights = Vector{T}(undef, nprt_per_rank)
        end

        resampling_indices = Vector{Int}(undef, filter_params.nprt)

        # TODO: these variables should be set in a better way
        nx, ny, n_state_var = model_data.model_params.nx, model_data.model_params.ny, model_data.model_params.n_state_var

        statistics = Array{SummaryStat{T}, 3}(undef, nx, ny, n_state_var)
        avg_arr = Array{T,3}(undef, nx, ny, n_state_var)
        var_arr = Array{T,3}(undef, nx, ny, n_state_var)

        # Memory buffer used during copy of the states
        copy_buffer = Array{T}(undef, nx, ny, n_state_var, nprt_per_rank)
    end

    @timeit_debug timer "get_particles" particles = get_particles(model_data)
    @timeit_debug timer "Mean and Var" get_mean_and_var!(statistics, particles, filter_params.master_rank)

    # Write initial state (time = 0) + metadata
    if(filter_params.verbose && my_rank == filter_params.master_rank)
        @timeit_debug timer "IO" begin
            unpack_statistics!(avg_arr, var_arr, statistics)
            write_snapshot(filter_params.output_filename, model_data, avg_arr, var_arr, weights, 0)
        end
    end

    for it in 1:filter_params.n_time_step

        # integrate true synthetic wavefield
        @timeit_debug timer "True State Update and Process Noise" truth_observations = update_truth!(model_data, nprt_per_rank)

        # Forecast: Update tsunami forecast and get observations from it
        # Parallelised with threads.

        @timeit_debug timer "Particle State Update and Process Noise" model_observations = update_particles!(model_data, nprt_per_rank)

        @timeit_debug timer "Weights" get_log_weights!(@view(weights[1:nprt_per_rank]),
                                                       truth_observations,
                                                       model_observations,
                                                       filter_params.weight_std)

        # Gather weights to master rank and resample particles.
        # Doing MPI collectives in place to save memory allocations.
        # This style with if statmeents is recommended instead of MPI.Gather_in_place! which is a bit strange.
        # Note that only master_rank allocates memory for all particles. Other ranks only allocate
        # for their chunk of state.
        if my_rank == filter_params.master_rank
            @timeit_debug timer "MPI Gather" MPI.Gather!(nothing,
                                                         weights,
                                                         nprt_per_rank,
                                                         filter_params.master_rank,
                                                         MPI.COMM_WORLD)
            @timeit_debug timer "Weights" normalized_exp!(weights)
            @timeit_debug timer "Resample" resample!(resampling_indices, weights)

        else
            @timeit_debug timer "MPI Gather" MPI.Gather!(weights,
                                                         nothing,
                                                         nprt_per_rank,
                                                         filter_params.master_rank,
                                                         MPI.COMM_WORLD)
        end

        # Broadcast resampled particle indices to all ranks
        MPI.Bcast!(resampling_indices, filter_params.master_rank, MPI.COMM_WORLD)

        @timeit_debug timer "get_particles" particles = get_particles(model_data)
        @timeit_debug timer "State Copy" copy_states!(particles, copy_buffer, resampling_indices, my_rank, nprt_per_rank)

        @timeit_debug timer "get_particles" particles = get_particles(model_data)
        @timeit_debug timer "Mean and Var" get_mean_and_var!(statistics, particles, filter_params.master_rank)

        if my_rank == filter_params.master_rank && filter_params.verbose

            @timeit_debug timer "IO" begin
                unpack_statistics!(avg_arr, var_arr, statistics)
                write_snapshot(filter_params.output_filename, model_data, avg_arr, var_arr, weights, it)
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

            # Assume the length of the timer string on master is the longest (because master does more stuff)
            if my_rank == filter_params.master_rank
                length_timer = length(string(timer))
            else
                length_timer = nothing
            end

            length_timer = MPI.bcast(length_timer, filter_params.master_rank, MPI.COMM_WORLD)

            chr_timer = Vector{Char}(rpad(str_timer,length_timer))

            timer_chars = MPI.Gather(chr_timer, filter_params.master_rank, MPI.COMM_WORLD)

            if my_rank == filter_params.master_rank
                @timeit_debug timer "IO" write_timers(length_timer, my_size, timer_chars, filter_params)
            end
        end
    end

    unpack_statistics!(avg_arr, var_arr, statistics)

    return get_truth(model_data), avg_arr, var_arr
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
    run_particle_filter(init, path_to_input_file::String)

Run the particle filter.  `init` is the function which initialise the model,
`path_to_input_file` is the path to the YAML file with the input parameters.
"""
function run_particle_filter(init, path_to_input_file::String, filter_type)

    if !MPI.Initialized()
        MPI.Init()
    end

    # Do I/O on rank 0 only and then broadcast params
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0

        user_input_dict = read_input_file(path_to_input_file)

    else

        user_input_dict = nothing

    end

    user_input_dict = MPI.bcast(user_input_dict, 0, MPI.COMM_WORLD)

    return run_particle_filter(init, user_input_dict, filter_type)

end

"""
    run_particle_filter(init, user_input_dict::Dict)

Run the particle filter.  `init` is the function which initialise the model,
`user_input_dict` is the list of input parameters, as a `Dict`.
"""
function run_particle_filter(init, user_input_dict::Dict, filter_type)

    filter_params = get_params(FilterParameters, get(user_input_dict, "filter", Dict()))
    model_params_dict = get(user_input_dict, "model", Dict())

    return run_particle_filter(init, filter_params, model_params_dict, filter_type)

end

end # module
