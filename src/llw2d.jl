module LLW2d

using ..Params

export
    set_stations!,
    timestep,
    setup,
    initheight!

# Linear Long Wave (LLW) tsunami in 2D Cartesian Coordinate

const nxa = 20            # absorber thickness
const nya = 20            # absorber thickness
const apara = 0.015       # damping for boundaries
const CUTOFF_DEPTH = 10   # shallowest water depth

# TODO: compute in `setup` and let it return these variables
#  real(DP) :: gg (Nx,Ny) !< absorbing boundary
#  integer  :: ist(:), jst(:)  !! station locations
#  real(DP) :: hh(:,:)  !< ocean depth
#  real(DP) :: hm(:,:)  !< x-averaged depth
#  real(DP) :: hn(:,:)  !< y-averaged depth
#  real(DP) :: fn(:,:), fm(:,:), fe(:,:)  !< land filters

# Set station locations. Users may need to modify it
function set_stations!(ist::AbstractVector{Int},
                       jst::AbstractVector{Int})
    # synthetic station locations
    nst = 0
    # let's assume ist and jst have a square number of elements
    n = floor(Int, sqrt(length(ist)))
    @inbounds for i in 1:n, j in 1:n
        nst += 1
        ist[nst] = floor(Int, ((i - 1) * 20 + 150 ) * 1000 / dx + 0.5)
        jst[nst] = floor(Int, ((j - 1) * 20 + 150 ) * 1000 / dy + 0.5)
    end

    # output for visualization
    # open(10, file='./out/stloc.dat')
    # do i=1, nst
    #   write(10,*) (ist(i)-1)*dx/1000., (jst(i)-1)*dy/1000
    # end do
    # close(10)
end


function timestep(eta0::AbstractMatrix{T},
                  mm0::AbstractMatrix{T},
                  nn0::AbstractMatrix{T}) where T
    dxeta = Matrix{T}(undef, nx, ny)
    dyeta = Matrix{T}(undef, nx, ny)
    dxM   = Matrix{T}(undef, nx, ny)
    dxN   = Matrix{T}(undef, nx, ny)
    eta1  = Matrix{T}(undef, nx, ny)
    mm1   = Matrix{T}(undef, nx, ny)
    nn1   = Matrix{T}(undef, nx, ny)

    # diffs
    for j in 1:ny
        for i in 2:nx
            @inbounds dxeta[i,j] = (eta0[i,j] - eta0[i - 1,j]) / dx
        end
        @inbounds dxeta[1,j] = (eta0[1,j] - 0) / dx
    end
    for i in 1:nx
        for j in 2:ny
            @inbounds dyeta[i,j] = (eta0[i,j] - eta0[i, j - 1]) / dy
        end
        @inbounds dyeta[i,1] = (eta0[i,1] - 0) / dy
    end

    # Update Velocity
    for j in 1:ny, i in 1:nx
        @inbounds mm1[i,j] = mm0[i, j] - g0 * hm[i, j] * dxeta[i, j] * dt
        @inbounds nn1[i,j] = nn0[i, j] - g0 * hn[i, j] * dyeta[i, j] * dt
    end

    # boundary condition
    for j in 1:ny, i in 1:nx
        @inbounds mm1[i, j] = mm1[i, j] * fm[i, j] * gg[i, j]
        @inbounds nn1[i, j] = nn1[i, j] * fn[i, j] * gg[i, j]
    end

    # diffs
    for j in 1:ny
        @inbounds dxM[nx, j] = (-mm1[nx, j]) / dx
        for i in 1:(Nx-1)
            @inbounds dxM[i, j] = (mm1[i + 1, j] - mm1[i, j]) / dx
        end
    end
    for i in 1:nx
        @inbounds dyN[i, ny] = (-nn1[i, ny]) / dy
        for j in 1:(ny-1)
            @inbounds dyN(i,j) = (nn1[i,j + 1] - nn1[i, j]) / dy
        end
    end

    # Update Wave Heigt
    for j in 1:ny, i in 1:Nx
        @inbounds eta1[i, j] = eta0[i, j] - (dxM[i, j] + dyN[i, j]) * dt
    end

    # boundary condition
    for j in 1:ny, i in 1:nx
        @inbounds eta1[i, j] = eta1[i, j] * fe[i, j] * gg[i, j]
    end
    return eta1, mm1, nn1
end

function setup(T::DataType = Float64)
    # Memory allocation
    hh = Matrix{T}(undef, nx, ny)
    hm = Matrix{T}(undef, nx, ny)
    hn = Matrix{T}(undef, nx, ny)
    fm = ones(T, nx, ne)
    fn = ones(T, nx, ne)
    fe = ones(T, nx, ne)

    # Bathymetry set-up. Users may need to modify it
    fill!(hh, 3000)
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
            if hh[i, j] <= 0 || hh(i - 1, j) <= 0
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
end


function initheight!(eta::AbstractMatrix{T},
                     hh::AbstractMatrix{T}) where T
    @assert size(eta) == size(hh)

    # source size
    aa = 30000
    bb = 30000

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
