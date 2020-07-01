module Default_params

export tdac_params

"""
tdac_params()

Parameters for TDAC run. Arguments:

* `nx::Int` : Number of grid points in the x direction
* `ny::Int` : Number of grid points in the y direction
* `x_length::AbstractFloat` : Domain size (m) in the x direction
* `y_length::AbstractFloat` : Domain size (m) in the y direction
* `dx::AbstractFloat` : Distance (m) between grid points in the x direction
* `dy::AbstractFloat` : Distance (m) between grid points in the y direction
* `n_state_var::Int`: Number of variables in the state vector
* `nobs::Int` : Number of observation stations
* `station_filename::String` : Name of input file for station coordinates
* `station_distance_x::Float` : Distance between stations in the x direction [m]
* `station_distance_y::Float` : Distance between stations in the y direction [m]
* `station_boundary_x::Float` : Distance between bottom left edge of box and first station in the x direction [m]
* `station_boundary_y::Float` : Distance between bottom left edge of box and first station in the y direction [m]
* `n_time_step::Int` : Number of time steps. On each time step we update the forward model forecast, get model observations, and weight and resample particles.
* `n_integration_step::Int` : Number of sub-steps to integrate the forward model per time step.
* `time_step::AbstractFloat` : Time step length (s)
* `verbose::Bool` : Flag to control whether to write output
* `output_filename::String` : Name of output file
* `state_prefix::String` : Prefix of the time slice data groups in output
* `title_da::String` : Suffix of the data assimilated data group in output
* `title_syn::String` : Suffix of the true state data group in output
* `title_grid::String` : Name of the grid data group in output
* `title_stations::String` : Name of the station coordinates data group in output
* `title_params::String` : Name of the parameters data group in output
* `nprt::Int` : Number of particles for particle filter
* `source_size::AbstractFloat` : Initial condition parameter
* `bathymetry_setup::AbstractFloat` : Bathymetry set-up.
* `lambda::AbstractFloat` : Length scale for Matérn covariance kernel in background noise
* `nu::AbstractFloat` : Smoothess parameter for Matérn covariance kernel in background noise
* `sigma::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel in background noise
* `lambda_initial_state::AbstractFloat` : Length scale for Matérn covariance kernel in initial state of particles
* `nu_initial_state::AbstractFloat` : Smoothess parameter for Matérn covariance kernel in initial state of particles
* `sigma_initial_state::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel in initial state of particles
* `padding::Int` : Min padding for circulant embedding gaussian random field generator
* `primes::Int`: Whether the size of the minimum circulant embedding of the covariance matrix can be written as a product of small primes (2, 3, 5 and 7). Default is `true`.
* `obs_noise_std`: Standard deviation of noise added to observations of the true state
* `master_rank` : Id of MPI rank that performs serial computations
* `random_seed::Int` : Seed number for the pseudorandom number generator
* `enable_timers::Bool` : Flag to control run time measurements
* `particle_initial_state::String` : Initial state of the particles before noise is added. Possible options are
  * "zero" : initialise height and velocity to 0 everywhere
  * "true" : copy the true initial state
* `absorber_thickness_fraction` : Thickness of absorber for sponge absorbing boundary conditions, fraction of grid size
* `boundary_damping` : damping for boundaries
* `cutoff_depth` : Shallowest water depth
"""
Base.@kwdef struct tdac_params{T<:AbstractFloat}

    master_rank::Int = 0

    nx::Int = 200
    ny::Int = 200
    x_length::T = 400.0e3
    y_length::T = 400.0e3
    dx::T = x_length / nx
    dy::T = y_length / ny

    n_state_var::Int = 3

    station_filename::String = ""
    nobs::Int = 4
    station_distance_x::T = 20.0e3
    station_distance_y::T = 20.0e3
    station_boundary_x::T = 150.0e3
    station_boundary_y::T = 150.0e3

    n_time_step::Int = 20
    n_integration_step::Int = 50
    time_step::T = 50.0
    verbose::Bool = false

    output_filename::String = "tdac.h5"
    state_prefix::String = "data"
    title_avg::String = "avg"
    title_var::String = "var"
    title_syn::String = "syn"
    title_grid::String = "grid"
    title_stations::String = "stations"
    title_params::String = "params"

    nprt::Int = 4

    source_size::T = 3.0e4
    bathymetry_setup::T = 3.0e4

    lambda::T = 1.0e4
    nu::T = 2.5
    sigma::T = 1.0

    padding::Int = 100
    primes::Bool = true
    obs_noise_std::T = 1.0

    lambda_initial_state::T = 1.0e4
    nu_initial_state::T = 2.5
    sigma_initial_state::T = 10.0

    random_seed::Int = 12345
    enable_timers::Bool = false

    particle_initial_state::String = "zero"

    absorber_thickness_fraction::T = 0.1
    boundary_damping::T = 0.015
    cutoff_depth::T = 10.0

end

end
