using FFTW
using LinearAlgebra
using Test

Base.@kwdef struct TestParameters{T<:AbstractFloat}

    nx::Int = 10
    ny::Int = 10
    x_length::T = 2.0
    y_length::T = 2.0
    dx::T = x_length / nx
    dy::T = y_length / ny

    sigma_cov::T = 1.0
    lambda_cov::T = 10.0

    sigma_obs::T = 1.0
    nobs = 4

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T

end


# Covariance function r(x,y), equation 1 in Dietrich and Newsam 96
function covariance(x::T, y::T, params::TestParameters) where T

    return params.sigma_cov^2 * exp(-(abs(x) + abs(y))/(2 * params.lambda_cov))

end

# Extended covariance function /bar r(x,y), equation 8 of Dietrich and Newsam 96
function extended_covariance(x::T, y::T, params::TestParameters) where T

    if (0 <= x) & (x <= params.x_length)
        x_ext = x
    elseif (params.x_length <= x) & (x <= 2 * params.x_length)
        x_ext = 2 * params.x_length - x
    else
        @error "value of x is out of bounds"
    end

    if (0 <= y) & (y <= params.y_length)
        y_ext = y
    elseif (params.y_length <= y) & (y <= 2 * params.y_length)
        y_ext = 2 * params.y_length - y
    else
        @error "value of y is out of bounds"
    end

    return covariance(x_ext, y_ext, params::TestParameters)

end

# Covariance between observations and the extended grid /bar R_21, from equation 11 in Dietrich & Newsam 96
function covariance_stations_extended_grid!(cov::AbstractArray{T,3}, params::TestParameters, stations::StationVectors) where T

    xid = (0:2*params.nx - 1)'
    yid = (0:2*params.ny - 1)

    @assert size(cov,1) == params.nobs
    @assert size(cov,2) == length(xid)
    @assert size(cov,3) == length(yid)

    # TODO: Use CartesianIndices instead of i
    for (i,ist,jst) in zip(1:params.nobs, stations.ist, stations.jst)
        x = abs.(xid .- ist) .* params.dx
        y = abs.(yid .- jst) .* params.dy
        cov[i,:,:] = extended_covariance.(x, y, Ref(params))
    end

end

function covariance_stations_grid!(cov::AbstractArray{T,3}, params::TestParameters, stations::StationVectors) where T

    xid = (0:params.nx)'
    yid = (0:params.ny)

    @assert size(cov,1) == params.nobs
    @assert size(cov,2) == length(xid)
    @assert size(cov,3) == length(yid)

    # TODO: Use CartesianIndices instead of i
    for (i,ist,jst) in zip(1:params.nobs, stations.ist, stations.jst)
        x = abs.(xid .- ist) .* params.dx
        y = abs.(yid .- jst) .* params.dy
        cov[i,:,:] = extended_covariance.(x, y, Ref(params))
    end

end

# Covariance between observations R_22, from equation 11 in in Dietrich & Newsam 96
function covariance_stations!(cov::AbstractArray{T,2}, params::TestParameters, stations::StationVectors) where T

    x = abs.(stations.ist .- stations.ist') * params.dx
    y = abs.(stations.jst' .- stations.jst) * params.dy

    @assert size(cov) == size(x)
    @assert size(cov) == size(y)

    cov .= covariance.(x, y, Ref(params)) + I(length(stations.ist)) * params.sigma_obs^2

end

function normalized_2d_fft!(transformed_array::AbstractArray{T}, array::AbstractArray{T}, params::TestParameters) where T

    normalization_factor = 1.0 / sqrt(4 * params.nx * params.ny)
    transformed_array .= fft(array) .* normalization_factor

end

function normalized_inverse_2d_fft!(transformed_array::AbstractArray{T}, array::AbstractArray{T}, params::TestParameters) where T

    normalization_factor = sqrt(4 * params.nx * params.ny)
    transformed_array .= ifft(array) .* normalization_factor

end

# Decomposition of R11, equation 12 of Deitrich and Newsam
function WΛWH_decomposition!(transformed_array::AbstractArray{T}, array::AbstractArray{T}, params::TestParameters) where T

    @assert size(array) == (params.nx + 1, params.ny + 1)

    extended_array = zeros(2*params.nx, 2*params.ny)

    extended_array[1:params.nx+1, 1:params.ny+1] .= array

    x = 1:2*params.nx * params.dx
    y = 1:2*params.ny * params.dy

    cov_ext = covariance.(x',y, Ref(params))

    #TODO: Ask Alex about dimension of bar_rho and multiplication with Diagonal(Lambda)

end

function calculate_mean_height!(mean::AbstractArray{T,3}, height::AbstractArray{T,3}, buffer::AbstractArray{T,2},
                                covariance_stations::AbstractMatrix{T}, inv_covariance_stations::AbstractMatrix{T},
                                observations::AbstractVector{T}, params::TestParameters)

    mu20 = params.sigma_obs^(-2) * (covariance_stations - I(params.nobs) * params.sigma_obs)
    mu21 = zeros(2*params.nx, 2*params.ny)
    mu22 = zeros(2*params.nx, 2*params.ny)

    buffer = inv_covariance_stations * (mu20 * observations)
    
    WΛWH_decomposition(mu21, buffer, params)
    WΛWH_decomposition(mu22, buffer, params)

end

@testset "Optimal Filter unit tests" begin
    params = TestParameters()
    stations = StationVectors([0,0,1,1],[0,1,0,1])
    cov_ext = extended_covariance(0.0, 1.0, params)
    @test cov_ext ≈ exp(-1/20)
    @test cov_ext ≈ extended_covariance(4.0, 1.0, params)
    @test cov_ext ≈ extended_covariance(0.0, 3.0, params)
    arr = rand(ComplexF64,10,10)
    arr2 = zeros(ComplexF64,10,10)
    arr3 = zeros(ComplexF64,10,10)
    normalized_2d_fft!(arr2,arr,params)
    normalized_inverse_2d_fft!(arr3,arr2,params)
    @test arr ≈ arr3

    cov_1 = zeros(params.nobs,2*params.nx,2*params.ny)
    cov_2 = zeros(params.nobs,1+params.nx,1+params.ny)
    cov_3 = zeros(params.nobs,params.nobs)
    covariance_stations_extended_grid!(cov_1,params,stations)
    covariance_stations_grid!(cov_2,params,stations)
    covariance_stations!(cov_3,params,stations)
    @test norm(cov_1) ≈ 36.25505783799344
    @test norm(cov_2) ≈ 20.107727592303476
    @test norm(cov_3) ≈ 5.261629704099609
    @test cov_3 == Symmetric(cov_3)
end
