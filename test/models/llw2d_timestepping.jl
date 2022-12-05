# Linear Long Wave (LLW) tsunami in 2D Cartesian Coordinate

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


function timestep!(dx_buffer::AbstractMatrix{T},
                   dy_buffer::AbstractMatrix{T},
                   eta1::AbstractMatrix{T},
                   mm1::AbstractMatrix{T},
                   nn1::AbstractMatrix{T},
                   eta0::AbstractMatrix{T},
                   mm0::AbstractMatrix{T},
                   nn0::AbstractMatrix{T},
                   absorbing_boundary::AbstractMatrix{T},
                   x_averaged_depth::AbstractMatrix{T},
                   y_averaged_depth::AbstractMatrix{T},
                   land_filter_m::AbstractMatrix{T},
                   land_filter_n::AbstractMatrix{T},
                   land_filter_e::AbstractMatrix{T},
                   dx::Real,dy::Real,dt::Real) where T
    nx, ny = size(eta1)
    @assert (nx, ny) == size(mm1) == size(nn1) == size(eta0) == size(mm0) ==
        size(nn0) == size(x_averaged_depth) == size(y_averaged_depth) ==
        size(land_filter_m) == size(land_filter_n) == size(land_filter_e) ==
        size(absorbing_boundary)

    # diffs
    for j in 1:ny
        for i in 2:nx
            @inbounds dx_buffer[i,j] = (eta0[i,j] - eta0[i - 1,j]) / dx
        end
        @inbounds dx_buffer[1,j] = (eta0[1,j] - 0) / dx
    end
    for i in 1:nx
        for j in 2:ny
            @inbounds dy_buffer[i,j] = (eta0[i,j] - eta0[i, j - 1]) / dy
        end
        @inbounds dy_buffer[i,1] = (eta0[i,1] - 0) / dy
    end

    # Update Velocity
    for j in 1:ny, i in 1:nx
        @inbounds mm1[i,j] = mm0[i, j] - g_n * x_averaged_depth[i, j] * dx_buffer[i, j] * dt
        @inbounds nn1[i,j] = nn0[i, j] - g_n * y_averaged_depth[i, j] * dy_buffer[i, j] * dt
    end

    # boundary condition
    for j in 1:ny, i in 1:nx
        @inbounds mm1[i, j] = mm1[i, j] * land_filter_m[i, j] * absorbing_boundary[i, j]
        @inbounds nn1[i, j] = nn1[i, j] * land_filter_n[i, j] * absorbing_boundary[i, j]
    end

    # diffs
    for j in 1:ny
        @inbounds dx_buffer[nx, j] = (-mm1[nx, j]) / dx
        for i in 1:(nx-1)
            @inbounds dx_buffer[i, j] = (mm1[i + 1, j] - mm1[i, j]) / dx
        end
    end
    for i in 1:nx
        @inbounds dy_buffer[i, ny] = (-nn1[i, ny]) / dy
        for j in 1:(ny-1)
            @inbounds dy_buffer[i, j] = (nn1[i,j + 1] - nn1[i, j]) / dy
        end
    end

    # Update Wave Heigt
    for j in 1:ny, i in 1:nx
        @inbounds eta1[i, j] = eta0[i, j] - (dx_buffer[i, j] + dy_buffer[i, j]) * dt
    end

    # boundary condition
    for j in 1:ny, i in 1:nx
        @inbounds eta1[i, j] = eta1[i, j] * land_filter_e[i, j] * absorbing_boundary[i, j]
    end
    return eta1, mm1, nn1
end

function timestep!(dx_buffer::AbstractMatrix{T},
                   dy_buffer::AbstractMatrix{T},
                   eta1::AbstractMatrix{T},
                   mm1::AbstractMatrix{T},
                   nn1::AbstractMatrix{T},
                   eta0::AbstractMatrix{T},
                   mm0::AbstractMatrix{T},
                   nn0::AbstractMatrix{T},
                   matrices::Matrices{T},
                   dx::Real,dy::Real,dt::Real) where T
    # Unpack the relevant fields of `matrices`
    return timestep!(dx_buffer, dy_buffer, eta1, mm1, nn1, eta0, mm0, nn0,
                     matrices.absorbing_boundary, matrices.x_averaged_depth,
                     matrices.y_averaged_depth, matrices.land_filter_m,
                     matrices.land_filter_n, matrices.land_filter_e, dx, dy, dt)
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
function get_initial_height(x::T, y::T, peak_x::T, peak_y::T, peak_height::T, cutoff::T) where T

    dx = peak_x - x
    dy = peak_y - y
    distance_to_peak = sqrt(dx^2 + dy^2)

    if distance_to_peak <= cutoff
        return peak_height / 4.0 * ((1 + cospi(dx / cutoff)) * (1 + cospi(dy / cutoff)))
    else
        return 0.0        
    end
    
end

# Initializes the surface height on all points of the grid
function initheight!(height::AbstractMatrix{T},
                     ocean_depth::AbstractMatrix{T},
                     dx::Real,dy::Real,cutoff_distance::Real,
                     peak_height::Real, peak_position::AbstractVector{T}) where T

    @assert size(height) == size(ocean_depth)

    nx, ny = size(height)

    x = (1:nx) .* dx
    y = (1:ny) .* dy

    height .= get_initial_height.(x', y, peak_position[1], peak_position[2], peak_height, cutoff_distance)
    height[ocean_depth .< eps(T)] .= 0.0
    
end

# Initializes the surface height on all points of the grid
function initheight!(height::AbstractMatrix{T},
                     matrices::Matrices{T},
                     dx::Real,dy::Real,cutoff_distance::Real,
                     peak_height::Real, peak_position::AbstractVector{T}) where T
    # Unpack the relevant field of `matrices`
    initheight!(height, matrices.ocean_depth, dx, dy, cutoff_distance, peak_height, peak_position)
end