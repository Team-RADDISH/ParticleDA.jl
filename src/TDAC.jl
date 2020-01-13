module TDAC

using LinearAlgebra

export tdac

include("params.jl")
include("matrix.jl")
include("llw2d.jl")

using .Params
using .LLW2d
using .Matrix_ls

const title_da  = "da"  # output file title
const title_syn = "syn" # output file title for synthetic data

# control parameters for optimum interpolations: See document
const rho = 1.0  # Ratio between obs and bg error
const rr = 20000 # Cutoff distance of error covariance (m)

# model sizes
const nn    = 3 * nx * ny
const ntmax = 3000  # Number of time steps

# visualization
const ntdec = 10 # decimation factor for visualization

# grid-to-grid distance
get_distance(i0, j0, i1, j1) =
    sqrt((float(i0 - i1) * dx) ^ 2 + (float(j0 - j1) * dy) ^ 2)

# Return waveform data at stations from given model parameter matrix
function get_obs!(obs::AbstractVector{T},
                  mm::AbstractVector{T},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int}) where T
    no = length(obs)
    nn = length(mm)
    @assert no == length(ist) == length(jst)
    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        iptr = (jj - 1) * nx + ii
        obs[i] = mm[iptr]
    end
end

# Weight matrix based on the Optimum Interpolation method.
function set_weight!(ww::AbstractMatrix{T},
                     ist::AbstractVector{Int},
                     jst::AbstractVector{Int}) where T
    nn, no = size(ww)
    @assert no == length(ist) == length(jst)
    mu_bgo = zeros(T, nn, no)
    mu_boo = zeros(T, no, no)
    mat = Matrix{T}(undef, no, no)

    # Estimate background error between numerical grid and station
    for ig in 1:(nx * ny)
        for i in 1:no
            # Background error depend on spatial distance

            # Gaussian correlation function
            ii = mod(ig, nx)
            jj = (ig - ii) / nx + 1
            dist = get_distance(ist[i], jst[i], ii, jj)
            mu_bgo[ig,i] = exp(-(dist / rr) ^ 2)
        end
    end

    # Estimate background error between stations
    for j in 1:no
        for i in 1:no
            # Gaussian correlation function
            dist = get_distance(ist[i], jst[i], ist[j], jst[j])
            mu_boo[i, j] = exp(-(dist / rr) ^ 2)
        end
    end

    # Calculate inverse matrix for obtaining weight matrix
    for j in 1:no
        for i in 1:no
            mat[i,j] = mu_boo[i,j]
            (i==j) && (mat[i, j] = mat[i, j] + rho ^ 2)
        end
    end

    # invert weight vector
    for ig in 1:(3 * nx * ny)
        Matrix_ls.gs!(@view(ww[ig, :]), mat, @view(mu_bgo[ig, :]))
    end
end

function tsunami_update!(xf::AbstractVector{T}, # output: forecasted
                         xa::AbstractVector{T}, # input: assimilated
                         hm::AbstractMatrix{T},
                         hn::AbstractMatrix{T},
                         fm::AbstractMatrix{T},
                         fn::AbstractMatrix{T},
                         fe::AbstractMatrix{T},
                         gg::AbstractMatrix{T}) where T
    nn = length(xa)
    @assert nn == length(xf)

    nn = nx * ny

    eta_a = reshape(@view(xa[1:nn]), nx, ny)
    mm_a  = reshape(@view(xa[(nn + 1):(2 * nn)]), nx, ny)
    nn_a  = reshape(@view(xa[(2 * nn + 1):(3 * nn)]), nx, ny)
    eta_f = reshape(@view(xf[1:nn]), nx, ny)
    mm_f  = reshape(@view(xf[(nn + 1):(2 * nn)]), nx, ny)
    nn_f  = reshape(@view(xf[(2 * nn + 1):(3 * nn)]), nx, ny)

    # Parts of model vector are aliased to tsunami heiht and velocities
    LLW2d.timestep!(eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, hm, hn, fn, fm, fe, gg)
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
    gg, hh, hm, hn, fm, fn, fe = LLW2d.setup() # obtain initial tsunami height
    eta = reshape(@view(mt[1:nx*ny]), nx, ny)
    LLW2d.initheight!(eta, hh)
    LLW2d.set_stations!(ist, jst)

    # Calculate weight matrix used in the data assimilation
    set_weight!(ww, ist, jst)

    for it in 1:ntmax

        if mod(it - 1, ntdec) == 0
            println("timestep = ", it)
        end
        ## save tsunami wavefield snapshot for visualization
        ##   note that m*(1:Nx*Ny) corresponds to the tsunami height
        ##
        # assimilation
        if mod(it - 1, ntdec) == 0
            LLW2d.output_snap(reshape(@view(ma[1:nx*ny]), nx, ny),
                              floor(Int, (it - 1) / ntdec),
                              title_da)
            LLW2d.output_snap(reshape(@view(ma[1:nx*ny]), nx, ny),
                              floor(Int, (it - 1) / ntdec),
                              title_syn)
        end

        # Retrieve "observation" data from synthetic true wavefield
        #   This part is specialized for synthetic test.
        #   This example code calculates synthetic data parallel to
        #   the data assimilation and use it as "observed" data.
        #   This part can be substituted by real observation data.

        tsunami_update!(mt, mt, hm, hn, fn, fm, fe, gg) # integrate true synthetic wavefield
        get_obs!(yt, mt, ist, jst) # generate observed data

        # Forecast-Assimilate

        # tsunami forecast
        tsunami_update!(mf, ma, hm, hn, fn, fm, fe, gg) # ma-->mf forecasting

        # Retrieve forecasted tsunami waveform data at stations
        get_obs!(yf, mf, ist, jst)

        # Residual
        @. d_obs = yt - yf

        # Assimilation.  TODO: maybe use `mul!(mf, ww, d_obs, 1, 1)`?
        mul!(ma, ww, d_obs)
        @. ma = mf + ma
    end
end

end # module
