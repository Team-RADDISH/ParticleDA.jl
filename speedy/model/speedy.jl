module SPEEDY

# All these functions need to be updated to accommodate the SPEEDY model

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
