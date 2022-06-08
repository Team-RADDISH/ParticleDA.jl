using LinearAlgebra
using GaussianRandomFields


struct OfflineMatrices{R<:Real, M<:AbstractMatrix{R}, F<:Factorization{R}}
    # Covariance between state X and observations Y given previous state x
    cov_X_Y::M  
    # Factorization of covariance between observations Y given previous state x
    fact_cov_Y_Y::F  
end

struct OnlineMatrices{T<:AbstractArray}
    # Buffer of size (observation dimension, number of particles per rank) for holding
    # intermediate values in computation of optimal proposal update
    observations_buffer::T
    # Buffer of size (state dimension, number of particles per rank) for holding
    # intermediate values in computation of optimal proposal update
    states_buffer::T
end

struct Grid{T}
    nx::Int
    ny::Int
    dx::T
    dy::T
    x_length::T
    y_length::T
end

# Covariance of additive state noise field between spatial points s₁ and s₂
function state_noise_covariance(
    s₁::T, 
    s₂::T, 
    covariance_structure::IsotropicCovarianceStructure{T}
) where T
    return covariance_structure.σ^2 * apply(covariance_structure, [s₁, s₂])
end

# Covariance Cov(X, Y) between states X = F(x) + U and observations Y = H(F(x) + U) + V 
# given previous state x  where U ~ Normal(0, Q) is the state noise, V ~ Normal(R) the 
# observation noise, F the forward operator of the (deterministic) state dynamics and H 
# a linear observation operator
function covariance_observations_state_given_previous_state(
    grid::Grid, 
    stations::NamedTuple, 
    covariance_structure::IsotropicCovarianceStructure{T}
) where T
    xid = 1:grid.nx
    yid = 1:grid.ny
    c = CartesianIndices((xid, yid))[:]
    cov = Matrix{T}(undef, length(c), stations.nst)
    for (i,ist,jst) in zip(1:stations.nst, stations.ist, stations.jst)
        cov[:, i] .= state_noise_covariance.(
            abs.(getindex.(c, 1) .- ist) .* grid.dx,
            abs.(getindex.(c, 2) .- jst) .* grid.dy,
            (covariance_structure,)
        )
    end
    return cov
end

# Cholesky factorization of covariance Cov(Y, Y) between observations Y = H(F(x)+U) + V 
# given previous state x where U ~ Normal(0, Q) is the state noise, V ~ Normal(R) the 
# observation noise, F the forward operator of the (deterministic) state dynamics and H 
# a linear observation operator
function factorized_covariance_observations_observations_given_previous_state(
    grid::Grid, 
    stations::NamedTuple, 
    covariance_structure::IsotropicCovarianceStructure{T}, 
    observation_noise_std::T,
) where T
    cov = state_noise_covariance.(
        abs.(stations.ist .- stations.ist') .* grid.dx,
        abs.(stations.jst' .- stations.jst) .* grid.dy,
        (covariance_structure,),
    )
    view(cov, diagind(cov)) .+= observation_noise_std.^2
    return cholesky!(cov)
end

# Allocate and compute matrices that do not depend on time-dependent variables
function init_offline_matrices(
    grid::Grid,
    stations::NamedTuple,
    covariance_structure::IsotropicCovarianceStructure{T},
    observation_noise_std::T,
) where T
    cov_X_Y = covariance_observations_state_given_previous_state(
        grid, stations, covariance_structure
    )
    fact_cov_Y_Y = factorized_covariance_observations_observations_given_previous_state(
        grid, stations, covariance_structure, observation_noise_std
    )
    matrices = OfflineMatrices(cov_X_Y, fact_cov_Y_Y)
    return matrices
end

# Allocate memory for matrices that will be updated during the time stepping loop.
function init_online_matrices(
    grid::Grid, stations::NamedTuple, n_assimilated_var::Int, nprt_per_rank::Int, T::Type
)
    n_grid = grid.nx * grid.ny  # number of elements in grid
    matrices = OnlineMatrices(
        Array{T}(undef, stations.nst, n_assimilated_var, nprt_per_rank),
        Array{T}(undef, n_grid, n_assimilated_var, nprt_per_rank)
    )
    return matrices
end

function update_particles_given_observations!(model_data, filter_data, observations, nprt_per_rank)

    observations_buffer = filter_data.online_matrices.observations_buffer
    states_buffer = filter_data.online_matrices.states_buffer
    # Compute Y ~ Normal(HX, R) for each particle X
    sample_observations_given_particles!(observations_buffer, model_data, nprt_per_rank)
    particles = get_particles(model_data)
    indices = get_observed_state_indices(model_data)
    n_assimilated_var = get_number_assimilated_var(model_data)
    # Update particles to account for observations, X = X - QHᵀ(HQHᵀ + R)⁻¹(Y − y)
    # The following lines are equivalent to the single statement version
    #     @view(particles[:, :, indices..., :]) .-= reshape(
    #         cov_X_Y * (fact_cov_Y_Y  \ (observations_buffer .- observations)), 
    #         size(particles[:, :, indices..., :])
    #     )
    # but we stage across multiple statements to allow using in-place operations to
    # avoid unnecessary allocations.
    observations_buffer .-= observations
    for var in 1:n_assimilated_var
        ldiv!(filter_data.offline_matrices[var].fact_cov_Y_Y, observations_buffer[:, var, :])
        mul!(states_buffer[:, var ,:], filter_data.offline_matrices[var].cov_X_Y, observations_buffer[:, var, :])
    end

    @view(particles[:, :, indices, :]) .-= reshape(
        states_buffer, size(particles[:, :, indices, :])
    )
    set_particles!(model_data, particles)
end
