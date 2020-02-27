module TDAC

using Random, Distributions, Statistics, Distributed, Base.Threads

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

# Return observation data at stations from given model state
function get_obs!(obs::AbstractVector{T},
                  state::AbstractVector{T},
                  nx::Int,
                  ny::Int,
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int}) where T
    @assert length(obs) == length(ist) == length(jst)
    nn = length(state)
    
    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        iptr = (jj - 1) * nx + ii
        obs[i] = state[iptr]
    end
end

# Observation covariance matrix based on simple exponential decay
function get_obs_covariance(nobs::Int,
                            ist::AbstractVector{Int},
                            jst::AbstractVector{Int})
    
    @assert nobs == length(ist) == length(jst)
    mu_boo = Matrix{Float64}(undef, nobs, nobs)

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

# Update tsunami wavefield with LLW2d. Return new value.
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

# Update tsunami wavefield with LLW2d in-place.
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

# Get weights for particles by evaluating the probability of the observations predicted by the model
# from a multivariate normal pdf with mean equal to real observations and covariance equal to observation covariance
function get_weights!(weight::AbstractVector{T},
                      obs::AbstractVector{T},
                      obs_model::AbstractMatrix{T},
                      cov_obs::AbstractMatrix{T}) where T
        
    weight .= Distributions.pdf(Distributions.MvNormal(obs, cov_obs), obs_model) # TODO: Verify that this works
    
    weight ./= sum(weight)
    
end

# Resample particles from given weights using Stochastic Universal Sampling
function resample!(state_resampled::AbstractMatrix{T}, state::AbstractMatrix{T}, weight::AbstractVector{S}) where {T,S}

    nprt = size(state,2)
    nprt_inv = 1.0 / nprt
    k = 1

    #TODO: Do we need to sort state by weight here?
    
    weight_cdf = cumsum(weight)
    u = nprt_inv * Random.rand(S)

    # Note: To parallelise this loop, updates to k and u have to be atomic.
    # TODO: search for better parallel implementations
    for ip in 1:nprt

        while(u > weight_cdf[k])
            k += 1
        end

        state_resampled[:,ip] = state[:,k]

        u += nprt_inv
        
    end
    
end

# Add (0,1) normal distributed white noise to state
function add_noise!(state, amplitude)
    
    @. state += randn() * amplitude
    
end

function tdac()
    # Model vector for data assimilation
    #   state*(        1:  Nx*Ny): tsunami height eta(nx,ny)
    #   state*(  Nx*Ny+1:2*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    #   state*(2*Nx*Ny+1:3*Nx*Ny): vertically integrated velocity Mx(nx,ny)
    state = zeros(Float64, dim_state, nprt) # model state vectors for particles
    state_true = zeros(Float64, dim_state) # model vector: true wavefield (observation)   
    state_avg = zeros(Float64, dim_state) # average of particle state vectors
    
    state_resampled = Matrix{Float64}(undef, dim_state, nprt) #preallocate once instead of every time resample is called
    
    weights = Vector{Float64}(undef, dim_state)

    obs_real = Vector{Float64}(undef, nobs)        # observed tsunami height
    obs_model = Matrix{Float64}(undef, nobs, nprt) # forecasted tsunami height

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
        get_obs!(obs_real, state_true, nx, ny, ist, jst) # generate observed data
        
        # Forecast
        # TODO: parallelise/simd this loop
        Threads.@threads for ip in 1:nprt
            
            # Update tsunami forecast
            tsunami_update!(@view(state[:,ip]), nx, ny, hm, hn, fn, fm, fe, gg)
            
            # Retrieve forecasted observations at stations
            get_obs!(@view(obs_model[:,ip]), @view(state[:,ip]), nx, ny, ist, jst)
            
        end

        # Weigh and resample particles
        if mod(it - 1, da_period) == 0

            # println("observations")
            # println("real :",yt)
            # for ip in 1:nprt
            #     println("model:",yf[:,ip])
            # end
            
            get_weights!(weight, obs_real, obs_model, cov_obs)

            # println("weights: ", weight)
            
            resample!(state_resampled, state, weight)
            state .= state_resampled

        end
        
        Statistics.mean!(state_avg, state)
        
    end
end

end # module
