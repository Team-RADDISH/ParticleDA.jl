"""
    FilterParameters()

Parameters for ParticleDA run. Keyword arguments:

* `master_rank` : Id of MPI rank that performs serial computations
* `verbose::Bool` : Flag to control whether to write output
* `output_filename::String` : Name of output file
* `nprt::Int` : Number of particles for particle filter
* `enable_timers::Bool` : Flag to control run time measurements
* `particle_save_time_indices`: Set of time indices to save particles at
* `seed`: Seed to initialise state of random number generator used for filtering
* `n_tasks`: Number of tasks to use for running parallelisable operations. Positive
   integers indicate the number of tasks directly, while the absolute value of negative
   integers indicate the number of task to use per-thread (as reported by 
   `Threads.nthreads()`). Using multiple tasks per thread will improve the ability of
   the scheduler to balance load across threads but potentially increase overheads.
   If simulation of the model being filtered use multiple threads then it may be 
   beneficial to set the `n_tasks = 1` to avoid too much contention between threads.
"""
Base.@kwdef struct FilterParameters{V<:Union{AbstractSet, AbstractVector}}
    master_rank::Int = 0
    verbose::Bool = false
    output_filename::String = "particle_da.h5"
    timer_output::String = "timers.h5"
    nprt::Int = 4
    nprt_per_rank::Union{Nothing, Int} = nothing
    enable_timers::Bool = false
    particle_save_time_indices::V = []
    seed::Union{Nothing, Int} = nothing
    n_tasks::Int = -1
end


# Initialise params struct with user-defined dict of values.
function get_params(T, user_input_dict::Dict)

    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = T(;user_input...)

end

get_params(user_input_dict::Dict) = get_params(FilterParameters, user_input_dict)

# Initialise params struct with default values
get_params() = FilterParameters()
