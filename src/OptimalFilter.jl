using FFTW
using LinearAlgebra
using Test
using SparseArrays
using Random
using Distributions

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


struct OnlineMatrices{T<:AbstractVector, S<:AbstractArray, U<:AbstractArray}

    z1_bar::T
    z2::T

    Z1::S
    Z2::S

    samples::U
    mean::U

end

# Covariance function r(x,y), equation 1 in Dietrich and Newsam 96
function covariance(x::T, y::T, filter_params) where T

    return filter_params.sigma_cov^2 * exp(-(abs(x) + abs(y))/(2 * filter_params.lambda_cov))

end

# Extended covariance function /bar r(x,y), equation 8 of Dietrich and Newsam 96
function extended_covariance(x::T, y::T, model_params, filter_params) where T

    if 0 <= x <= model_params.x_length
        x_ext = x
    elseif model_params.x_length <= x <= 2 * model_params.x_length
        x_ext = 2 * model_params.x_length - x
    else
        @error "value of x is out of bounds"
    end

    if 0 <= y <= model_params.y_length
        y_ext = y
    elseif model_params.y_length <= y <= 2 * model_params.y_length
        y_ext = 2 * model_params.y_length - y
    else
        @error "value of y is out of bounds"
    end

    return covariance(x_ext, y_ext, filter_params)

end

# Covariance between observations and the extended grid /bar R_21, from equation 11 in Dietrich & Newsam 96
function covariance_stations_extended_grid!(cov::AbstractMatrix{T}, model_params, filter_params, stations) where T

    xid = 1:2*model_params.nx
    yid = 1:2*model_params.ny

    c = CartesianIndices((xid, yid))[:]

    @assert size(cov) == (model_params.nobs, length(c))

    for (i,ist,jst) in zip(1:model_params.nobs, stations.ist, stations.jst)
        cov[i,:] .= extended_covariance.(abs.(getindex.(c, 1) .- ist) .* model_params.dx,
                                         abs.(getindex.(c, 2) .- jst) .* model_params.dy,
                                         (model_params,), (filter_params,))
    end

end

# Covariance between stations and the original grid R_21, from equations 3-4 in Dietrich & Newsam 96
function covariance_stations_grid!(cov::AbstractMatrix{T}, model_params, filter_params, stations) where T

    xid = 1:model_params.nx+1
    yid = 1:model_params.ny+1

    c = CartesianIndices((xid, yid))[:]

    @assert size(cov) == (length(c), model_params.nobs)

    for (i,ist,jst) in zip(1:model_params.nobs, stations.ist, stations.jst)
        cov[:,i] .= extended_covariance.(abs.(getindex.(c, 1) .- ist) .* model_params.dx,
                                         abs.(getindex.(c, 2) .- jst) .* model_params.dy,
                                         (model_params,), (filter_params,))
    end

end

# Covariance between observations R_22, from equationd 3-4 in in Dietrich & Newsam 96
# TODO: Ask Alex why we add sigma^2 on the diagonal
function covariance_stations!(cov::AbstractMatrix{T}, model_params, filter_params, stations) where T

    cov .= covariance.(abs.(stations.ist .- stations.ist') .* model_params.dx,
                       abs.(stations.jst' .- stations.jst) .* model_params.dy,
                       (filter_params,)) .+ I(model_params.nobs) .* model_params.obs_noise_std.^2

end

# First column vector rho_bar of covariance matrix among pairs of points of the extended grid R11_bar,
# from Dietrich & Newsam 96 described in text between equations 11 and 12
function first_column_covariance_extended_grid!(rho::AbstractVector{T}, model_params, filter_params) where T

    xid = 1:2*model_params.nx
    yid = 1:2*model_params.ny

    c = CartesianIndices((xid, yid))[:]

    rho .= extended_covariance.((getindex.(c, 1) .- 1) .* model_params.dx,
                                (getindex.(c, 2) .- 1) .* model_params.dy,
                                (model_params,), (filter_params,))


end

# Normalized two-dimension discrete Fourier transofrm normalized by sqrt(n1_bar).
# Operates on the 2d data stored as a matrix.
# From Dietrich & Newsam 96 in text following equation 12
function normalized_2d_fft!(transformed_array::AbstractMatrix{T}, array::AbstractMatrix{S}, model_params) where {T,S}

    normalization_factor = 1.0 / sqrt(4 * model_params.nx * model_params.ny)
    transformed_array .= fft(array) .* normalization_factor

end

# Normalized two-dimension discrete Fourier transofrm normalized by sqrt(n1_bar).
# Operates on the 2d data stored as a vector.
# From Dietrich & Newsam 96 in text following equation 12
function normalized_2d_fft!(transformed_vector::AbstractVector{T}, vector::AbstractVector{S}, model_params) where {T,S}

    normalization_factor = 1.0 / sqrt(4 * model_params.nx * model_params.ny)
    transformed_vector .= fft(reshape(vector, 2*model_params.nx, 2*model_params.ny))[:] .* normalization_factor

end

# Normalized inverse two-dimension discrete Fourier transofrm normalized by sqrt(n1_bar).
# Operates on the 2d data stored as a matrix.
# From Dietrich & Newsam 96 in text following equation 12
function normalized_inverse_2d_fft!(transformed_array::AbstractMatrix{T}, array::AbstractMatrix{S}, model_params) where {T,S}

    normalization_factor = sqrt(4 * model_params.nx * model_params.ny)
    transformed_array .= ifft(array) .* normalization_factor

end

# Normalized inverse two-dimension discrete Fourier transofrm normalized by sqrt(n1_bar).
# Operates on the 2d data stored as a vector.
# From Dietrich & Newsam 96 in text following equation 12
function normalized_inverse_2d_fft!(transformed_vector::AbstractVector{T}, vector::AbstractVector{S}, model_params) where {T,S}

    normalization_factor = sqrt(4 * model_params.nx * model_params.ny)
    transformed_vector .= ifft(reshape(vector, 2 * model_params.nx, 2 * model_params.ny))[:] .* normalization_factor

end

# Decomposition of R11, equation 12 of Deitrich and Newsam
function WΛWH_decomposition!(transformed_array::AbstractMatrix{T}, array::AbstractMatrix{T},
                             offline_matrices::OfflineMatrices, params) where T

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
function get_values_at_stations(field::AbstractMatrix{T}, stations) where T

    values = zeros(T, length(stations.ist))

    for (num,(i,j)) in enumerate(zip(stations.ist, stations.jst))
        values[num] = field[i,j]
    end

    return values

end

# Allocate and compute matrices that do not depend on time-dependent variables (height and observations).
function init_offline_matrices(model_params, filter_params, stations)

    n1 = (model_params.nx + 1) * (model_params.ny + 1) # number of elements in original grid
    n1_bar = 4 * model_params.nx * model_params.ny     # number of elements in extended grid

    F = Float64
    C = ComplexF64

    matrices = OfflineMatrices(Vector{F}(undef, n1_bar),                   #rho_bar
                               Matrix{F}(undef, n1, model_params.nobs),          #R12
                               Matrix{F}(undef, model_params.nobs, n1_bar),      #R21_bar
                               Matrix{F}(undef, model_params.nobs, model_params.nobs), #R22
                               Matrix{F}(undef, model_params.nobs, model_params.nobs), #R22_inv
                               Matrix{F}(undef, n1, model_params.nobs),          #R12_invR22
                               Vector{F}(undef, n1_bar),                   #Lambda (diagonal elements)
                               Matrix{C}(undef, model_params.nobs, n1_bar),      #K
                               Matrix{F}(undef, model_params.nobs, model_params.nobs), #L
                               Matrix{F}(undef, model_params.nobs, model_params.nobs), #mu20

                               Matrix{F}(undef, model_params.nx+1, model_params.ny+1), #buf1
                               Matrix{F}(undef, model_params.nx+1, model_params.ny+1)  #buf2
                               )

    first_column_covariance_extended_grid!(matrices.rho_bar, model_params, filter_params)
    covariance_stations_grid!(matrices.R12, model_params, filter_params, stations)
    covariance_stations_extended_grid!(matrices.R21_bar, model_params, filter_params, stations)
    covariance_stations!(matrices.R22, model_params, filter_params, stations)
    matrices.R22_inv .= inv(matrices.R22)
    matrices.R12_invR22 .= matrices.R12 * matrices.R22_inv

    fourier_coeffs = Vector{ComplexF64}(undef, n1_bar)
    normalized_inverse_2d_fft!(fourier_coeffs, matrices.rho_bar, model_params)
    matrices.Lambda .= sqrt(4 * model_params.nx * model_params.ny) .* real.(fourier_coeffs)

    WHbar_R12 = Matrix{C}(undef, n1_bar, model_params.nobs)
    for i in 1:model_params.nobs
        normalized_2d_fft!(@view(WHbar_R12[:,i]), @view(matrices.R21_bar[i,:]), model_params)
    end
    KH = Diagonal(matrices.Lambda)^(-1/2)*WHbar_R12
    matrices.K .= KH'

    A = real.(matrices.R22 .- matrices.K*KH)
    if ishermitian(A)
        matrices.L .= cholesky(A).L
    end

    matrices.mu20 .= model_params.obs_noise_std^(-2) .* (matrices.R22 .- I(model_params.nobs) .* model_params.obs_noise_std^2)

    return matrices

end

# Allocate memory for matrices that will be updated during the time stepping loop.
function init_online_matrices(model_params, filter_params)

    n1 = (model_params.nx + 1) * (model_params.ny + 1) # number of elements in original grid
    n1_bar = 4 * model_params.nx * model_params.ny # number of elements in extended grid

    C = ComplexF64
    F = Float64

    matrices = OnlineMatrices(Vector{C}(undef, n1_bar),
                              Vector{C}(undef, model_params.nobs),
                              Matrix{C}(undef, model_params.nx+1, model_params.ny+1),
                              Matrix{C}(undef, model_params.nx+1, model_params.ny+1),
                              Array{F}(undef, model_params.nx+1, model_params.ny+1, filter_params.nprt),
                              Array{F}(undef, model_params.nx+1, model_params.ny+1, filter_params.nprt)
                              )

    return matrices


end

# Calculate the mean for the optimal proposal of the height
function calculate_mean_height!(mean::AbstractArray{T,3}, height::AbstractArray{T,3},
                                offline_matrices::OfflineMatrices, observations::AbstractVector{T},
                                stations, model_params, filter_params) where T

    # The arguments for the WΛWH decompositions are matrices that only have nonzero values
    # at the indices of the stations. Store them as sparse arrays to save space.
    mu21 = sparse(stations.ist, stations.jst,
                  offline_matrices.R22_inv * (offline_matrices.mu20 * observations),
                  model_params.nx+1, model_params.ny+1)
    mu22 = model_params.obs_noise_std^(-2) * sparse(stations.ist, stations.jst,
                                          observations,
                                          model_params.nx+1, model_params.ny+1)

    # Compute WΛWH decompositions, results are dense matrices, store them in buffers
    # These correspond to mu21 and mu22 in Alex's code
    WΛWH_decomposition!(offline_matrices.buf1, mu21, offline_matrices, model_params)
    WΛWH_decomposition!(offline_matrices.buf2, mu22, offline_matrices, model_params)

    # Compute the difference of the decomposition results, store in offline_matrices.buf1
    # This corresponds to mu2 in Alex's code.
    # TODO: Check if WΛWH is linear and you could swap the order
    offline_matrices.buf2 .-= offline_matrices.buf1

    mu10 = Vector{T}(undef, model_params.nobs)

    # Loop over particles
    for iprt = 1:filter_params.nprt

        mul!(mu10, offline_matrices.R22_inv, get_values_at_stations(@view(height[:,:,iprt]), stations))
        mu10_sparse = sparse(stations.ist, stations.jst, mu10, model_params.nx+1, model_params.ny+1)

        # Compute decomposition of height values at stations times the inverse covariance matrix
        # The argument corresponds to mu10 and the outcome to mu11 in Alex's code
        WΛWH_decomposition!(offline_matrices.buf1, mu10_sparse, offline_matrices, model_params)

        # Compute the mean for the ith particle using mu2 and mu11
        # Skip storing the temporary mu1 in Alex's code
        mean[:,:,iprt] .= @view(height[:,:,iprt]) .- offline_matrices.buf1 .+ offline_matrices.buf2

    end

end

function sample_height_proposal!(height::AbstractArray{T,3},
                                 offline_matrices::OfflineMatrices, online_matrices::OnlineMatrices,
                                 observations::AbstractVector{T}, stations, model_params, filter_params,
                                 rng::Random.AbstractRNG) where T

    @assert filter_params.nprt % 2 == 0 "Number of particles must be even"

    calculate_mean_height!(online_matrices.mean, height, offline_matrices, observations, stations, model_params, filter_params)

    i_n1 = LinearIndices((model_params.nx+1, model_params.ny+1))
    i_n1_bar = LinearIndices((2*model_params.nx, 2*model_params.ny))

    for iprt in 1:2:filter_params.nprt
        # TODO we could pre-create all our random numbers in one go before the loop, would that be faster?
        e1 = complex.(randn(rng, 4*model_params.nx*model_params.ny), randn(rng, 4*model_params.nx*model_params.ny))
        e2 = complex.(randn(rng, model_params.nobs), randn(rng, model_params.nobs))

        # This gives the vector z1_bar
        normalized_inverse_2d_fft!(online_matrices.z1_bar, Diagonal(offline_matrices.Lambda)^(1/2) * e1, model_params)

        # This is the vector z2
        online_matrices.z2 .= offline_matrices.K * e1 .+ offline_matrices.L * e2

        # Restrict z1_bar to Omega1 and reshape into an array
        online_matrices.Z1 .= online_matrices.z1_bar[i_n1_bar[1:model_params.nx+1,1:model_params.nx+1]]
        # Multiply z2 with R12*R22^-1 and reshape the result into an array
        online_matrices.Z2 .= (offline_matrices.R12_invR22 * online_matrices.z2)[i_n1]

        online_matrices.samples[:,:,iprt    ] .= @view(online_matrices.mean[:,:,iprt    ]) .+ real.(online_matrices.Z1 .- online_matrices.Z2)
        online_matrices.samples[:,:,iprt + 1] .= @view(online_matrices.mean[:,:,iprt + 1]) .+ imag.(online_matrices.Z1 .- online_matrices.Z2)

    end

end

function get_log_weights!(log_weights::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          obs::AbstractVector{T},
                          matrices::OfflineMatrices) where T

    #TODO: Is this just the same as get_log_weights! in ParticleDA with R22_inv as cov_obs?
    # DONE: No, ParticleDA.get_log_weights! fails with
    # ERROR: PosDefException: matrix is not Hermitian; Cholesky factorization failed.

    nprt = size(obs_model,1)

    for iprt in 1:nprt

        log_weights[iprt] = -0.5 * (obs - obs_model[:,iprt])' * matrices.R22_inv * (obs - obs_model[:,iprt])

    end

    #Normalization is done in a separate function due to parallelism optimisation

end
