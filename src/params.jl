module Params

export tdac_params

struct tdac_params{T<:AbstractFloat}
    # Physics parameters
    g0::T

    # Grid parameters
    nx::Int
    ny::Int
    nobs::Int
    dx::T
    dy::T
    dim_grid::Int
    dim_state::Int

    # Run parameters
    dt::T
    ntmax::Int

    # Output parameters
    title_da::String
    title_syn::String
    ntdec::Int

    # DA parameters
    nprt::Int
    da_period::Int
    inv_rr::T
end

end
