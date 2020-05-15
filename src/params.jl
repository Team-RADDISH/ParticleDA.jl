module Default_params

export tdac_params

"""
tdac_params()

Parameters for TDAC run. Arguments:

* `nx::Int` : Number of grid points in the x direction
* `ny::Int` : Number of grid points in the y direction
* `n_state_var::Int`: Number of variables in the state vector
* `dim_grid::Int` : Grid size
* `dim_state::Int` : State vector size (height, velocity_x, velocity_y) at each grid point
* `dx::AbstractFloat` : Distance (m) between grid points in the x direction
* `dy::AbstractFloat` : Distance (m) between grid points in the y direction
* `nobs::Int` : Number of observation stations
* `station_separation::Int` : Distance between stations in station_dx/dx grid points
* `station_boundary::Int` : Distance between bottom left edge of box and first station in station_dx/dx grid points
* `station_dx::AbstractFloat` : Scaling factor for distance between stations in the x direction
* `station_dy::AbstractFloat` : Scaling factor for distance between stations in the y direction
* `ntmax::Int` : Number of time steps
* `dt::AbstractFloat` : Time step length (unit?)
* `verbose::Bool` : Flag to control whether to write output
* `output_filename::String` : Name of output file
* `state_prefix::String` : Prefix of the time slice data groups in output
* `title_da::String` : Suffix of the data assimilated data group in output
* `title_syn::String` : Suffix of the true state data group in output
* `title_grid::String` : Name of the grid data group in output
* `title_params::String` : Name of the parameters data group in output
* `ntdec::Int` : Number of time steps between output writes in output
* `nprt::Int` : Number of particles for particle filter
* `da_period::Int` : Number of time steps between particle resamplings
* `rr::AbstractFloat` : Length scale for covariance decay
* `inv_rr::AbstractFloat` : Inverse of length scale, stored for performance
* `source_size::AbstractFloat` : Initial condition parameter
* `bathymetry_setup::AbstractFloat` : Bathymetry set-up.
* `lambda::AbstractFloat` : Length scale for Matérn covariance kernel (could be same as rr)
* `nu::AbstractFloat` : Smoothess parameter for Matérn covariance kernel
* `sigma::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel
* `padding::Int` : Min padding for circulant embedding gaussian random field generator
* `primes::Int`: Whether the size of the minimum circulant embedding of the covariance matrix can be written as a product of small primes (2, 3, 5 and 7). Default is `true`.
* `obs_noise_amplitude`: Multiplier for noise added to observations of the true state
* `random_seed` : Seed number for the pseudorandom number generator
"""
Base.@kwdef struct tdac_params{T<:AbstractFloat}

    nx::Int = 200
    ny::Int = 200

    n_state_var::Int = 3
    dim_grid::Int = nx * ny
    dim_state::Int = n_state_var * dim_grid
    dx::T = 2.0e3
    dy::T = 2.0e3

    nobs::Int = 4
    station_separation::Int = 20
    station_boundary::Int = 150
    station_dx::T = 1.0e3
    station_dy::T = 1.0e3
    
    ntmax::Int = 500
    dt::T = 1.0
    verbose::Bool = false

    output_filename::String = "tdac.h5"
    state_prefix::String = "data"
    title_avg::String = "avg"
    title_var::String = "var"
    title_syn::String = "syn"
    title_grid::String = "grid"
    title_params::String = "params"
    ntdec::Int = 50

    nprt::Int = 4
    da_period::Int = 50
    rr::T = 2.0e4
    inv_rr::T = 1.0/rr

    source_size::T = 3.0e4
    bathymetry_setup::T = 3.0e4

    lambda::T = 1.0e4
    nu::T = 2.5
    sigma::T = 1.0
    padding::Int = 100
    primes::Bool = true
    obs_noise_amplitude::T = 1.0

    random_seed::Int = 12345
end

end
