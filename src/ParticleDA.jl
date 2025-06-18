module ParticleDA

using Random
using Statistics
using MPI
using Base.Threads
using YAML
using HDF5
using TimerOutputs
using LinearAlgebra
using PDMats
using StructArrays
using ChunkSplitters
using Test

export run_particle_filter, simulate_observations_from_model
export BootstrapFilter, OptimalFilter
export MeanSummaryStat, MeanAndVarSummaryStat, NaiveMeanSummaryStat, NaiveMeanAndVarSummaryStat

include("params.jl")
include("io.jl")
include("models.jl")
include("statistics.jl")
include("filters.jl")
include("utils.jl")
include("testing.jl")
include("kalman.jl")

using .Kalman

"""
    simulate_observations_from_model(
        init_model, input_file_path, output_file_path; rng=Random.TaskLocalRNG()
    ) -> Matrix
    
Simulate observations from the state space model initialised by the `init_model`
function with parameters specified by the `model` key in the input YAML file at 
`input_file_path` and save the simulated observation and state sequences to a HDF5 file
at `output_file_path`. `rng` is a random number generator to use to generate random
variates while simulating from the model - a seeded random number generator may be
specified to ensure reproducible results.

The input YAML file at `input_file_path` should have a `simulate_observations` key
with value a dictionary with keys `seed` and `n_time_step` corresponding to respectively
the number of time steps to generate observations for from the model and the seed to
use to initialise the state of the random number generator used to simulate the
observations.

The simulated observation sequence is returned as a matrix with columns corresponding to
the observation vectors at each time step.
"""
function simulate_observations_from_model(
    init_model,
    input_file_path::String,
    output_file_path::String; 
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    input_dict = read_input_file(input_file_path)
    model_dict = get(input_dict, "model", Dict())
    model = init_model(model_dict)
    simulate_observations_dict = get(input_dict, "simulate_observations", Dict())
    n_time_step = get(simulate_observations_dict, "n_time_step", 1)
    seed = get(simulate_observations_dict, "seed", nothing)
    Random.seed!(rng, seed)
    h5open(output_file_path, "cw") do output_file
        return simulate_observations_from_model(
            model, n_time_step; output_file, rng
        )
    end
end

function simulate_observations_from_model(
    model, 
    num_time_step::Integer;
    output_file::Union{Nothing, HDF5.File}=nothing,
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    state = Vector{get_state_eltype(model)}(undef, get_state_dimension(model))
    observation_sequence = Matrix{get_observation_eltype(model)}(
        undef, get_observation_dimension(model), num_time_step
    )
    sample_initial_state!(state, model, rng)
    if !isnothing(output_file)
        write_state(output_file, state, 0, "state", model)
    end
    for (time_index, observation) in enumerate(eachcol(observation_sequence))
        update_state_deterministic!(state, model, time_index)
        update_state_stochastic!(state, model, rng)
        sample_observation_given_state!(observation, state, model, rng)
        if !isnothing(output_file)
            write_state(output_file, state, time_index, "state", model)
            write_observation(output_file, observation, time_index, model)
        end
    end
    return observation_sequence
end

"""
    run_particle_filter(
        init_model,
        input_file_path,
        observation_file_path,
        filter_type=BootstrapFilter,
        summary_stat_type=MeanAndVarSummaryStat;
        rng=Random.TaskLocalRNG()
    ) -> Tuple{Matrix, Union{NamedTuple, Nothing}}

Run particle filter. `init_model` is the function which initialise the model,
`input_file_path` is the path to the YAML file with the input parameters.
`observation_file_path` is the path to the HDF5 file containing the observation
sequence to perform filtering for. `filter_type` is the particle filter type to use.  
See [`ParticleFilter`](@ref) for the possible values. `summary_stat_type` is a type 
specifying the summary statistics of the particles to compute at each time step. See 
[`AbstractSummaryStat`](@ref) for the possible values. `rng` is a random number
generator to use to generate random variates while filtering - a seeded random 
number generator may be specified to ensure reproducible results. If running with
multiple threads a thread-safe generator such as `Random.TaskLocalRNG` (the default)
must be used.

Returns a tuple containing the state particles representing an estimate of the filtering
distribution at the final observation time (with each particle a column of the returned
matrix) and a named tuple containing the estimated summary statistics of this final 
filtering distribution. If running on multiple ranks using MPI, the returned states
array will correspond only to the particles local to this rank and the summary
statistics will be returned only on the master rank with all other ranks returning
`nothing` for their second return value.
"""
function run_particle_filter(
    init_model,
    input_file_path::String,
    observation_file_path::String,
    filter_type::Type{<:ParticleFilter}=BootstrapFilter,
    summary_stat_type::Type{<:AbstractSummaryStat}=MeanAndVarSummaryStat;
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)
    MPI.Init()
    # Do I/O on rank 0 only and then broadcast
    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    if my_rank == 0
        input_dict = read_input_file(input_file_path)
        observation_sequence = h5open(
            read_observation_sequence, observation_file_path, "r"
        )
    else
        input_dict = nothing
        observation_sequence = nothing
    end
    input_dict = MPI.bcast(input_dict, 0, MPI.COMM_WORLD)
    observation_sequence = MPI.bcast(observation_sequence, 0, MPI.COMM_WORLD)
    filter_params = get_params(FilterParameters, get(input_dict, "filter", Dict()))
    if !isnothing(filter_params.seed)
        # Use a linear congruential generator to generate different seeds for each rank
        seed = UInt64(filter_params.seed)
        multiplier, increment = 0x5851f42d4c957f2d, 0x14057b7ef767814f
        for _ in 1:my_rank
            # As seed is UInt64 operations will be modulo 2^64
            seed = multiplier * seed + increment  
        end
        # Seed per-rank random number generator
        Random.seed!(rng, seed)
    end
    model_params_dict = get(input_dict, "model", Dict())
    return run_particle_filter(
        init_model, 
        filter_params, 
        model_params_dict,
        observation_sequence,
        filter_type,
        summary_stat_type; 
        rng
    )
end

function run_particle_filter(
    init_model, 
    filter_params::FilterParameters, 
    model_params_dict::Dict,
    observation_sequence::AbstractMatrix,
    filter_type::Type{<:ParticleFilter},
    summary_stat_type::Type{<:AbstractSummaryStat};
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
)

    MPI.Init()

    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
    my_size = MPI.Comm_size(MPI.COMM_WORLD)

    # For now, assume that the particles can be evenly divided between ranks
    @assert mod(filter_params.nprt, my_size) == 0

    nprt_per_rank = Int(filter_params.nprt / my_size)

    if filter_params.enable_timers
        TimerOutputs.enable_debug_timings(ParticleDA)
    end
    timer = TimerOutput()

    # Number of tasks to schedule operations which can be parallelized acoss particles 
    # over - negative n_tasks filter parameter values are assumed to correspond to 
    # number of tasks per thread and we force the maximum number of tasks that can be 
    # set to the number of particles on each rank so that there is at least one
    # particle per task
    n_tasks = min(
        filter_params.n_tasks > 0 
        ? filter_params.n_tasks 
        : Threads.nthreads() * abs(filter_params.n_tasks),
        nprt_per_rank
    )

    # Do memory allocations
    @timeit_debug timer "Model initialization" model = init_model(
        model_params_dict, n_tasks
    )
    
    @timeit_debug timer "State initialization" states = init_states(
        model, nprt_per_rank, n_tasks, rng
    )

    @timeit_debug timer "Filter initialization" filter_data = init_filter(
        filter_params, model, nprt_per_rank, n_tasks, filter_type, summary_stat_type
    )

    @timeit_debug timer "Summary statistics" update_statistics!(
        filter_data.statistics, states, filter_params.master_rank
    )

    # Write initial state (time = 0) + metadata
    if(filter_params.verbose && my_rank == filter_params.master_rank)
        @timeit_debug timer "Unpack statistics" unpack_statistics!(
            filter_data.unpacked_statistics, filter_data.statistics
        )
        @timeit_debug timer "Write snapshot" write_snapshot(
            filter_params.output_filename,
            model,
            filter_data,
            states,
            0,
            0 in filter_params.particle_save_time_indices,
        )
    end

    for (time_index, observation) in enumerate(eachcol(observation_sequence))

        # Sample updated values for particles from proposal distribution and compute
        # unnormalized log weights for each particle in ensemble given observations
        # for current time step
        @timeit_debug timer "Proposals and weights" sample_proposal_and_compute_log_weights!(
            states, 
            @view(filter_data.weights[1:nprt_per_rank]),
            observation,
            time_index,
            model, 
            filter_data, 
            filter_type, 
            rng
        )

        # Gather weights to master rank and resample particles, doing MPI collectives 
        # inplace to save memory allocations.
        # Note that only master_rank allocates memory for all particles. Other ranks 
        # only allocate for their chunk of state.
        if my_rank == filter_params.master_rank
            @timeit_debug timer "Gather weights" MPI.Gather!(
                MPI.IN_PLACE,
                UBuffer(filter_data.weights, nprt_per_rank),
                filter_params.master_rank,
                MPI.COMM_WORLD
            )
            @timeit_debug timer "Normalize weights" normalized_exp!(filter_data.weights)
            @timeit_debug timer "Resample" resample!(
                filter_data.resampling_indices, filter_data.weights, rng
            )

        else
            @timeit_debug timer "Gather weights" MPI.Gather!(
                filter_data.weights, nothing, filter_params.master_rank, MPI.COMM_WORLD
            )
        end

        # Broadcast resampled particle indices to all ranks
        MPI.Bcast!(filter_data.resampling_indices, filter_params.master_rank, MPI.COMM_WORLD)
    
        @timeit_debug timer "Copy states" copy_states!(
            states,
            filter_data.copy_buffer,
            filter_data.resampling_indices,
            my_rank,
            nprt_per_rank,
            timer
        )
                                                      
        if filter_params.verbose
            @timeit_debug timer "Update statistics" update_statistics!(
                filter_data.statistics, states, filter_params.master_rank
            )
        end

        if my_rank == filter_params.master_rank && filter_params.verbose

            @timeit_debug timer "Unpack statistics" unpack_statistics!(
                filter_data.unpacked_statistics, filter_data.statistics
            )
            @timeit_debug timer "Write snapshot" write_snapshot(
                filter_params.output_filename,
                model,
                filter_data,
                states,
                time_index,
                time_index in filter_params.particle_save_time_indices,
            )

        end

    end
    
    if !filter_params.verbose
        # Do final update and unpack of statistics if not performed in filtering loop
        @timeit_debug timer "Update statistics" update_statistics!(
            filter_data.statistics, states, filter_params.master_rank
        )
        if my_rank == filter_params.master_rank
            @timeit_debug timer "Unpack statistics" unpack_statistics!(
                filter_data.unpacked_statistics, filter_data.statistics
            )
        end
    end

    if filter_params.enable_timers

        if my_rank == filter_params.master_rank
            print_timer(timer)
        end

        if filter_params.verbose
            # Gather string representations of timers from all ranks and write them on master
            str_timer = string(timer)

            timer_lengths = MPI.Gather(
                sizeof(str_timer), filter_params.master_rank, MPI.COMM_WORLD
            )

            if my_rank == filter_params.master_rank
                timer_chars = MPI.Gatherv!(
                    str_timer,
                    MPI.VBuffer(Vector{UInt8}(undef, sum(timer_lengths)), timer_lengths),
                    filter_params.master_rank,
                    MPI.COMM_WORLD
                )
                write_timers(timer_lengths, my_size, timer_chars, filter_params)
            else
                MPI.Gatherv!(str_timer, nothing, filter_params.master_rank, MPI.COMM_WORLD)
            end
        end
    end

    return states, filter_data.unpacked_statistics
end

end # module
