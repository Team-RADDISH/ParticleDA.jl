module TDAC

using LinearAlgebra

export tdac

include("params.jl")
include("matrix.jl")
include("llw2d.jl")

using .Params
using .LLW2d
using .Matrix_ls

# control parameters for optimum interpolations: See document
const rho = 1.0  # Ratio between obs and bg error
const rr = 20000 # Cutoff distance of error covariance (m)

# model sizes
const nn    = 3 * nx * ny
const ntmax = 3000  # Number of time steps

# grid-to-grid distance
get_distance(i0, j0, i1, j1) = sqrt(((i0 - i1) * dx) ^ 2 + ((j0 - j1) * dy) ^ 2)

# Return waveform data at stations from given model parameter matrix
function get_obs!(obs::AbstractVector{T},
                  mm::AbstractVector{T},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int}) where T
    no = length(obs)
    @assert no == length(mm) == length(ist) == length(jst)
    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        iptr = (jj - 1) * nx + ii
        obs[i] = mm[mod(iptr, no) + 1] # TODO: check this!!!!!
    end
end


function tdac()
    # Model vector for data assimilation
    #   m*(        1:  Nx*Ny): tsunami height eta(nx,ny)
    #   m*(  Nx*Ny+1:2*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    #   m*(2*Nx*Ny+1:3*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    mf = zeros(Float64, nn) # model vector: forecasted
    ma = zeros(Float64, nn) # model vector: data-assimilated
    mt = zeros(Float64, nn) # model vector: true wavefield (observation)

    ww    = Matrix{Float64}(undef, nn, no) # weight matrix
    yt    = Vector{Float64}(undef, no)     # observed tsunami height
    yf    = Vector{Float64}(undef, no)     # forecasted tsunami height
    d_obs = Vector{Float64}(undef, no)     # Forecast-observation residual
    # station location in digital grids
    ist   = Vector{Int}(undef, no)
    jst   = Vector{Int}(undef, no)

    # Set up tsunami model
    gg, hh, hm, hn, fn, fm, fe = LLW2d.setup() # obtain initial tsunami height
    eta = reshape(@view(mt[1:nx*ny]), nx, ny)
    LLW2d.initheight!(eta, hh)
    LLW2d.set_stations!(ist, jst)

    # Calculate weight matrix used in the data assimilation
    set_weight()

    for it in 1:ntmax

        # if mod(it-1, ntdec) == 0
        #     write(STDERR,* ) "timestep = ", it
        # end

        ## save tsunami wavefield snapshot for visualization
        ##   note that m*(1:Nx*Ny) corresponds to the tsunami height
        ##
        # assimilation
        # if ( mod(it-1, ntdec) == 0 ) then
        #   call llw2d__output_snap(ma(1:nx*ny), (it-1)/ntdec, title_da)
        #   call llw2d__output_snap(mt(1:nx*ny), (it-1)/ntdec, title_syn)
        # endif

        # Retrieve "observation" data from synthetic true wavefield
        #   This part is specialized for synthetic test.
        #   This example code calculates synthetic data parallel to
        #   the data assimilation and use it as "observed" data.
        #   This part can be substituted by real observation data.

        tsunami_update(mt, mt)     # integrate true synthetic wavefield
        get_obs!(yt, mt, ist, jst) # generate observed data

        # Forecast-Assimilate

        # tsunami forecast
        tsunami_update(ma, mf) # ma-->mf forecasting

        # Retrieve forecasted tsunami waveform data at stations
        get_obs(mf, yf)

        # Residual
        @. d_obs = yt - yf

        # Assimilation.  TODO: maybe use `mul!(mf, ww, d_obs, 1, 1)`?
        mul!(ma, ww, d_obs)
        @. ma = mf + ma
    end
end

end # module
