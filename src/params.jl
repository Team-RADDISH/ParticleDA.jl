"""
    FilterParameters()

Parameters for ParticleDA run. Keyword arguments:

* `master_rank` : Id of MPI rank that performs serial computations
* `verbose::Bool` : Flag to control whether to write output
* `output_filename::String` : Name of output file
* `nprt::Int` : Number of particles for particle filter
* `particle_save_time_indices`: Set of time indices to save particles at
* `seed`: Seed to initialise state of random number generator used for filtering
"""
Base.@kwdef struct FilterParameters{V<:Union{AbstractSet, AbstractVector}}
    master_rank::Int = 0
    verbose::Bool = false
    output_filename::String = "particle_da.h5"
    nprt::Int = 4
    particle_save_time_indices::V = []
    seed::Union{Nothing, Int} = nothing
end


# Initialise params struct with user-defined dict of values.
function get_params(T, user_input_dict::Dict)

    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = T(;user_input...)

end

get_params(user_input_dict::Dict) = get_params(FilterParameters, user_input_dict)

# Initialise params struct with default values
get_params() = FilterParameters()
