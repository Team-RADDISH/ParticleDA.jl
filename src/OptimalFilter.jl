using FFTW
using LinearAlgebra
using SparseArrays
using Random
using Distributions
using GaussianRandomFields

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

struct Grid{T}
    nx::Int
    ny::Int
    dx::T
    dy::T
    x_length::T
    y_length::T
end

# Covariance function r(x,y), equation 1 in Dietrich & Newsam 1996
function covariance(x::T, y::T, covariance_structure::IsotropicCovarianceStructure{T}) where T
    return covariance_structure.σ^2 * apply(covariance_structure, [x, y])
end

# Extended covariance function ̄r(x,y), equation 8 of Dietrich & Newsam 1996
function extended_covariance(x::T, y::T, grid::Grid, covariance_structure::IsotropicCovarianceStructure{T}) where T

    if 0 <= x <= grid.x_length
        x_ext = x
    elseif grid.x_length <= x <= 2 * grid.x_length
        x_ext = 2 * grid.x_length - x
    else
        @error "value of x is out of bounds"
    end

    if 0 <= y <= grid.y_length
        y_ext = y
    elseif grid.y_length <= y <= 2 * grid.y_length
        y_ext = 2 * grid.y_length - y
    else
        @error "value of y is out of bounds"
    end

    return covariance(x_ext, y_ext, covariance_structure)

end

# Covariance between observations and the extended grid R̅₂₁, from equation 11 in Dietrich & Newsam 1996
function covariance_stations_extended_grid!(
    cov::AbstractMatrix{T},
    grid::Grid,
    grid_ext::Grid,
    stations::NamedTuple,
    covariance_structure::IsotropicCovarianceStructure{T}
) where T

    xid = 1:grid_ext.nx
    yid = 1:grid_ext.ny

    c = CartesianIndices((xid, yid))[:]

    @assert size(cov) == (stations.nst, length(c))

    for (i,ist,jst) in zip(1:stations.nst, stations.ist, stations.jst)
        cov[i,:] .= extended_covariance.(abs.(getindex.(c, 1) .- ist) .* grid_ext.dx,
                                         abs.(getindex.(c, 2) .- jst) .* grid_ext.dy,
                                         (grid,), (covariance_structure,))
    end

end

# Covariance between stations and the original grid R₂₁, from equations 3 and 4 in Dietrich & Newsam 1996
function covariance_grid_stations!(cov::AbstractMatrix{T}, grid::Grid, stations::NamedTuple, covariance_structure::IsotropicCovarianceStructure{T}) where T

    xid = 1:grid.nx
    yid = 1:grid.ny

    c = CartesianIndices((xid, yid))[:]

    @assert size(cov) == (length(c), stations.nst)

    for (i,ist,jst) in zip(1:stations.nst, stations.ist, stations.jst)
        cov[:,i] .= extended_covariance.(abs.(getindex.(c, 1) .- ist) .* grid.dx,
                                         abs.(getindex.(c, 2) .- jst) .* grid.dy,
                                         (grid,), (covariance_structure,))
    end

end

# Covariance between observations R̅₂₂ = R₂₂ + Σ, where R₂₂ is as defined in equations 3 and 4 in
# Dietrich & Newsam 96 and Σ is the observation noise covariance (see note at end of
# Section 2 in Dietrich & Newsam 1996)
function covariance_stations!(cov::AbstractMatrix{T}, grid::Grid, stations::NamedTuple, covariance_structure::IsotropicCovarianceStructure{T}, std::T) where T

    cov .= covariance.(abs.(stations.ist .- stations.ist') .* grid.dx,
                       abs.(stations.jst' .- stations.jst) .* grid.dy,
                       (covariance_structure,)) .+ I(stations.nst) .* std.^2

end

# First column vector rho_bar of covariance matrix among pairs of points of the extended grid R̅₁₁,
# from Dietrich & Newsam 1996 described in text between equations 11 and 12
function first_column_covariance_grid!(rho::AbstractVector{T}, grid::Grid, grid_ext::Grid, covariance_structure::IsotropicCovarianceStructure{T}) where T

    xid = 1:grid_ext.nx
    yid = 1:grid_ext.ny

    c = CartesianIndices((xid, yid))[:]

    rho .= extended_covariance.((getindex.(c, 1) .- 1) .* grid_ext.dx,
                                (getindex.(c, 2) .- 1) .* grid_ext.dy,
                                (grid,), (covariance_structure,))


end

# Normalized two-dimension discrete Fourier transofrm normalized by sqrt(̄n₁).
# Operates on the 2d data stored as a matrix.
# The argument `f` lets you switch between forward transform (`f=identity`) and
# inverse transform (`f=inv`).
# From Dietrich & Newsam 96 in text following equation 12
function normalized_2d_fft!(transformed_array::AbstractMatrix{<:Complex}, array::AbstractMatrix{S}, fft_plan::FFTW.FFTWPlan, fft_plan!::FFTW.FFTWPlan, grid_ext, f=identity) where {S}

    normalization_factor = f(sqrt(grid_ext.nx * grid_ext.ny))
    if pointer(transformed_array) == pointer(array)
        mul!(transformed_array, f(fft_plan!), array)
    else
        mul!(transformed_array, f(fft_plan), array)
    end
    transformed_array ./= normalization_factor

end

# Normalized two-dimension discrete Fourier transofrm normalized by sqrt(̄n₁).
# Operates on the 2d data stored as a vector.
# The argument `f` lets you switch between forward transform (`f=identity`) and
# inverse transform (`f=inv`).
# From Dietrich & Newsam 96 in text following equation 12
function normalized_2d_fft!(transformed_vector::AbstractVector{<:Complex}, vector::AbstractVector{S}, fft_plan::FFTW.FFTWPlan, fft_plan!::FFTW.FFTWPlan, grid_ext, f=identity) where {S}

    normalization_factor = f(sqrt(grid_ext.nx * grid_ext.ny))
    tmp_array = complex(reshape(vector, grid_ext.nx, grid_ext.ny))
    mul!(tmp_array, f(fft_plan!), tmp_array)
    transformed_vector .= @view(tmp_array[:]) ./ normalization_factor

end

# Decomposition of R̅₁₁, equation 12 of Deitrich & Newsam 1996
function WΛWH_decomposition!(transformed_array::AbstractMatrix{T},
                             array::AbstractMatrix{T},
                             offline_matrices::OfflineMatrices,
                             grid::Grid,
                             grid_ext::Grid,
                             fft_plan::FFTW.FFTWPlan,
                             fft_plan!::FFTW.FFTWPlan,
                             ) where T

    @assert size(array) == (grid.nx, grid.ny)

    extended_array = zeros(ComplexF64, grid_ext.nx, grid_ext.ny)

    extended_array[1:grid.nx, 1:grid.ny] .= array

    normalized_2d_fft!(extended_array, extended_array, fft_plan, fft_plan!, grid_ext)

    # Here we do an element-wise multiplication of the extended_array with the vector Lambda. This is identical to
    # Diagonal(Lambda) * extended_array[:], but avoids flattening and reshaping extended_array.
    normalized_2d_fft!(extended_array, reshape(offline_matrices.Lambda, grid_ext.nx, grid_ext.ny).*extended_array, fft_plan, fft_plan!, grid_ext, inv)

    transformed_array .= real.(@view(extended_array[1:grid.nx, 1:grid.ny]))

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
function init_offline_matrices(grid::Grid,
                               grid_ext::Grid,
                               stations::NamedTuple,
                               covariance_structure::IsotropicCovarianceStructure{T},
                               obs_noise_std::T,
                               fft_plan::FFTW.FFTWPlan,
                               fft_plan!::FFTW.FFTWPlan,
                               F::Type,
                               ) where T

    n1 = grid.nx * grid.ny # number of elements in original grid
    n1_bar = grid_ext.nx * grid_ext.ny # number of elements in extended grid

    C = complex(F)

    matrices = OfflineMatrices(Vector{F}(undef, n1_bar),                   #rho_bar
                               Matrix{F}(undef, n1, stations.nst),          #R12
                               Matrix{F}(undef, stations.nst, n1_bar),      #R21_bar
                               Matrix{F}(undef, stations.nst, stations.nst), #R22
                               Matrix{F}(undef, stations.nst, stations.nst), #R22_inv
                               Matrix{F}(undef, n1, stations.nst),          #R12_invR22
                               Vector{F}(undef, n1_bar),                   #Lambda (diagonal elements)
                               Matrix{C}(undef, stations.nst, n1_bar),      #K
                               Matrix{F}(undef, stations.nst, stations.nst), #L
                               Matrix{F}(undef, stations.nst, stations.nst), #mu20

                               Matrix{F}(undef, grid.nx, grid.ny), #buf1
                               Matrix{F}(undef, grid.nx, grid.ny)  #buf2
                               )

    first_column_covariance_grid!(matrices.rho_bar, grid, grid_ext, covariance_structure)
    covariance_grid_stations!(matrices.R12, grid, stations, covariance_structure)
    covariance_stations_extended_grid!(matrices.R21_bar, grid, grid_ext, stations, covariance_structure)
    covariance_stations!(matrices.R22, grid, stations, covariance_structure, obs_noise_std)
    matrices.R22_inv .= inv(matrices.R22)
    matrices.R12_invR22 .= matrices.R12 * matrices.R22_inv

    fourier_coeffs = Vector{C}(undef, n1_bar)
    normalized_2d_fft!(fourier_coeffs, matrices.rho_bar, fft_plan, fft_plan!, grid_ext, inv)
    matrices.Lambda .= sqrt(n1_bar) .* real.(fourier_coeffs)

    WHbar_R12 = Matrix{C}(undef, n1_bar, stations.nst)
    for i in 1:stations.nst
        normalized_2d_fft!(@view(WHbar_R12[:,i]), @view(matrices.R21_bar[i,:]), fft_plan, fft_plan!, grid_ext)
    end
    KH = Diagonal(matrices.Lambda)^(-1/2)*WHbar_R12
    matrices.K .= KH'

    A = real.(matrices.R22 .- matrices.K*KH)

    if A ≈ Hermitian(A)
        matrices.L .= cholesky(Hermitian(A)).L
    else
        error("R22 - K*KH is not hermitian! Increasing the grid size may help. See Dietrich and Newsam '96 for details.")
    end

    matrices.mu20 .= obs_noise_std^(-2) .* (matrices.R22 .- I(stations.nst) .* obs_noise_std^2)

    return matrices

end

# Allocate memory for matrices that will be updated during the time stepping loop.
function init_online_matrices(grid::Grid, grid_ext::Grid, stations::NamedTuple, nprt_per_rank::Int, T::Type)

    n1 = grid.nx * grid.ny # number of elements in original grid
    n1_bar = grid_ext.nx * grid_ext.ny # number of elements in extended grid

    C = complex(T)

    matrices = OnlineMatrices(Vector{C}(undef, n1_bar),
                              Vector{C}(undef, stations.nst),
                              Matrix{C}(undef, grid.nx, grid.ny),
                              Matrix{C}(undef, grid.nx, grid.ny),
                              Array{T}(undef, grid.nx, grid.ny, nprt_per_rank),
                              Array{T}(undef, grid.nx, grid.ny, nprt_per_rank)
                              )

    return matrices


end

# Calculate the mean for the optimal proposal of the height
function calculate_mean_height!(mean::AbstractArray{T,3},
                                height::AbstractArray{T,3},
                                offline_matrices::OfflineMatrices,
                                observations::AbstractVector{T},
                                stations::NamedTuple,
                                grid::Grid,
                                grid_ext::Grid,
                                fft_plan::FFTW.FFTWPlan,
                                fft_plan!::FFTW.FFTWPlan,
                                nprt_per_rank::Int,
                                obs_noise_std::T,
                                ) where T

    # The arguments for the WΛWH decompositions are matrices that only have nonzero values
    # at the indices of the stations. Store them as sparse arrays to save space.
    mu21 = sparse(stations.ist, stations.jst,
                  offline_matrices.R22_inv * (offline_matrices.mu20 * observations),
                  grid.nx, grid.ny)
    mu22 = obs_noise_std^(-2) * sparse(stations.ist, stations.jst, observations, grid.nx, grid.ny)

    # Compute WΛWH decompositions, results are dense matrices, store them in buffers
    # These correspond to mu21 and mu22 in Alex's code
    WΛWH_decomposition!(offline_matrices.buf1, mu21, offline_matrices, grid, grid_ext, fft_plan, fft_plan!)
    WΛWH_decomposition!(offline_matrices.buf2, mu22, offline_matrices, grid, grid_ext, fft_plan, fft_plan!)

    # Compute the difference of the decomposition results, store in offline_matrices.buf1
    # This corresponds to mu2 in Alex's code.
    # TODO: Check if WΛWH is linear and you could swap the order
    offline_matrices.buf2 .-= offline_matrices.buf1

    mu10 = Vector{T}(undef, stations.nst)

    # Loop over particles
    for iprt = 1:nprt_per_rank

        mul!(mu10, offline_matrices.R22_inv, get_values_at_stations(@view(height[:,:,iprt]), stations))
        mu10_sparse = sparse(stations.ist, stations.jst, mu10, grid.nx, grid.ny)

        # Compute decomposition of height values at stations times the inverse covariance matrix
        # The argument corresponds to mu10 and the outcome to mu11 in Alex's code
        WΛWH_decomposition!(offline_matrices.buf1, mu10_sparse, offline_matrices, grid, grid_ext, fft_plan, fft_plan!)

        # Compute the mean for the ith particle using mu2 and mu11
        # Skip storing the temporary mu1 in Alex's code
        mean[:,:,iprt] .= @view(height[:,:,iprt]) .- offline_matrices.buf1 .+ offline_matrices.buf2

    end

end

function sample_height_proposal!(height::AbstractArray{T,3},
                                 offline_matrices::OfflineMatrices,
                                 online_matrices::OnlineMatrices,
                                 observations::AbstractVector{T},
                                 stations::NamedTuple,
                                 grid::Grid,
                                 grid_ext::Grid,
                                 fft_plan::FFTW.FFTWPlan,
                                 fft_plan!::FFTW.FFTWPlan,
                                 nprt_per_rank::Int,
                                 rng::Random.AbstractRNG,
                                 obs_noise_std::T,
                                 ) where T

    @assert iseven(nprt_per_rank) "Number of particles per rank must be even to use the Optimal Filter"

    calculate_mean_height!(online_matrices.mean, height, offline_matrices, observations, stations, grid, grid_ext, fft_plan, fft_plan!, nprt_per_rank, obs_noise_std)

    i_n1 = LinearIndices((grid.nx, grid.ny))
    i_n1_bar = LinearIndices((grid_ext.nx, grid_ext.ny))

    e1 = Vector{ComplexF64}(undef, grid_ext.nx * grid_ext.ny)
    e2 = Vector{ComplexF64}(undef, stations.nst)

    for iprt in 1:2:nprt_per_rank

        @. e1 = complex(randn(rng), randn(rng))
        @. e2 = complex(randn(rng), randn(rng))

        # This gives the vector z1_bar
        normalized_2d_fft!(online_matrices.z1_bar, Diagonal(offline_matrices.Lambda)^(1/2) * e1, fft_plan, fft_plan!, grid_ext, inv)

        # This is the vector z2
        mul!(online_matrices.z2, offline_matrices.K, e1)
        mul!(online_matrices.z2, offline_matrices.L, e2, 1, 1)

        # Restrict z1_bar to Omega1 and reshape into an array
        online_matrices.Z1 .= online_matrices.z1_bar[i_n1_bar[1:grid.nx,1:grid.nx]]
        # Multiply z2 with R12*R22^-1 and reshape the result into an array
        online_matrices.Z2 .= (offline_matrices.R12_invR22 * online_matrices.z2)[i_n1]

        online_matrices.samples[:,:,iprt    ] .= @view(online_matrices.mean[:,:,iprt    ]) .+ real.(online_matrices.Z1 .- online_matrices.Z2)
        online_matrices.samples[:,:,iprt + 1] .= @view(online_matrices.mean[:,:,iprt + 1]) .+ imag.(online_matrices.Z1 .- online_matrices.Z2)

    end

end

function get_log_weights!(log_weights::AbstractVector{T},
                          obs::AbstractVector{T},
                          obs_model::AbstractMatrix{T},
                          matrices::OfflineMatrices) where T

    #TODO: Is this just the same as get_log_weights! in ParticleDA with R22_inv as cov_obs?
    # DONE: No, ParticleDA.get_log_weights! fails with
    # ERROR: PosDefException: matrix is not Hermitian; Cholesky factorization failed.

    nprt = size(obs_model,2)

    for iprt in 1:nprt

        log_weights[iprt] = -0.5 * (obs - obs_model[:,iprt])' * matrices.R22_inv * (obs - obs_model[:,iprt])

    end

    #Normalization is done in a separate function due to parallelism optimisation

end
