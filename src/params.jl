module Default_params

export tdac_params

"""
tdac_params()

Parameters for TDAC run. Arguments:

* `nx` : number of grid points in the x direction
* `ny` : number of grid points in the y direction
* `dim_grid` : Grid size
* `dim_state` : State vector size (height, velocity_x, velocity_y) at each grid point
* `dx` : Distance (m) between grid points in the x direction
* `dy` : Distance (m) between grid points in the y direction
* `nobs` : Number of observation stations
* `station_separation` : Distance between stations in station_dx/dx grid points
* `station_boundary` : Distance between bottom left edge of box and first station in station_dx/dx grid points
* `station_dx` : Scaling factor for distance between stations in the x direction
* `station_dy` : Scaling factor for distance between stations in the y direction
* `ntmax` : Number of time steps
* `dt` : Time step length (unit?)
* `verbose` : Flag to write output
* `title_da` : Prefix of the output files of the average particle state
* `title_ syn` : Prefix of the output files of the true state
* `ntdec` : Number of time steps between output writes
* `nprt` : Number of particles for particle filter
* `da_period` : Number of time steps between particle resamplings
* `rr` : Length scale for covariance decay
* `inv_rr` : Inverse of length scale, stored for performance
* `source_size` : Initial condition parameter
* `bathymetry_setup` : Bathymetry set-up.
* `lambda` : Length scale for Matérn covariance kernel (could be same as rr)
* `nu` : Smoothess parameter for Matérn covariance kernel
* `sigma` : Marginal standard deviation for Matérn covariance kernel
* `padding` : Min padding for circulant embedding gaussian random field generator
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
    group_prefix::String = "data"
    title_da::String = "da"
    title_syn::String = "syn"
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
    obs_noise_amplitude::T = 1.0

    random_seed::Int = 12345
end

end
