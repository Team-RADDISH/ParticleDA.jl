module SPEEDY

# All these functions need to be updated to accommodate the SPEEDY model

<<<<<<< HEAD
struct Matrices{T,M<:Array{T,3}, N<:Array{T,2}}
    u0::M
    v0::M
    T0::M
    q0::M
    ps0::N
    rain0::N
end
function setup(nx::Int,
               ny::Int,
               nz::Int,
               T::DataType = Float64)
    # Memory allocation
    u = ones(T, nx, ny, nz)
    # u = reshape(u, nx, ny, nz)
    v = ones(T, nx, ny, nz)
    # v = reshape(v, nx, ny, nz)
    Temp = ones(T, nx, ny, nz)
    # Temp = reshape(Temp, nx, ny, nz)
    q = ones(T, nx, ny, nz)
    # q = reshape(q, nx, ny, nz)
    ps = ones(T, nx, ny)
    rain = ones(T, nx, ny)

    return Matrices(u,v,Temp,q,ps,rain)
end

=======
struct Matrices{T,M<:AbstractMatrix{T}}
    absorbing_boundary::M
    ocean_depth::M
    x_averaged_depth::M
    y_averaged_depth::M
    land_filter_m::M
    land_filter_n::M
    land_filter_e::M
end

const g_n = 9.80665

# Set station locations.
function set_stations!(ist::AbstractVector{Int},
                       jst::AbstractVector{Int},
                       station_distance_x::T,
                       station_distance_y::T,
                       station_boundary_x::T,
                       station_boundary_y::T,
                       dx::T,
                       dy::T) where T
    # synthetic station locations
    nst = 0

    # let's check ist and jst have a square number of elements before computing n
    @assert mod(sqrt(length(ist)),1.0) ≈ 0
    @assert mod(sqrt(length(jst)),1.0) ≈ 0
    n = floor(Int, sqrt(length(ist)))

    @inbounds for i in 1:n, j in 1:n
        nst += 1
        ist[nst] = floor(Int, (station_boundary_x + (i - 1) * station_distance_x) / dx)
        jst[nst] = floor(Int, (station_boundary_y + (j - 1) * station_distance_y) / dy)
    end
end


function setup(nx::Int,
               ny::Int,
               bathymetry_val::Real,
               absorber_thickness_fraction::Real,
               apara::Real,
               cutoff_depth::Real,
               T::DataType = Float64)
    # Memory allocation
    ocean_depth = Matrix{T}(undef, nx, ny)
    x_averaged_depth = Matrix{T}(undef, nx, ny)
    y_averaged_depth = Matrix{T}(undef, nx, ny)
    absorbing_boundary = ones(T, nx, ny)
    land_filter_m = ones(T, nx, ny) # land filters
    land_filter_n = ones(T, nx, ny) # "
    land_filter_e = ones(T, nx, ny) # "

    nxa = floor(Int, nx * absorber_thickness_fraction)
    nya = floor(Int, nx * absorber_thickness_fraction)

    # Bathymetry set-up. Users may need to modify it
    fill!(ocean_depth, bathymetry_val)
    @inbounds for j in 1:ny, i in 1:nx
        if ocean_depth[i,j] < 0
            ocean_depth[i,j] = 0
        elseif ocean_depth[i,j] < cutoff_depth
            ocean_depth[i,j] = cutoff_depth
        end
    end

    # average bathymetry for staabsorbing_boundaryered-grid computation
    for j in 1:ny
        for i in 2:nx
            x_averaged_depth[i, j] = (ocean_depth[i, j] + ocean_depth[i - 1, j]) / 2
            if ocean_depth[i, j] <= 0 || ocean_depth[i - 1, j] <= 0
                x_averaged_depth[i, j] = 0
            end
        end
        x_averaged_depth[1, j] = ocean_depth[1, j]
    end
    for i in 1:nx
        for j in 2:ny
            y_averaged_depth[i, j] = (ocean_depth[i, j] + ocean_depth[i, j - 1]) / 2
            if ocean_depth[i, j] <= 0 || ocean_depth[i, j - 1] <= 0
                y_averaged_depth[i, j] = 0
            end
        end
        y_averaged_depth[i, 1] = ocean_depth[i, 1]
    end

    # Land filter
    @inbounds for j in 1:ny,i in 1:nx
        (x_averaged_depth[i, j] < 0) && (land_filter_m[i, j] = 0)
        (y_averaged_depth[i, j] < 0) && (land_filter_n[i, j] = 0)
        (ocean_depth[i, j] < 0) && (land_filter_e[i, j] = 0)
    end

    # Sponge absorbing boundary condition by Cerjan (1985)
    @inbounds for j in 1:ny, i in 1:nx
        if i <= nxa
            absorbing_boundary[i, j] *= exp(-((apara * (nxa - i)) ^ 2))
        end
        if i >= nx - nxa + 1
            absorbing_boundary[i, j] *= exp(-((apara * (i - nx + nxa - 1)) ^ 2))
        end
        if j <= nya
            absorbing_boundary[i, j] *= exp(-((apara * (nya - j)) ^ 2))
        end
        if j >= ny - nya + 1
            absorbing_boundary[i, j] *= exp(-((apara * (j - ny + nya - 1)) ^ 2))
        end
    end
    return Matrices(absorbing_boundary, ocean_depth, x_averaged_depth, y_averaged_depth,
                    land_filter_m, land_filter_n, land_filter_e)
end

# Calculates the initial surface height at point x,y
>>>>>>> fd5d2a8 (Addition of speedy files)
end # module
