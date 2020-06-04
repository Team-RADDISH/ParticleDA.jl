module LLW2d

# Linear Long Wave (LLW) tsunami in 2D Cartesian Coordinate

const nxa = 20            # absorber thickness
const nya = 20            # absorber thickness
const apara = 0.015       # damping for boundaries
const CUTOFF_DEPTH = 10   # shallowest water depth

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


function timestep!(dx_buffer::AbstractMatrix{T},
                   dy_buffer::AbstractMatrix{T},
                   eta1::AbstractMatrix{T},
                   mm1::AbstractMatrix{T},
                   nn1::AbstractMatrix{T},
                   eta0::AbstractMatrix{T},
                   mm0::AbstractMatrix{T},
                   nn0::AbstractMatrix{T},
                   hm::AbstractMatrix{T},
                   hn::AbstractMatrix{T},
                   fm::AbstractMatrix{T},
                   fn::AbstractMatrix{T},
                   fe::AbstractMatrix{T},
                   gg::AbstractMatrix{T},
                   dx::Real,dy::Real,dt::Real) where T
    nx, ny = size(eta1)
    @assert (nx, ny) == size(mm1) == size(nn1) == size(eta0) == size(mm0) ==
        size(nn0) == size(hm) == size(hn) == size(fm) == size(fn) == size(fe) ==
        size(gg)

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
        @inbounds mm1[i,j] = mm0[i, j] - g_n * hm[i, j] * dx_buffer[i, j] * dt
        @inbounds nn1[i,j] = nn0[i, j] - g_n * hn[i, j] * dy_buffer[i, j] * dt
    end

    # boundary condition
    for j in 1:ny, i in 1:nx
        @inbounds mm1[i, j] = mm1[i, j] * fm[i, j] * gg[i, j]
        @inbounds nn1[i, j] = nn1[i, j] * fn[i, j] * gg[i, j]
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
        @inbounds eta1[i, j] = eta1[i, j] * fe[i, j] * gg[i, j]
    end
    return eta1, mm1, nn1
end

function setup(nx::Int,
               ny::Int,
               bathymetry_val::Real,
               T::DataType = Float64)
    # Memory allocation
    hh = Matrix{T}(undef, nx, ny) # ocean depth
    hm = Matrix{T}(undef, nx, ny) # x-averaged depth
    hn = Matrix{T}(undef, nx, ny) # y-averaged depth
    gg = Matrix{T}(undef, nx, ny) # absorbing boundary
    fm = ones(T, nx, ny) # land filters
    fn = ones(T, nx, ny) # "
    fe = ones(T, nx, ny) # "

    # Bathymetry set-up. Users may need to modify it
    fill!(hh, bathymetry_val)
    @inbounds for j in 1:ny, i in 1:nx
        if hh[i,j] < 0
            hh[i,j] = 0
        elseif hh[i,j] < CUTOFF_DEPTH
            hh[i,j] = CUTOFF_DEPTH
        end
    end

    # average bathymetry for staggered-grid computation
    for j in 1:ny
        for i in 2:nx
            hm[i, j] = (hh[i, j] + hh[i - 1, j]) / 2
            if hh[i, j] <= 0 || hh[i - 1, j] <= 0
                hm[i, j] = 0
            end
        end
        hm[1, j] = hh[1, j]
    end
    for i in 1:nx
        for j in 2:ny
            hn[i, j] = (hh[i, j] + hh[i, j - 1]) / 2
            if hh[i, j] <= 0 || hh[i, j - 1] <= 0
                hn[i, j] = 0
            end
        end
        hn[i, 1] = hh[i, 1]
    end

    # Land filter
    @inbounds for j in 1:ny,i in 1:nx
        (hm[i, j] < 0) && (fm[i, j] = 0)
        (hn[i, j] < 0) && (fn[i, j] = 0)
        (hh[i, j] < 0) && (fe[i, j] = 0)
    end

    # Sponge absorbing boundary condition by Cerjan (1985)
    @inbounds for j in 1:ny, i in 1:nx
          if i <= nxa
             gg[i, j] = exp(-((apara * (nxa - i)) ^ 2))
          elseif i >= nx - nxa + 1
             gg[i, j] = exp(-((apara * (i - nx + nxa - 1)) ^ 2))
          elseif j <= nya
             gg[i, j] = exp(-((apara * (nya - j)) ^ 2))
          elseif j >= ny - nya + 1
             gg[i, j] = exp(-((apara * (j - ny + nya - 1)) ^ 2))
          else
             gg[i, j] = 1
          end
    end
    return gg, hh, hm, hn, fm, fn, fe
end


function initheight!(eta::AbstractMatrix{T},
                     hh::AbstractMatrix{T},
                     dx::Real,dy::Real,source_size::Real) where T
    @assert size(eta) == size(hh)

    # source size
    aa = source_size
    bb = source_size

    # bathymetry setting
    fill!(eta, 0)

    nx, ny = size(eta)

    i0 = floor(Int, nx / 4)
    j0 = floor(Int, ny / 4)
    for j in 1:ny
        if -bb <= (j - j0) * dy && (j - j0) * dy <= bb
            hy = (1 + cospi((j - j0) * dy / bb)) / 2
        else
            hy = 0.0
        end

        for i in 1:nx
            if -aa <= (i - i0) * dx && (i - i0) * dx <= aa
                hx = (1 + cospi((i - i0) * dx / aa)) / 2
            else
                hx = 0.0
            end
            eta[i, j] = hx * hy
        end
    end

    # force zero amplitude on land
    for j in 1:ny
        for i in 1:nx
            (hh[i, j] < eps(T)) && (eta[i, j] = 0)
        end
    end
    return eta
end

end # module
