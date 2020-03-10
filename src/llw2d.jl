module LLW2d

using ..Params

# Linear Long Wave (LLW) tsunami in 2D Cartesian Coordinate

const nxa = 20            # absorber thickness
const nya = 20            # absorber thickness
const apara = 0.015       # damping for boundaries
const CUTOFF_DEPTH = 10   # shallowest water depth

# Set station locations. Users may need to modify it
function set_stations!(ist::AbstractVector{Int},
                       jst::AbstractVector{Int})
    # synthetic station locations
    nst = 0
    
    # let's check ist and jst have a square number of elements before computing n
    @assert mod(sqrt(length(ist)),1.0) ≈ 0
    @assert mod(sqrt(length(jst)),1.0) ≈ 0
    n = floor(Int, sqrt(length(ist)))
    
    @inbounds for i in 1:n, j in 1:n
        nst += 1
        ist[nst] = floor(Int, ((i - 1) * grid_params.station_separation + grid_params.station_boundary )
                         * grid_params.station_dx / grid_params.dx + 0.5)
        jst[nst] = floor(Int, ((j - 1) * grid_params.station_separation + grid_params.station_boundary )
                         * grid_params.station_dy / grid_params.dy + 0.5)
    end
end


function timestep!(eta1::AbstractMatrix{T},
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
                   gg::AbstractMatrix{T}) where T
    nx, ny = size(eta1)
    @assert (nx, ny) == size(mm1) == size(nn1) == size(eta0) == size(mm0) ==
        size(nn0) == size(hm) == size(hn) == size(fm) == size(fn) == size(fe) ==
        size(gg)

    dxeta = Matrix{T}(undef, nx, ny)
    dyeta = Matrix{T}(undef, nx, ny)
    dxM   = Matrix{T}(undef, nx, ny)
    dyN   = Matrix{T}(undef, nx, ny)

    # diffs
    for j in 1:ny
        for i in 2:nx
            @inbounds dxeta[i,j] = (eta0[i,j] - eta0[i - 1,j]) / grid_params.dx
        end
        @inbounds dxeta[1,j] = (eta0[1,j] - 0) / grid_params.dx
    end
    for i in 1:nx
        for j in 2:ny
            @inbounds dyeta[i,j] = (eta0[i,j] - eta0[i, j - 1]) / grid_params.dy
        end
        @inbounds dyeta[i,1] = (eta0[i,1] - 0) / grid_params.dy
    end

    # Update Velocity
    for j in 1:ny, i in 1:nx
        @inbounds mm1[i,j] = mm0[i, j] - physics_params.g0 * hm[i, j] * dxeta[i, j] * run_params.dt
        @inbounds nn1[i,j] = nn0[i, j] - physics_params.g0 * hn[i, j] * dyeta[i, j] * run_params.dt
    end

    # boundary condition
    for j in 1:ny, i in 1:nx
        @inbounds mm1[i, j] = mm1[i, j] * fm[i, j] * gg[i, j]
        @inbounds nn1[i, j] = nn1[i, j] * fn[i, j] * gg[i, j]
    end

    # diffs
    for j in 1:ny
        @inbounds dxM[nx, j] = (-mm1[nx, j]) / grid_params.dx
        for i in 1:(nx-1)
            @inbounds dxM[i, j] = (mm1[i + 1, j] - mm1[i, j]) / grid_params.dx
        end
    end
    for i in 1:nx
        @inbounds dyN[i, ny] = (-nn1[i, ny]) / grid_params.dy
        for j in 1:(ny-1)
            @inbounds dyN[i, j] = (nn1[i,j + 1] - nn1[i, j]) / grid_params.dy
        end
    end

    # Update Wave Heigt
    for j in 1:ny, i in 1:nx
        @inbounds eta1[i, j] = eta0[i, j] - (dxM[i, j] + dyN[i, j]) * run_params.dt
    end

    # boundary condition
    for j in 1:ny, i in 1:nx
        @inbounds eta1[i, j] = eta1[i, j] * fe[i, j] * gg[i, j]
    end
    return eta1, mm1, nn1
end

function setup(nx::Int = grid_params.nx,
               ny::Int = grid_params.nx,
               hh_val::AbstractFloat = 3000.0,
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
    fill!(hh, hh_val)
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
                     aa_and_bb_val::AbstractFloat = 3.0e4) where T
    @assert size(eta) == size(hh)

    # source size
    aa = aa_and_bb_val
    bb = aa_and_bb_val

    # bathymetry setting
    fill!(eta, 0)

    nx, ny = size(eta)

    i0 = floor(Int, nx / 4)
    j0 = floor(Int, ny / 4)
    for j in 1:ny
        if -bb <= (j - j0) * grid_params.dy && (j - j0) * grid_params.dy <= bb
            hy = (1 + cospi((j - j0) * grid_params.dy / bb)) / 2
        else
            hy = 0.0
        end

        for i in 1:nx
            if -aa <= (i - i0) * grid_params.dx && (i - i0) * grid_params.dx <= aa
                hx = (1 + cospi((i - i0) * grid_params.dx / aa)) / 2
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

# export snapshot data for visualization
function output_snap(eta::AbstractMatrix, isnap::Integer, title::AbstractString)
    nx, ny = size(eta)
    outdir = "out"
    mkpath(outdir)
    fn_out = joinpath(outdir,
                      "jl-$(title)__" *
                      lpad(isnap, 6, '0') *
                      "__.dat")
    open(fn_out, "w") do io
        for j in 1:ny
            for i in 1:nx
                println(io, (i - 1) * grid_params.dx * 1.0e-3,
                        "\t",
                        (j - 1) * grid_params.dy * 1.0e-3,
                        "\t",
                        real(eta[i,j]))
            end
        end
    end
end

end # module
