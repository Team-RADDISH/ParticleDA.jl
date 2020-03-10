module Params

export grid_params, run_params, output_params, da_params, physics_params

## Parameters

include("./input.jl")

struct Physics_params{T<:AbstractFloat}
    g0::T
end

struct Grid_params{T<:AbstractFloat}
    nx::Int
    ny::Int
    nobs::Int
    dx::T
    dy::T
    dim_grid::Int
    dim_state::Int

    Grid_params(nx, ny, nobs, dx, dy) = new{Float64}(nx, ny, nobs, dx, dy, nx*ny, 3*nx*ny)
    Grid_params(nx, ny, nobs, dx, dy, dim_grid) = new{Float64}(nx, ny, nobs, dx, dy, dim_grid, 3*dim_grid)
    Grid_params(nx, ny, nobs, dx, dy, dim_grid, dim_state) = new{Float64}(nx, ny, nobs, dx, dy, dim_grid, dim_state)
end

struct Run_params{T<:AbstractFloat}
    dt::T
    ntmax::Int
end

struct Output_params
    title_da::String
    title_syn::String
    ntdec::Int
end

struct Da_params{T<:AbstractFloat}
    nprt::Int
    da_period::Int
    inv_rr::T
end

const physics_params = Physics_params(9.80665)
const grid_params = Grid_params(nx, ny, nobs, dx, dy)
const run_params = Run_params(dt, ntmax)
const output_params = Output_params(title_da, title_syn, ntdec)
const da_params = Da_params(nprt, da_period, 1.0 / rr)

end
