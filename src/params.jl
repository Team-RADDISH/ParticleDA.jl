module Default_params

export tdac_params

"Parameters for TDAC run"
Base.@kwdef struct tdac_params{T<:AbstractFloat}

    "number of grid points in the x direction"
    nx::Int = 200
    "number of grid points in the y direction"
    ny::Int = 200
    "Grid size"
    dim_grid::Int = nx * ny
    "State vector size (height, velocity_x, velocity_y) at each grid point"
    dim_state::Int = 3 * dim_grid
    "Distance (m) between grid points in the x direction"
    dx::T = 2.0e3
    "Distance (m) between grid points in the y direction"
    dy::T = 2.0e3

    "Number of observation stations"
    nobs::Int = 4
    "Distance between stations in station_dx/dx grid points"
    station_separation::Int = 20
    "Distance between bottom left edge of box and first station in station_dx/dx grid points"
    station_boundary::Int = 150
    "Scaling factor for distance between stations in the x direction"
    station_dx::T = 1.0e3
    "Scaling factor for distance between stations in the y direction"
    station_dy::T = 1.0e3
    
    "Number of time steps"
    ntmax::Int = 500
    "Time step length (unit?)"
    dt::T = 1.0
    "Flag to write output"
    verbose::Bool = false

    "Prefix of the output files of the average particle state"
    title_da::String = "da"
    "Prefix of the output files of the true state"
    title_syn::String = "syn"
    "Number of time steps between output writes"
    ntdec::Int = 50

    "Number of particles for particle filter"
    nprt::Int = 4
    "Number of time steps between particle resamplings"
    da_period::Int = 50
    "Length scale for covariance decay"
    rr::T = 2.0e4
    "Inverse of length scale, stored for performance"
    inv_rr::T = 1.0/rr

    "Initial condition parameter"
    source_size::T = 3.0e4
    "Bathymetry set-up."
    bathymetry_setup::T = 3.0e4
end

end
