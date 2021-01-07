using FFTW
using LinearAlgebra
using Test
using SparseArrays
using Random
using Distributions

Base.@kwdef struct TestParameters{T<:AbstractFloat}

    nx::Int = 20
    ny::Int = 20
    x_length::T = 40.0
    y_length::T = 40.0
    dx::T = x_length / nx
    dy::T = y_length / ny

    sigma_cov::T = 1.0
    lambda_cov::T = 1.0

    sigma_obs::T = 0.01
    nobs = 3

    nprt = 10

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T

end

struct OfflineMatrices{T<:AbstractArray, S<:AbstractArray, U<:AbstractArray}

    rho_bar::S
    R12::T
    R21_bar::T
    R22::T # Covariance between observation stations
    R22_inv::T # Inverse of R22
    R12_invR22::T
    Lambda::S
    K::U
    L::T
    mu20::T

    buf1::T
    buf2::T

end


struct OnlineMatrices{T<:AbstractVector, S<:AbstractArray}

    z1_bar::T
    z2::T

    Z1::S
    Z2::S

end

# Covariance function r(x,y), equation 1 in Dietrich and Newsam 96
function covariance(x::T, y::T, params::TestParameters) where T

    return params.sigma_cov^2 * exp(-(abs(x) + abs(y))/(2 * params.lambda_cov))

end

# Extended covariance function /bar r(x,y), equation 8 of Dietrich and Newsam 96
function extended_covariance(x::T, y::T, params::TestParameters) where T

    if 0 <= x <= params.x_length
        x_ext = x
    elseif params.x_length <= x <= 2 * params.x_length
        x_ext = 2 * params.x_length - x
    else
        @error "value of x is out of bounds"
    end

    if 0 <= y <= params.y_length
        y_ext = y
    elseif params.y_length <= y <= 2 * params.y_length
        y_ext = 2 * params.y_length - y
    else
        @error "value of y is out of bounds"
    end

    return covariance(x_ext, y_ext, params::TestParameters)

end

# Covariance between observations and the extended grid /bar R_21, from equation 11 in Dietrich & Newsam 96
function covariance_stations_extended_grid!(cov::AbstractMatrix{T}, params::TestParameters, stations::StationVectors) where T

    xid = 1:2*params.nx
    yid = 1:2*params.ny

    c = CartesianIndices((xid, yid))[:]

    linear_xid = map(i->i[1], c)
    linear_yid = map(i->i[2], c)

    @assert size(cov) == (params.nobs, length(c))

    for (i,ist,jst) in zip(1:params.nobs, stations.ist, stations.jst)
        cov[i,:] .= extended_covariance.(abs.(linear_xid .- ist) .* params.dx,
                                         abs.(linear_yid .- jst) .* params.dy,
                                         (params,))
    end

end

function covariance_stations_grid!(cov::AbstractMatrix{T}, params::TestParameters, stations::StationVectors) where T

    xid = 1:params.nx+1
    yid = 1:params.ny+1

    c = CartesianIndices((xid, yid))[:]

    @assert size(cov) == (length(c), params.nobs)

    linear_xid = map(i->i[1], c)
    linear_yid = map(i->i[2], c)

    for (i,ist,jst) in zip(1:params.nobs, stations.ist, stations.jst)
        x = abs.(linear_xid .- ist) .* params.dx
        y = abs.(linear_yid .- jst) .* params.dy
        cov[:,i] = extended_covariance.(x, y, Ref(params))
    end

end

# Covariance between observations R_22, from equation 3 in in Dietrich & Newsam 96
# TODO: Ask Alex why we add sigma^2 on the diagonal
function covariance_stations!(cov::AbstractMatrix{T}, params::TestParameters, stations::StationVectors) where T

    cov .= covariance.(abs.(stations.ist .- stations.ist') .* params.dx,
                       abs.(stations.jst' .- stations.jst) .* params.dy,
                       (params,)) .+ I(params.nobs) .* params.sigma_obs.^2

end

# First column vector rho_bar of covariance matrix among pairs of points of the extended grid R11_bar,
# from Dietrich & Newsam 96 described in text between equations 11 and 12
function first_column_covariance_extended_grid!(rho::AbstractVector{T}, params::TestParameters) where T

    xid = 1:2*params.nx
    yid = 1:2*params.ny

    c = CartesianIndices((xid, yid))[:]

    rho .= extended_covariance.((getindex.(c, 1) .- 1) .* params.dx,
                                (getindex.(c, 2) .- 1) .* params.dy,
                                (params,))


end

function normalized_2d_fft!(transformed_array::AbstractMatrix{T}, array::AbstractMatrix{S}, params::TestParameters) where {T,S}

    normalization_factor = 1.0 / sqrt(4 * params.nx * params.ny)
    transformed_array .= fft(array) .* normalization_factor

end

function normalized_2d_fft!(transformed_vector::AbstractVector{T}, vector::AbstractVector{S}, params::TestParameters) where {T,S}

    normalization_factor = 1.0 / sqrt(4 * params.nx * params.ny)
    transformed_vector .= fft(reshape(vector, 2*params.nx, 2*params.ny))[:] .* normalization_factor

end

function normalized_inverse_2d_fft!(transformed_array::AbstractMatrix{T}, array::AbstractMatrix{S}, params::TestParameters) where {T,S}

    normalization_factor = sqrt(4 * params.nx * params.ny)
    transformed_array .= ifft(array) .* normalization_factor

end

function normalized_inverse_2d_fft!(transformed_vector::AbstractVector{T}, vector::AbstractVector{S}, params::TestParameters) where {T,S}

    normalization_factor = sqrt(4 * params.nx * params.ny)
    transformed_vector .= ifft(reshape(vector, 2 * params.nx, 2 * params.ny))[:] .* normalization_factor

end

# Decomposition of R11, equation 12 of Deitrich and Newsam
function WΛWH_decomposition!(transformed_array::AbstractMatrix{T}, array::AbstractMatrix{T},
                             offline_matrices::OfflineMatrices, params::TestParameters) where T

    @assert size(array) == (params.nx + 1, params.ny + 1)

    extended_array = zeros(ComplexF64, 2*params.nx, 2*params.ny)

    extended_array[1:params.nx+1, 1:params.ny+1] .= array

    normalized_2d_fft!(extended_array, extended_array, params)

    # Here we do an element-wise multiplication of the extended_array with the vector Lambda. This is identical to
    # Diagonal(Lambda) * extended_array[:], but avoids flattening and reshaping extended_array.
    normalized_inverse_2d_fft!(extended_array, reshape(offline_matrices.Lambda, 2*params.nx, 2*params.ny).*extended_array, params)

    transformed_array .= real.(@view(extended_array[1:params.nx+1, 1:params.ny+1]))

end

# Get a vector of values of field at positions of [stations.ist, stations.jst]
function get_values_at_stations(field::AbstractMatrix{T}, stations::StationVectors) where T

    values = zeros(T, length(stations.ist))

    for (num,(i,j)) in enumerate(zip(stations.ist, stations.jst))
        values[num] = field[i,j]
    end

    return values

end

function init_offline_matrices(params::TestParameters, stations::StationVectors)

    n1 = (params.nx + 1) * (params.ny + 1) # number of elements in original grid
    n1_bar = 4 * params.nx * params.ny     # number of elements in extended grid

    F = Float64
    C = ComplexF64

    matrices = OfflineMatrices(Vector{F}(undef, n1_bar),                   #rho_bar
                               Matrix{F}(undef, n1, params.nobs),          #R12
                               Matrix{F}(undef, params.nobs, n1_bar),      #R21_bar
                               Matrix{F}(undef, params.nobs, params.nobs), #R22
                               Matrix{F}(undef, params.nobs, params.nobs), #R22_inv
                               Matrix{F}(undef, n1, params.nobs),          #R12_invR22
                               Vector{F}(undef, n1_bar),                   #Lambda (diagonal elements)
                               Matrix{C}(undef, params.nobs, n1_bar),      #K
                               Matrix{F}(undef, params.nobs, params.nobs), #L
                               Matrix{F}(undef, params.nobs, params.nobs), #mu20

                               Matrix{F}(undef, params.nx+1, params.ny+1), #buf1
                               Matrix{F}(undef, params.nx+1, params.ny+1)  #buf2
                               )

    first_column_covariance_extended_grid!(matrices.rho_bar, params)
    covariance_stations_grid!(matrices.R12, params, stations)
    covariance_stations_extended_grid!(matrices.R21_bar, params, stations)
    covariance_stations!(matrices.R22, params, stations)
    matrices.R22_inv .= inv(matrices.R22)
    matrices.R12_invR22 .= matrices.R12 * matrices.R22_inv

    fourier_coeffs = Vector{ComplexF64}(undef, n1_bar)
    normalized_inverse_2d_fft!(fourier_coeffs, matrices.rho_bar, params)
    matrices.Lambda .= sqrt(4 * params.nx * params.ny) .* real.(fourier_coeffs)

    WHbar_R12 = Matrix{C}(undef, n1_bar, params.nobs)
    for i in 1:params.nobs
        normalized_2d_fft!(@view(WHbar_R12[:,i]), @view(matrices.R21_bar[i,:]), params)
    end
    KH = Diagonal(matrices.Lambda)^(-1/2)*WHbar_R12
    matrices.K .= KH'

    A = real.(matrices.R22 .- matrices.K.*KH)
    if ishermitian(A)
        matrices.L .= cholesky(A).L
    end

    matrices.mu20 .= params.sigma_obs^(-2) .* (matrices.R22 .- I(params.nobs) .* params.sigma_obs^2)

    return matrices

end

function init_online_matrices(params::TestParameters)

    n1 = (params.nx + 1) * (params.ny + 1) # number of elements in original grid
    n1_bar = 4 * params.nx * params.ny # number of elements in extended grid

    C = ComplexF64

    matrices = OnlineMatrices(Vector{C}(undef, n1_bar),
                              Vector{C}(undef, params.nobs),
                              Matrix{C}(undef, params.nx+1, params.ny+1),
                              Matrix{C}(undef, params.nx+1, params.ny+1)
                              )

    return matrices


end

# Calculate the mean for the optimal proposal of the height
function calculate_mean_height!(mean::AbstractArray{T,3}, height::AbstractArray{T,3},
                                offline_matrices::OfflineMatrices, observations::AbstractVector{T},
                                stations::StationVectors, params::TestParameters) where T

    # The arguments for the WΛWH decompositions are matrices that only have nonzero values
    # at the indices of the stations. Store them as sparse arrays to save space.
    mu21 = sparse(stations.ist, stations.jst,
                  offline_matrices.R22_inv * (offline_matrices.mu20 * observations),
                  params.nx+1, params.ny+1)
    mu22 = params.sigma_obs^(-2) * sparse(stations.ist, stations.jst,
                                          observations,
                                          params.nx+1, params.ny+1)

    # Compute WΛWH decompositions, results are dense matrices, store them in buffers
    # These correspond to mu21 and mu22 in Alex's code
    WΛWH_decomposition!(offline_matrices.buf1, mu21, offline_matrices, params)
    WΛWH_decomposition!(offline_matrices.buf2, mu22, offline_matrices, params)

    # Compute the difference of the decomposition results, store in offline_matrices.buf1
    # This corresponds to mu2 in Alex's code.
    # TODO: Check if WΛWH is linear and you could swap the order
    offline_matrices.buf2 .-= offline_matrices.buf1

    mu10 = Vector{T}(undef, params.nobs)

    # Loop over particles
    for iprt = 1:params.nprt

        mu10 .= offline_matrices.R22_inv * get_values_at_stations(@view(height[iprt,:,:]), stations)
        mu10_sparse = sparse(stations.ist, stations.jst, mu10, params.nx+1, params.ny+1)

        # Compute decomposition of height values at stations times the inverse covariance matrix
        # The argument corresponds to mu10 and the outcome to mu11 in Alex's code
        WΛWH_decomposition!(offline_matrices.buf1, mu10_sparse, offline_matrices, params)

        # Compute the mean for the ith particle using mu2 and mu11
        # Skip storing the temporary mu1 in Alex's code
        mean[iprt,:,:] .= @view(height[iprt,:,:]) .- offline_matrices.buf1 .+ offline_matrices.buf2

    end

end

function sample_height_proposal!(samples::AbstractArray{T,3}, height::AbstractArray{T,3}, mean::AbstractArray{T,3},
                                 offline_matrices::OfflineMatrices, online_matrices::OnlineMatrices,
                                 observations::AbstractVector{T}, stations::StationVectors, params::TestParameters,
                                 rng::Random.AbstractRNG) where {T,S}

    @assert params.nprt % 2 == 0 "Number of particles must be even"

    calculate_mean_height!(mean, height, offline_matrices, observations, stations, params)

    #TODO: Can you create a Normal(0,1) distribution of complex type?
    nd = Normal(0,1)

    i_n1 = LinearIndices((params.nx+1, params.ny+1))
    i_n1_bar = LinearIndices((2*params.nx, 2*params.ny))

    for iprt in 1:2:params.nprt
        # TODO randn(ComplexF64) seems to set variance = 1/2. Could not find how to change that.
        # TODO we could pre-create all our random numbers in one go before the loop, would that be faster?
        e1 = rand(rng, nd, 4*params.nx*params.ny) + rand(rng, nd, 4*params.nx*params.ny)im
        e2 = rand(rng, nd, params.nobs) + rand(rng, nd, params.nobs)im

        # This gives the vector z1_bar
        normalized_inverse_2d_fft!(online_matrices.z1_bar, Diagonal(offline_matrices.Lambda)^(1/2) * e1, params)

        # This is the vector z2
        online_matrices.z2 .= offline_matrices.K * e1 + offline_matrices.L * e2

        # Restrict z1_bar to Omega1 and reshape into an array
        online_matrices.Z1 .= online_matrices.z1_bar[i_n1_bar[1:params.nx+1,1:params.nx+1]]
        # Multiply z2 with R12*R22^-1 and reshape the result into an array
        online_matrices.Z2 .= (offline_matrices.R12_invR22 * online_matrices.z2)[i_n1]

        samples[iprt,    :,:] .= mean[iprt,    :,:] + real.(online_matrices.Z1) - real.(online_matrices.Z2)
        samples[iprt + 1,:,:] .= mean[iprt + 1,:,:] + imag.(online_matrices.Z1) - imag.(online_matrices.Z2)

    end

end

function get_log_weights!(log_weights::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          obs::AbstractVector{T},
                          matrices::OfflineMatrices) where T

    #TODO: Is this just the same as get_log_weights! in ParticleDA with R22_inv as cov_obs?

    nprt = size(obs_model,1)

    for iprt in 1:nprt

        log_weights[iprt] = -0.5 * (obs - obs_model[i,:])' * matrices.R22_inv * (obs - obs_model[i,:])

    end

    #Normalization is done in a separate function due to parallelism optimisation

end

@testset "Optimal Filter unit tests" begin

    seed = 123
    Random.seed!(seed)

    # Use default parameters
    params = TestParameters()
    # Set station coordinates
    ist = rand(1:params.nx, 3)
    jst = rand(1:params.ny, 3)
    stations = StationVectors(ist, jst)
    cov_ext = extended_covariance(0.0, 0.5 * params.y_length, params)
    @test cov_ext ≈ exp(-0.5 * params.y_length / (2 * params.lambda_cov))
    @test cov_ext ≈ extended_covariance(2.0 * params.x_length, 0.5 * params.y_length, params)
    @test cov_ext ≈ extended_covariance(0.0, 1.5 * params.y_length, params)
    arr = rand(ComplexF64,10,10)
    arr2 = zeros(ComplexF64,10,10)
    arr3 = zeros(ComplexF64,10,10)
    normalized_2d_fft!(arr2,arr,params)
    normalized_inverse_2d_fft!(arr3,arr2,params)
    @test arr ≈ arr3

    cov_1 = zeros(params.nobs,4*params.nx*params.ny)
    cov_2 = zeros((1+params.nx)*(1+params.ny), params.nobs)
    cov_3 = zeros(params.nobs,params.nobs)
    covariance_stations_extended_grid!(cov_1,params,stations)
    covariance_stations_grid!(cov_2,params,stations)
    covariance_stations!(cov_3,params,stations)
    @test all(isfinite.(cov_1))
    @test all(isfinite.(cov_2))
    @test all(isfinite.(cov_3))
    @test cov_3 == Symmetric(cov_3)

    mean = Array{Float64}(undef, params.nprt, params.nx+1, params.ny+1)
    height = rand(params.nprt, params.nx+1, params.ny+1)
    obs = randn(params.nobs)
    mat_off = init_offline_matrices(params, stations)
    @test minimum(mat_off.Lambda) > 0.0
    calculate_mean_height!(mean, height, mat_off, obs, stations, params)
    @test all(isfinite.(mean))

    rng = Random.MersenneTwister(seed)
    mat_on = init_online_matrices(params)
    samples = Array{Float64}(undef, params.nprt, params.nx+1, params.ny+1)
    sample_height_proposal!(samples, height, mean, mat_off, mat_on, obs, stations, params, rng)
    @test all(isfinite.(samples))

end

using BenchmarkTools

@testset "Optimal Filter validation" begin

    seed = 123
    Random.seed!(seed)
    rng = Random.MersenneTwister(seed)

    include("/Users/tkoskela/git_repos/raddish/mini_apps/optimal_particle_filter/Sample_Optimal_Height_Proposal.jl");

    params = TestParameters(nprt=2)
    stations = StationVectors(st.st_ij[:,1].+1, st.st_ij[:,2].+1)

    h(x,y) = 1 - (x-params.nx-1)^2 - (y-params.ny-1)^2 + randn()
    height = zeros(params.nprt, params.nx+1, params.ny+1)
    x = (1:params.nx+1) .* params.dx
    y = (1:params.ny+1) .* params.dy
    for i = 1:params.nprt
        height[i,:,:] = h.(x',y)
    end

    obs = zeros(params.nobs)
    for i = 1:params.nobs
        obs[i] = height[1,stations.ist[i], stations.jst[i]] + rand()
    end

    mean_height = Array{Float64}(undef, params.nprt, params.nx+1, params.ny+1)
    samples = Array{Float64}(undef, params.nprt, params.nx+1, params.ny+1)

    mat_off = init_offline_matrices(params, stations)
    mat_on = init_online_matrices(params)

    calculate_mean_height!(mean_height, height, mat_off, obs, stations, params)
    sample_height_proposal!(samples, height, mean_height, mat_off, mat_on, obs, stations, params, rng)

    Yobs_t = copy(obs)
    FH_t = copy(reshape(height, params.nprt, (params.nx+1)*(params.ny+1)))

    Mean_height = Calculate_Mean(FH_t, th, st, Yobs_t, Sobs, gr)
    Samples = Sample_Height_Proposal(FH_t, th, st, Yobs_t, Sobs, gr)

    print("old mean height: ")
    @btime Mean_height = Calculate_Mean(FH_t, th, st, Yobs_t, Sobs, gr)
    print("new mean height: ")
    @btime calculate_mean_height!(mean_height, height, mat_off, obs, stations, params)
    print("old sampling: ")
    @btime Samples = Sample_Height_Proposal(FH_t, th, st, Yobs_t, Sobs, gr)
    print("new sampling: ")
    @btime sample_height_proposal!(samples, height, mean_height, mat_off, mat_on, obs, stations, params, rng)

    @test mean_height ≈ reshape(Mean_height, params.nprt, params.nx+1, params.ny+1)
    @test samples ≈ reshape(Samples, params.nprt, params.nx+1, params.ny+1)

end
