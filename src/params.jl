module Default_params

export FilterParameters

"""
    Parameters()

Parameters for ParticleDA run. Keyword arguments:

* `master_rank` : Id of MPI rank that performs serial computations
* `n_time_step::Int` : Number of time steps. On each time step we update the forward model forecast, get model observations, and weight and resample particles.
* `verbose::Bool` : Flag to control whether to write output
* `output_filename::String` : Name of output file
* `nprt::Int` : Number of particles for particle filter
* `enable_timers::Bool` : Flag to control run time measurements
"""
Base.@kwdef struct FilterParameters

    master_rank::Int = 0

    n_time_step::Int = 20
    verbose::Bool = false

    output_filename::String = "particle_da.h5"

    nprt::Int = 4

    enable_timers::Bool = false

end

end
