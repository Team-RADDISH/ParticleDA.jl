module TDAC

using Random, Distributions, Statistics, Distributed

export tdac

include("params.jl")
include("matrix.jl")
include("llw2d.jl")

using .Params
using .LLW2d
using .Matrix_ls

# grid-to-grid distance
get_distance(i0, j0, i1, j1) =
    sqrt((float(i0 - i1) * dx) ^ 2 + (float(j0 - j1) * dy) ^ 2)

# Return waveform data at stations from given model parameter matrix
function get_obs(mm::AbstractVector{T},
                 ist::AbstractVector{Int},
                 jst::AbstractVector{Int}) where T
    @assert length(ist) == length(jst)
    nobs = length(ist)
    obs = zeros(nobs)
    nn = length(mm)
    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        iptr = (jj - 1) * nx + ii
        obs[i] = mm[iptr]
    end

    return obs
end

# Weight matrix based on the Optimum Interpolation method.
function get_obs_covariance(nobs::Int,
                            ist::AbstractVector{Int},
                            jst::AbstractVector{Int})
    
    @assert nobs == length(ist) == length(jst)
    mu_boo = zeros(Float64, nobs, nobs)

    # Estimate background error between stations
    for j in 1:nobs
        for i in 1:nobs
            # Gaussian correlation function
            dist = get_distance(ist[i], jst[i], ist[j], jst[j])
            mu_boo[i, j] = exp(-(dist / rr) ^ 2)
        end
    end
    
    return mu_boo
end

function tsunami_update(xa::AbstractVector{T},
                        hm::AbstractMatrix{T},
                        hn::AbstractMatrix{T},
                        fm::AbstractMatrix{T},
                        fn::AbstractMatrix{T},
                        fe::AbstractMatrix{T},
                        gg::AbstractMatrix{T}) where T
    nn = length(xa)
    xf = zero(xa)

    nn = nx * ny

    eta_a = reshape(@view(xa[1:nn]), nx, ny)
    mm_a  = reshape(@view(xa[(nn + 1):(2 * nn)]), nx, ny)
    nn_a  = reshape(@view(xa[(2 * nn + 1):(3 * nn)]), nx, ny)
    eta_f = reshape(@view(xf[1:nn]), nx, ny)
    mm_f  = reshape(@view(xf[(nn + 1):(2 * nn)]), nx, ny)
    nn_f  = reshape(@view(xf[(2 * nn + 1):(3 * nn)]), nx, ny)

    # Parts of model vector are aliased to tsunami heiht and velocities
    LLW2d.timestep!(eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, hm, hn, fn, fm, fe, gg)

    return xf
    
end

function get_weights(y::AbstractVector{T}, hx::AbstractMatrix{T}, cov_obs::AbstractMatrix{T}) where T
    
    # for ip = 1:nprt
    #     weight[i] = Distributions.pdf(Distributions.MvNormal(yt, cov_obs), hx[:,iprt])        
    # end
    
    weight = Distributions.pdf(Distributions.MvNormal(y, cov_obs), hx) # This may work
    
    return weight / sum(weight)
    
end

function resample(x::AbstractMatrix{T}, weight::AbstractVector{Float64}) where T

    nprt = size(x,2)
    nprt_inv = 1.0 / nprt
    k = 1
    
    weight_cdf = cumsum(weight)
    x_resampled = zero(x)
    u = nprt_inv * Random.rand(Float64)

    # Note: To parallelise this loop, updates to k and u have to be atomic.
    # TODO: search for better parallel implementations
    for ip in 1:nprt

        while(u > weight_cdf[k])
            k += 1
        end

        x_resampled[:,ip] = x[:,k]

        u += nprt_inv
        
    end

    return x_resampled
    
end

function add_noise!(x, amplitude)
    
    x[:] += Random.randn(length(x)) * amplitude
    
end

function tdac()
    # Model vector for data assimilation
    #   m*(        1:  Nx*Ny): tsunami height eta(nx,ny)
    #   m*(  Nx*Ny+1:2*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    #   m*(2*Nx*Ny+1:3*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    xf = zeros(Float64, dim_state_vector, nprt) # state vectors for particles
    xa = zeros(Float64, dim_state_vector) # average of particle state vectors
    xt = zeros(Float64, dim_state_vector) # model vector: true wavefield (observation)
    weights = zeros(Float64, dim_state_vector)
    
    xa_avg = Vector{Float64}(undef, dim_state_vector)

    yt    = Vector{Float64}(undef, nobs)        # observed tsunami height
    yf    = Matrix{Float64}(undef, nobs, nprt)  # forecasted tsunami height

    # station location in digital grids
    ist   = Vector{Int}(undef, nobs)
    jst   = Vector{Int}(undef, nobs)

    # Set up tsunami model
    gg, hh, hm, hn, fm, fn, fe = LLW2d.setup() # obtain initial tsunami height
    eta = reshape(@view(xt[1:nx*ny]), nx, ny)
    LLW2d.initheight!(eta, hh)
    LLW2d.set_stations!(ist, jst)

    cov_obs = get_obs_covariance(nobs, ist, jst)
    
    for it in 1:ntmax

        if mod(it - 1, ntdec) == 0
            println("timestep = ", it)
        end
        
        # save tsunami wavefield snapshot for visualization
        if mod(it - 1, ntdec) == 0
            LLW2d.output_snap(reshape(@view(xa[1:nx*ny]), nx, ny),
                              floor(Int, (it - 1) / ntdec),
                              title_da)
            LLW2d.output_snap(reshape(@view(xt[1:nx*ny]), nx, ny),
                              floor(Int, (it - 1) / ntdec),
                              title_syn)
        end

        xt = tsunami_update(xt, hm, hn, fn, fm, fe, gg) # integrate true synthetic wavefield
        yt = get_obs(xt, ist, jst) # generate observed data

        add_noise!(xf, 1e-2)
        
        # Forecast-Assimilate
        # TODO: parallelise this loop
        @distributed for ip in 1:nprt
            
            # tsunami forecast
            xf[:,ip] = tsunami_update(xf[:,ip], hm, hn, fn, fm, fe, gg) # forecasting
            
            # Retrieve forecasted tsunami waveform data at stations
            yf[:,ip] = get_obs(xf[:,ip], ist, jst)
            
        end

        if mod(it - 1, da_period) == 0

            # println("observations")
            # println("real :",yt)
            # for ip in 1:nprt
            #     println("model:",yf[:,ip])
            # end
            
            weight = get_weights(yt, yf, cov_obs)

            # println("weights: ", weight)
            
            xf = resample(xf, weight)

        end
            
        Statistics.mean!(xa, xf)
        
    end
end

end # module
