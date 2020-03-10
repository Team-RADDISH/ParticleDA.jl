module Default_params

export tdac_params

Base.@kwdef struct tdac_params{T<:AbstractFloat}

    # Grid parameters
    nx::Int = 200
    ny::Int = 200
    dim_grid::Int = nx * ny
    dim_state::Int = 3 * dim_grid
    dx::T = 2.0e3
    dy::T = 2.0e3

    # Station parameters
    nobs::Int = 4
    station_separation::Int = 20
    station_boundary::Int = 150
    station_dx::T = 1.0e3
    station_dy::T = 1.0e3
    
    # Run parameters
    ntmax::Int = 500
    dt::T = 1.0
    verbose::Bool = false

    # Output parameters
    title_da::String = "da"
    title_syn::String = "syn"
    ntdec::Int = 50

    # DA parameters
    nprt::Int = 4
    da_period::Int = 50
    rr::T = 2.0e4
    inv_rr::T = 1.0/rr

    # Initial values
    source_size::T = 3.0e4
    bathymetry_setup::T = 3.0e4
end

end
