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
* `weight_std`: Standard deviation of the distribution of the weights
* `enable_timers::Bool` : Flag to control run time measurements
* `lambda_cov`: Denominator of the exponent term in covariance functionused by Optimal Filter
* `sigma_cov`: Multiplier of the exponential in covariance function used by Optimal Filter
"""
Base.@kwdef struct FilterParameters{T<:AbstractFloat}

    master_rank::Int = 0

    n_time_step::Int = 20
    verbose::Bool = false

    output_filename::String = "particle_da.h5"

    nprt::Int = 4

    weight_std::T = 1.0

    enable_timers::Bool = false

    lambda_cov::T = 1.0
    sigma_cov::T = 1.0

end

end
