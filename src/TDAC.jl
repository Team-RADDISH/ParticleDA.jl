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
function get_obs(nx::Int,
                 ny::Int,
                 state::AbstractVector{T},
                 ist::AbstractVector{Int},
                 jst::AbstractVector{Int}) where T
    @assert length(ist) == length(jst)
    nobs = length(ist)
    obs = zeros(nobs)
    nn = length(state)
    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        iptr = (jj - 1) * nx + ii
        obs[i] = state[iptr]
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

function tsunami_update(nx::Int,
                        ny::Int,
                        state::AbstractVector{T},
                        hm::AbstractMatrix{T},
                        hn::AbstractMatrix{T},
                        fm::AbstractMatrix{T},
                        fn::AbstractMatrix{T},
                        fe::AbstractMatrix{T},
                        gg::AbstractMatrix{T}) where T
    nn = nx * ny

    state_forecast = zero(state)
    
    eta_a = reshape(@view(state[1:nn]), nx, ny)
    mm_a  = reshape(@view(state[(nn + 1):(2 * nn)]), nx, ny)
    nn_a  = reshape(@view(state[(2 * nn + 1):(3 * nn)]), nx, ny)
    eta_f = reshape(@view(state_forecast[1:nn]), nx, ny)
    mm_f  = reshape(@view(state_forecast[(nn + 1):(2 * nn)]), nx, ny)
    nn_f  = reshape(@view(state_forecast[(2 * nn + 1):(3 * nn)]), nx, ny)

    # Parts of model vector are aliased to tsunami heiht and velocities
    LLW2d.timestep!(eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, hm, hn, fn, fm, fe, gg)

    return state_forecast
    
end

function tsunami_update!(nx::Int,
                         ny::Int,
                         state::AbstractVector{T},
                         hm::AbstractMatrix{T},
                         hn::AbstractMatrix{T},
                         fm::AbstractMatrix{T},
                         fn::AbstractMatrix{T},
                         fe::AbstractMatrix{T},
                         gg::AbstractMatrix{T}) where T
    
    nn = nx * ny

    eta_a = reshape(@view(state[1:nn]), nx, ny)
    mm_a  = reshape(@view(state[(nn + 1):(2 * nn)]), nx, ny)
    nn_a  = reshape(@view(state[(2 * nn + 1):(3 * nn)]), nx, ny)
    eta_f = reshape(@view(state[1:nn]), nx, ny)
    mm_f  = reshape(@view(state[(nn + 1):(2 * nn)]), nx, ny)
    nn_f  = reshape(@view(state[(2 * nn + 1):(3 * nn)]), nx, ny)

    # Parts of model vector are aliased to tsunami heiht and velocities
    LLW2d.timestep!(eta_f, mm_f, nn_f, eta_a, mm_a, nn_a, hm, hn, fn, fm, fe, gg)
    
end


function get_weights(obs::AbstractVector{T}, obs_model::AbstractMatrix{T}, cov_obs::AbstractMatrix{T}) where T
    
    # for ip = 1:nprt
    #     weight[i] = Distributions.pdf(Distributions.MvNormal(yt, cov_obs), hx[:,iprt])        
    # end
    
    weight = Distributions.pdf(Distributions.MvNormal(obs, cov_obs), obs_model) # TODO: Verify that this works
    
    return weight / sum(weight)
    
end

function resample(state::AbstractMatrix{T}, weight::AbstractVector{Float64}) where T

    nprt = size(state,2)
    nprt_inv = 1.0 / nprt
    k = 1

    #TODO: Do we need to sort state by weight here?
    
    weight_cdf = cumsum(weight)
    state_resampled = zero(state)
    u = nprt_inv * Random.rand(Float64)

    # Note: To parallelise this loop, updates to k and u have to be atomic.
    # TODO: search for better parallel implementations
    for ip in 1:nprt

        while(u > weight_cdf[k])
            k += 1
        end

        state_resampled[:,ip] = state[:,k]

        u += nprt_inv
        
    end

    return state_resampled
    
end

function add_noise!(state, amplitude)
    
    state[:] += Random.randn(length(state)) * amplitude
    
end

function tdac()
    # Model vector for data assimilation
    #   state*(        1:  Nx*Ny): tsunami height eta(nx,ny)
    #   state*(  Nx*Ny+1:2*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    #   state*(2*Nx*Ny+1:3*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    state = zeros(Float64, dim_state_vector, nprt) # model state vectors for particles
    state_avg = zeros(Float64, dim_state_vector) # average of particle state vectors
    state_true = zeros(Float64, dim_state_vector) # model vector: true wavefield (observation)
    weights = zeros(Float64, dim_state_vector)

    obs_real = Vector{Float64}(undef, nobs)        # observed tsunami height
    obs_model = Matrix{Float64}(undef, nobs, nprt)  # forecasted tsunami height

    # station location in digital grids
    ist   = Vector{Int}(undef, nobs)
    jst   = Vector{Int}(undef, nobs)

    # Set up tsunami model
    gg, hh, hm, hn, fm, fn, fe = LLW2d.setup() # obtain initial tsunami height
    eta = reshape(@view(state[1:nx*ny]), nx, ny)
    LLW2d.initheight!(eta, hh)
    LLW2d.set_stations!(ist, jst)

    cov_obs = get_obs_covariance(nobs, ist, jst)
    
    for it in 1:ntmax

        if mod(it - 1, ntdec) == 0
            println("timestep = ", it)
        end
        
        # save tsunami wavefield snapshot for visualization
        if mod(it - 1, ntdec) == 0
            LLW2d.output_snap(reshape(@view(state_avg[1:nx*ny]), nx, ny),
                              floor(Int, (it - 1) / ntdec),
                              title_da)
            LLW2d.output_snap(reshape(@view(state_true[1:nx*ny]), nx, ny),
                              floor(Int, (it - 1) / ntdec),
                              title_syn)
        end

        tsunami_update!(nx,ny,state_true, hm, hn, fn, fm, fe, gg) # integrate true synthetic wavefield
        obs_real = get_obs(nx, ny, state_true, ist, jst) # generate observed data

        add_noise!(state, 1e-2)
        
        # Forecast-Assimilate
        # TODO: parallelise this loop
        @distributed for ip in 1:nprt
            
            # tsunami forecast
            tsunami_update!(nx,ny,@view(state[:,ip]), hm, hn, fn, fm, fe, gg) # forecasting
            
            # Retrieve forecasted tsunami waveform data at stations
            obs_model[:,ip] = get_obs(nx, ny, @view(state[:,ip]), ist, jst)
            
        end

        if mod(it - 1, da_period) == 0

            # println("observations")
            # println("real :",yt)
            # for ip in 1:nprt
            #     println("model:",yf[:,ip])
            # end
            
            weight = get_weights(obs_real, obs_model, cov_obs)

            # println("weights: ", weight)
            
            state = resample(state, weight)

        end
            
        Statistics.mean!(state_avg, state)
        
    end
end

end # module
