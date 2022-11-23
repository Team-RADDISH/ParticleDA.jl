module Default_params

export FilterParameters

"""
    Parameters()

Parameters for ParticleDA run. Keyword arguments:

* `master_rank` : Id of MPI rank that performs serial computations
* `verbose::Bool` : Flag to control whether to write output
* `output_filename::String` : Name of output file
* `nprt::Int` : Number of particles for particle filter
* `enable_timers::Bool` : Flag to control run time measurements
* `particle_save_time_indices: Set of time indices to save particles at
* `seed`: Seed to initialise state of random number generator used for filtering
"""
Base.@kwdef struct FilterParameters{V<:Union{AbstractSet, AbstractVector}}

    master_rank::Int = 0

    verbose::Bool = false

    output_filename::String = "particle_da.h5"

    nprt::Int = 4

    enable_timers::Bool = false
    
    particle_save_time_indices::V = []
    
    seed::Union{Nothing, Int} = nothing

end


end
