module Default_params
using Dates

export FilterParameters

"""
    Parameters()

Parameters for ParticleDA run. Keyword arguments:

* `master_rank` : Id of MPI rank that performs serial computations
* `n_time_step::Int` : Number of time steps. On each time step we update the forward model forecast, get model observations, and weight and resample particles.
* `verbose::Bool` : Flag to control whether to write output
* `output_filename::String` : Name of output file
* `nprt::Int` : Number of particles for particle filter
* `weight_std`: Standard deviation of the distribution of the weights
* `random_seed::Int` : Seed number for the pseudorandom number generator
* `enable_timers::Bool` : Flag to control run time measurements
"""
Base.@kwdef struct FilterParameters{T<:AbstractFloat}

    master_rank::Int = 0

    # n_time_step::Int = 0
    verbose::Bool = false

    output_filename::String = "particle_da.h5"

    nprt::Int = 4

    weight_std::T = 1.0

    random_seed::Int = 12345

    enable_timers::Bool = false

    # Initial date
    IYYYY::Int = 1982
    IMM::Int = 01
    IDD::Int = 01
    IHH::Int = 00

    # Final date
    FYYYY::Int = 1983
    FMM::Int = 03
    FDD::Int = 01
    FHH::Int = 00
    Hinc::Int = 6

    n_time_step::Int = length(DateTime(IYYYY,IMM,IDD,IHH):Hour(Hinc):DateTime(FYYYY,FMM,FDD,FHH))

end

end
