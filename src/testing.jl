"""
    run_unit_tests_for_generic_model_interface(model, seed)

Run tests for model `model` correctly implementing generic model interface with random
seed `seed`.

Tests that all required methods are defined for model and that they have expected
behaviour.
"""
function run_unit_tests_for_generic_model_interface(model, seed; RNGType = Random.Xoshiro)
    
    state_dimension = ParticleDA.get_state_dimension(model)
    @test isa(state_dimension, Integer)
    @test state_dimension > 0
    
    observation_dimension = ParticleDA.get_observation_dimension(model)
    @test isa(observation_dimension, Integer)
    @test observation_dimension > 0
    
    state_eltype = ParticleDA.get_state_eltype(model)
    @test isa(state_eltype, DataType)
    
    observation_eltype = ParticleDA.get_observation_eltype(model)
    @test isa(observation_eltype, DataType)
    
    state = Vector{state_eltype}(undef, state_dimension)
    state .= NaN
    
    ParticleDA.sample_initial_state!(state, model, RNGType(seed))
    @test !any(isnan.(state))
    # sample_initial_state! should generate same state when passed random number
    # generator with same state / seed
    state_copy = copy(state)
    ParticleDA.sample_initial_state!(state, model, RNGType(seed))
    @test all(state .== state_copy)
    
    # update_state_deterministic! should give same updated state for same input state
    ParticleDA.update_state_deterministic!(state, model, 1)
    ParticleDA.update_state_deterministic!(state_copy, model, 1)
    @test !any(isnan.(state))
    @test all(state .== state_copy)
    
    # update_state_stochastic! should give same updated state for same input + rng state
    ParticleDA.update_state_stochastic!(state, model, RNGType(seed))
    ParticleDA.update_state_stochastic!(state_copy, model, RNGType(seed))
    @test !any(isnan.(state))
    @test all(state == state_copy)
    
    observation = Vector{observation_eltype}(undef, observation_dimension)
    observation .= NaN
    observation_copy = copy(observation)
    # sample_observation_given_state! should give same observation for same input + 
    # rng state
    ParticleDA.sample_observation_given_state!(
        observation, state, model, RNGType(seed)
    )
    ParticleDA.sample_observation_given_state!(
        observation_copy, state, model, RNGType(seed)
    )
    @test !any(isnan.(observation))
    @test all(observation .== observation_copy)
    
    log_density = ParticleDA.get_log_density_observation_given_state(
        observation, state, model
    )
    @test isa(log_density, Real)
    @test !isnan(log_density)
    # get_log_density_observation_given_state should give same output for same inputs
    @test log_density == ParticleDA.get_log_density_observation_given_state(
        observation, state, model
    )
    
    # Tests for model IO functions
    
    output_filename = tempname()
    h5open(output_filename, "cw") do file 
        # As write_model_metadata could be a no-op we just test it runs without error
        ParticleDA.write_model_metadata(file, model)
        ParticleDA.write_observation(file, observation, 0, model)
        @test haskey(file, "observations")
        state_group_name = "state"
        ParticleDA.write_state(file, state, 0, state_group_name, model)
        @test haskey(file, state_group_name)
        ParticleDA.write_weights(file, [1, 1, 1], 0, model)
        @test haskey(file, "weights")
    end
    
    n_particle = 2
    filter_data = (
        weights=ones(n_particle), 
        unpacked_statistics=Dict(
            "avg" => zeros(state_dimension), "var" => zeros(state_dimension)
        )
    )
    states = zeros(state_dimension, n_particle)
    for save_states in (true, false)
        output_filename = tempname()
        ParticleDA.write_snapshot(
            output_filename, model, filter_data, states, 0, save_states
        )
        h5open(output_filename, "r") do file
            for key in keys(filter_data.unpacked_statistics)
                @test haskey(file, "state_$key")
            end
            @test haskey(file, "weights")
            for i in 1:n_particle
                key = "state_particle_$i"
                @test save_states ? haskey(file, key) : !haskey(file, key)
            end
        end
    end
end

function check_mean_function(
    set_mean!,
    set_sample!,
    rng,
    bound_constant,
    estimate_n_samples,
    dimension,
    el_type
)
    mean = Vector{el_type}(undef, dimension)
    mean .= NaN
    mean_copy = copy(mean)
    set_mean!(mean)
    @test !any(isnan.(mean))
    set_mean!(mean_copy)
    @test all(mean .== mean_copy)
    sample = Vector{el_type}(undef, dimension)
    for n_sample in estimate_n_samples
        empirical_mean = zeros(el_type, dimension)
        for _ in 1:n_sample
            set_sample!(sample, rng)
            empirical_mean .+= sample ./ n_sample
        end
        # Monte Carlo estimate of mean should have O(sqrt(n_sample)) convergence to
        # true mean
        @test (
            norm(empirical_mean - mean, Inf) 
            < bound_constant / sqrt(n_sample)
        )
    end
end

function check_covariance_function(
    get_covariance_ij,
    set_mean!,
    set_sample!,
    rng,
    bound_constant,
    estimate_n_samples,
    dimension,
    el_type
)
    cov = Matrix{Float64}(undef, dimension, dimension)
    all_entries_valid = true
    for i in 1:dimension
        for j in 1:i
            cov_ij = get_covariance_ij(i, j)
            all_entries_valid &= isa(cov_ij, Real)
            all_entries_valid &= !isnan(cov_ij)
            if i == j
                all_entries_valid &= cov_ij > 0
            else
                all_entries_valid &= (cov_ij == get_covariance_ij(j, i))
            end
            cov[i, j] = cov_ij
        end
    end
    @test all_entries_valid
    
    cov = Symmetric(cov, :L)
    @test isposdef(cov)
    
    function get_variances_and_correlations(covariance_matrix)
        variances = diag(covariance_matrix)
        inv_scale_matrix = Diagonal(1 ./ sqrt.(variances))
        correlation_matrix = inv_scale_matrix * covariance_matrix * inv_scale_matrix
        return variances, correlation_matrix
    end
    
    # Get vector of variances and correlation matrix 
    var, corr = get_variances_and_correlations(cov)

    mean = Vector{el_type}(undef, dimension)
    set_mean!(mean)
    
    sample = Vector{el_type}(undef, dimension)
    
    for n_sample in estimate_n_samples
        empirical_cov = zeros(dimension, dimension)
        for _ in 1:n_sample
            set_sample!(sample, rng)
            sample .-= mean
            empirical_cov .+= (sample * sample') ./ (n_sample - 1)
        end
        # Monte Carlo estimates of variances and correlations should have roughly
        # O(sqrt(n_sample)) convergence to true values
        empirical_var, empirical_corr = get_variances_and_correlations(empirical_cov)
        @test (
            norm(empirical_var - var, Inf) < bound_constant / sqrt(n_sample)
        )
        @test (
            norm(empirical_corr - corr, Inf) < bound_constant / sqrt(n_sample)
        )
    end
    
end

function check_cross_covariance_function(
    get_cross_covariance_ij,
    set_means!,
    set_samples!,
    rng,
    bound_constant,
    estimate_n_samples,
    dimensions,
    el_types
)
    cross_cov = Matrix{Float64}(undef, dimensions...)
    all_entries_valid = true
    for i in 1:dimensions[1]
        for j in 1:dimensions[2]
            cross_cov_ij = get_cross_covariance_ij(i, j)
            all_entries_valid &= isa(cross_cov_ij, Real)
            all_entries_valid &= !isnan(cross_cov_ij)
            cross_cov[i, j] = cross_cov_ij
        end
    end
    @test all_entries_valid

    means = Tuple(
        Vector{el_type}(undef, dimension) 
        for (el_type, dimension) in zip(el_types, dimensions)
    )
    set_means!(means...)
    
    samples = Tuple(
        Vector{el_type}(undef, dimension) 
        for (el_type, dimension) in zip(el_types, dimensions)
    )
    
    for n_sample in estimate_n_samples
        empirical_cross_cov = zeros(dimensions...)
        for _ in 1:n_sample
            set_samples!(samples..., rng)
            samples[1] .-= means[1]
            samples[2] .-= means[2]            
            empirical_cross_cov .+= (samples[1] * samples[2]') ./ (n_sample - 1)
        end
        # Monte Carlo estimates of cross_covariances should have roughly
        # O(sqrt(n_sample)) convergence to true values
        @test (
            norm(empirical_cross_cov - cross_cov, Inf) 
            < bound_constant / sqrt(n_sample)
        )
    end
    
end


"""
    run_tests_for_optimal_proposal_model_interface(
        model, seed, estimate_bound_constant, estimate_n_samples
    )

Run tests for model `model` correctly implementing locally optimal proposal model
interface with random seed `seed`, constant factor for checks of functions exhibiting
expected Monte Carlo error scaling `estimate_bound_constant` and number of samples to
use in checks of Monte Carlo error scaling `estimate_n_samples`.

Tests that all additional methods required to use locally optimal proposal filter are
defined for model and that they have expected behaviour.
"""
function run_tests_for_optimal_proposal_model_interface(
    model, seed, estimate_bound_constant, estimate_n_samples; RNGType = Random.Xoshiro
)
    state_dimension = ParticleDA.get_state_dimension(model)
    observation_dimension = ParticleDA.get_observation_dimension(model)
    state_eltype = ParticleDA.get_state_eltype(model)
    observation_eltype = ParticleDA.get_observation_eltype(model)

    state = Vector{state_eltype}(undef, state_dimension)
    ParticleDA.sample_initial_state!(state, model, RNGType(seed))

    check_mean_function(
        m -> ParticleDA.get_observation_mean_given_state!(m, state, model),
        (s, r) -> ParticleDA.sample_observation_given_state!(s, state, model, r),
        RNGType(seed),
        estimate_bound_constant,
        estimate_n_samples,
        observation_dimension,
        observation_eltype
    )

    function state_transition_mean!(mean)
        mean[:] = state
        ParticleDA.update_state_deterministic!(mean, model, 0)
    end

    function sample_state_transition(next_state, rng)
        next_state[:] = state
        ParticleDA.update_state_deterministic!(next_state, model, 0)
        ParticleDA.update_state_stochastic!(next_state, model, rng)
    end   

    check_mean_function(
        state_transition_mean!,
        sample_state_transition,
        RNGType(seed),
        estimate_bound_constant,
        estimate_n_samples,
        state_dimension,
        state_eltype
    )

    check_covariance_function(
        (i, j) -> ParticleDA.get_covariance_observation_noise(model, i, j),
        m -> ParticleDA.get_observation_mean_given_state!(m, state, model),
        (s, r) -> ParticleDA.sample_observation_given_state!(s, state, model, r),
        RNGType(seed),
        estimate_bound_constant,
        estimate_n_samples,
        observation_dimension,
        observation_eltype 
    )

    check_covariance_function(
        (i, j) -> ParticleDA.get_covariance_state_noise(model, i, j),
        state_transition_mean!,
        sample_state_transition,
        RNGType(seed),
        estimate_bound_constant * 10,
        estimate_n_samples,
        state_dimension,
        state_eltype 
    )
    
    state_buffer = Vector{state_eltype}(undef, state_dimension)
    
    function sample_observation_given_previous_state!(observation, rng)
        state_buffer[:] = state
        ParticleDA.update_state_deterministic!(state_buffer, model, 0)
        ParticleDA.update_state_stochastic!(state_buffer, model, rng)
        ParticleDA.sample_observation_given_state!(
            observation, state_buffer, model, rng
        )
    end
    
    function observation_given_previous_state_mean!(mean)
        state_buffer[:] = state
        ParticleDA.update_state_deterministic!(state_buffer, model, 0)
        ParticleDA.get_observation_mean_given_state!(mean, state_buffer, model)
    end
    
    check_covariance_function(
        (i, j) -> ParticleDA.get_covariance_observation_observation_given_previous_state(
            model, i, j
        ),
        observation_given_previous_state_mean!,
        sample_observation_given_previous_state!,
        RNGType(seed),
        estimate_bound_constant,
        estimate_n_samples,
        observation_dimension,
        observation_eltype 
    )
    
    function sample_state_observation_given_previous_state!(state_, observation, rng)
        state_[:] = state
        ParticleDA.update_state_deterministic!(state_, model, 0)
        ParticleDA.update_state_stochastic!(state_, model, rng)
        ParticleDA.sample_observation_given_state!(
            observation, state_, model, rng
        )
    end
    
    function state_observation_given_previous_state_mean!(state_mean, observation_mean)
        state_mean[:] = state
        ParticleDA.update_state_deterministic!(state_mean, model, 0)
        ParticleDA.get_observation_mean_given_state!(
            observation_mean, state_mean, model
        )
    end
    
    check_cross_covariance_function(
        (i, j) -> ParticleDA.get_covariance_state_observation_given_previous_state(
            model, i, j
        ),
        state_observation_given_previous_state_mean!,
        sample_state_observation_given_previous_state!,
        RNGType(seed),
        estimate_bound_constant,
        estimate_n_samples,
        (state_dimension, observation_dimension),
        (state_eltype, observation_eltype)         
    )

end

"""
    run_tests_for_convergence_of_filter_estimates_against_kalman_filter(
        filter_type,
        init_model,
        model_parameters_dict,
        seed,
        n_time_step,
        n_particles,
        mean_rmse_bound_constant,
        log_var_rmse_bound_constant,
    )

Run tests to check convergence of estimates produced using filter with type
`filter_type` for (linear-Gaussian) model initialised by `init_model` and with
parameters `model_parameter_dict` against ground-truth values computed using a Kalman
filter, running filtering for `n_time_step` and with a sequence of `n_particles`
ensemble sizes and with random number generator seeded with `seed`. Estimates of
filtering distribution means and (log) variances are checked to show the expected Monte
Carlo error (`1 / sqrt(n_particle)`) scaling with constant factors
`mean_rmse_bound_constant` and `log_var_rmse_bound_constant` used in checks - that is
`error < bound_constant / sqrt(n_particle)`.
"""
function run_tests_for_convergence_of_filter_estimates_against_kalman_filter(
    filter_type,
    init_model,
    model_parameters_dict,
    seed,
    n_time_step,
    n_particles,
    mean_rmse_bound_constant,
    log_var_rmse_bound_constant,
)
    rng = Random.TaskLocalRNG()
    Random.seed!(rng, seed)
    model = init_model(model_parameters_dict)
    observation_seq = simulate_observations_from_model(
        model, n_time_step; rng=rng
    )
    true_state_mean_seq, true_state_var_seq = Kalman.run_kalman_filter(
        model, observation_seq
    )
    for n_particle in n_particles
        output_filename = tempname()
        filter_parameters = FilterParameters(
            nprt=n_particle, verbose=true, output_filename=output_filename
        )
        states, statistics = run_particle_filter(
            init_model,
            filter_parameters, 
            model_parameters_dict, 
            observation_seq, 
            filter_type, 
            MeanAndVarSummaryStat; 
            rng=rng
        )
        state_mean_seq = Matrix{get_state_eltype(model)}(
            undef, get_state_dimension(model), n_time_step
        )
        state_var_seq = Matrix{get_state_eltype(model)}(
            undef, get_state_dimension(model), n_time_step
        )
        weights_seq = Matrix{Float64}(undef, n_particle, n_time_step)
        h5open(output_filename, "r") do file
            for t in 1:n_time_step
                key = time_index_to_hdf5_key(t)
                state_mean_seq[:, t] = read(file["state_avg"][key])
                state_var_seq[:, t] = read(file["state_var"][key])
                weights_seq[:, t] = read(file["weights"][key])
            end
        end
        mean_rmse = sqrt(
            mean(x -> x.^2, state_mean_seq .- true_state_mean_seq)
        )
        log_var_rmse = sqrt(
            mean(x -> x.^2, log.(state_var_seq) .- log.(true_state_var_seq))
        )
        # Monte Carlo estimates of mean and log variance should have O(sqrt(n_particle))
        # convergence to true values
        @test mean_rmse < mean_rmse_bound_constant / sqrt(n_particle)
        @test log_var_rmse < log_var_rmse_bound_constant / sqrt(n_particle)
    end
end
