using ParticleDA
using LinearAlgebra, Test, HDF5, Random, YAML
using MPI
using StableRNGs
using GaussianRandomFields: Matern
using Statistics
using PDMats

using ParticleDA: FilterParameters

include(joinpath(@__DIR__, "model", "model.jl"))

using .Model, .Model.LLW2d
using .Model: ModelParameters

@testset "LLW2d" begin
    dx = dy = 2e3

    ### get_station_grid_indices
    station_grid_indices = Model.get_station_grid_indices(
        2, 2, 20e3, 20e3, 150e3, 150e3, dx, dy
    )
    @test station_grid_indices[:, 1] == [76, 76, 86, 86]
    @test station_grid_indices[:, 2] == [76, 86, 76, 86]

    station_grid_indices = Model.get_station_grid_indices(
        3, 3, 20e3, 20e3, 150e3, 150e3, dx, dy
    )
    @test station_grid_indices[:, 1] == [76, 76, 76, 86, 86, 86, 96, 96, 96]
    @test station_grid_indices[:, 2] == [76, 86, 96, 76, 86, 96, 76, 86, 96]

    ### initheight!
    nx = 2
    ny = 2
    eta = ones(nx, ny)
    ocean_depth  = ones(nx, ny)
    peak_position = [floor(Int, nx/4) * dx, floor(Int, ny/4) * dy]
    LLW2d.initheight!(eta, ocean_depth, dx, dy, 3e4, 1.0, peak_position)
    @test eta ≈ [0.978266982572228  0.9463188389826958;
                 0.9463188389826958 0.9154140546161575]
    eta = ones(2, 2)
    ocean_depth  = zeros(2, 2)
    LLW2d.initheight!(eta, ocean_depth, dx, dy, 3e4, 1.0, peak_position)
    @test eta ≈ zeros(2, 2)

    # timestep.  TODO: add real tests.  So far we're just making sure code won't
    # crash
    n = 200
    eta1 = rand(n, n)
    mm1 = rand(n, n)
    nn1 = rand(n, n)
    eta0 = rand(n, n)
    mm0 = rand(n, n)
    nn0 = rand(n, n)
    y_averaged_depth = rand(n, n)
    x_averaged_depth = rand(n, n)
    land_filter_m = rand(n, n)
    land_filter_n = rand(n, n)
    land_filter_e = rand(n,n)
    absorbing_boundary = rand(n,n)
    model_matrices = LLW2d.Matrices(absorbing_boundary, ocean_depth,
                                    x_averaged_depth, y_averaged_depth,
                                    land_filter_m, land_filter_n, land_filter_e)
    dxeta = Matrix{Float64}(undef, n, n)
    dyeta = Matrix{Float64}(undef, n, n)
    LLW2d.timestep!(dxeta, dyeta, eta1, mm1, nn1, eta0, mm0, nn0, model_matrices, dx, dy, 1)

    # setup.  TODO: add real tests.  So far we're just making sure code won't
    # crash
    LLW2d.setup(n, n, 3e4, 0.1, 0.015, 10.0)
end

function run_unit_tests_for_generic_model_interface(model_data, seed)
    
    state_dimension = ParticleDA.get_state_dimension(model_data)
    @test isa(state_dimension, Integer)
    @test state_dimension > 0
    
    observation_dimension = ParticleDA.get_observation_dimension(model_data)
    @test isa(observation_dimension, Integer)
    @test observation_dimension > 0
    
    state_eltype = ParticleDA.get_state_eltype(model_data)
    @test isa(state_eltype, DataType)
    
    observation_eltype = ParticleDA.get_observation_eltype(model_data)
    @test isa(observation_eltype, DataType)
    
    state = Vector{state_eltype}(undef, state_dimension)
    state .= NaN
    
    ParticleDA.sample_initial_state!(state, model_data, StableRNG(seed))
    @test !any(isnan.(state))
    # sample_initial_state! should generate same state when passed random number
    # generator with same state / seed
    state_copy = copy(state)
    ParticleDA.sample_initial_state!(state, model_data, StableRNG(seed))
    @test all(state .== state_copy)
    
    # update_state_deterministic! should give same updated state for same input state
    ParticleDA.update_state_deterministic!(state, model_data, 1)
    ParticleDA.update_state_deterministic!(state_copy, model_data, 1)
    @test !any(isnan.(state))
    @test all(state .== state_copy)
    
    # update_state_stochastic! should give same updated state for same input + rng state
    ParticleDA.update_state_stochastic!(state, model_data, StableRNG(seed))
    ParticleDA.update_state_stochastic!(state_copy, model_data, StableRNG(seed))
    @test !any(isnan.(state))
    @test all(state == state_copy)
    
    observation = Vector{observation_eltype}(undef, observation_dimension)
    observation .= NaN
    observation_copy = copy(observation)
    # sample_observation_given_state! should give same observation for same input + 
    # rng state
    ParticleDA.sample_observation_given_state!(
        observation, state, model_data, StableRNG(seed)
    )
    ParticleDA.sample_observation_given_state!(
        observation_copy, state, model_data, StableRNG(seed)
    )
    @test !any(isnan.(observation))
    @test all(observation .== observation_copy)
    
    log_density = ParticleDA.get_log_density_observation_given_state(
        observation, state, model_data
    )
    @test isa(log_density, Real)
    @test !isnan(log_density)
    # get_log_density_observation_given_state should give same output for same inputs
    @test log_density == ParticleDA.get_log_density_observation_given_state(
        observation, state, model_data
    )
    
    # Tests for model IO functions
    
    output_filename = tempname()
    h5open(output_filename, "cw") do file 
        # As write_model_metadata could be a no-op we just test it runs without error
        ParticleDA.write_model_metadata(file, model_data)
        ParticleDA.write_observation(file, observation, 0, model_data)
        @test haskey(file, "observations")
        state_group_name = "state"
        ParticleDA.write_state(file, state, 0, state_group_name, model_data)
        @test haskey(file, state_group_name)
        ParticleDA.write_weights(file, [1, 1, 1], 0, model_data)
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
            output_filename, model_data, filter_data, states, 0, save_states
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


function run_tests_for_optimal_proposal_model_interface(
    model_data, seed, estimate_bound_constant, estimate_n_samples
)
    state_dimension = ParticleDA.get_state_dimension(model_data)
    observation_dimension = ParticleDA.get_observation_dimension(model_data)
    state_eltype = ParticleDA.get_state_eltype(model_data)
    observation_eltype = ParticleDA.get_observation_eltype(model_data)

    state = Vector{state_eltype}(undef, state_dimension)
    ParticleDA.sample_initial_state!(state, model_data, StableRNG(seed))

    check_mean_function(
        m -> ParticleDA.get_observation_mean_given_state!(m, state, model_data),
        (s, r) -> ParticleDA.sample_observation_given_state!(s, state, model_data, r),
        StableRNG(seed),
        estimate_bound_constant,
        estimate_n_samples,
        observation_dimension,
        observation_eltype
    )

    function state_transition_mean!(mean)
        mean[:] = state
        ParticleDA.update_state_deterministic!(mean, model_data, 0)
    end

    function sample_state_transition(next_state, rng)
        next_state[:] = state
        ParticleDA.update_state_deterministic!(next_state, model_data, 0)
        ParticleDA.update_state_stochastic!(next_state, model_data, rng)
    end   

    check_mean_function(
        state_transition_mean!,
        sample_state_transition,
        StableRNG(seed),
        estimate_bound_constant,
        estimate_n_samples,
        state_dimension,
        state_eltype
    )

    check_covariance_function(
        (i, j) -> ParticleDA.get_covariance_observation_noise(model_data, i, j),
        m -> ParticleDA.get_observation_mean_given_state!(m, state, model_data),
        (s, r) -> ParticleDA.sample_observation_given_state!(s, state, model_data, r),
        StableRNG(seed),
        estimate_bound_constant,
        estimate_n_samples,
        observation_dimension,
        observation_eltype 
    )

    check_covariance_function(
        (i, j) -> ParticleDA.get_covariance_state_noise(model_data, i, j),
        state_transition_mean!,
        sample_state_transition,
        StableRNG(seed),
        estimate_bound_constant * 10,
        estimate_n_samples,
        state_dimension,
        state_eltype 
    )
    
    state_buffer = Vector{state_eltype}(undef, state_dimension)
    
    function sample_observation_given_previous_state!(observation, rng)
        state_buffer[:] = state
        ParticleDA.update_state_deterministic!(state_buffer, model_data, 0)
        ParticleDA.update_state_stochastic!(state_buffer, model_data, rng)
        ParticleDA.sample_observation_given_state!(
            observation, state_buffer, model_data, rng
        )
    end
    
    function observation_given_previous_state_mean!(mean)
        state_buffer[:] = state
        ParticleDA.update_state_deterministic!(state_buffer, model_data, 0)
        ParticleDA.get_observation_mean_given_state!(mean, state_buffer, model_data)
    end
    
    check_covariance_function(
        (i, j) -> ParticleDA.get_covariance_observation_observation_given_previous_state(
            model_data, i, j
        ),
        observation_given_previous_state_mean!,
        sample_observation_given_previous_state!,
        StableRNG(seed),
        estimate_bound_constant,
        estimate_n_samples,
        observation_dimension,
        observation_eltype 
    )
    
    function sample_state_observation_given_previous_state!(state_, observation, rng)
        state_[:] = state
        ParticleDA.update_state_deterministic!(state_, model_data, 0)
        ParticleDA.update_state_stochastic!(state_, model_data, rng)
        ParticleDA.sample_observation_given_state!(
            observation, state_, model_data, rng
        )
    end
    
    function state_observation_given_previous_state_mean!(state_mean, observation_mean)
        state_mean[:] = state
        ParticleDA.update_state_deterministic!(state_mean, model_data, 0)
        ParticleDA.get_observation_mean_given_state!(
            observation_mean, state_mean, model_data
        )
    end
    
    check_cross_covariance_function(
        (i, j) -> ParticleDA.get_covariance_state_observation_given_previous_state(
            model_data, i, j
        ),
        state_observation_given_previous_state_mean!,
        sample_state_observation_given_previous_state!,
        StableRNG(seed),
        estimate_bound_constant,
        estimate_n_samples,
        (state_dimension, observation_dimension),
        (state_eltype, observation_eltype)         
    )

end

function check_hdf5_group_valid(parent, group, group_name)
    @test haskey(parent, group_name)
    @test isa(group, HDF5.Group)
    @test occursin(group_name, HDF5.name(group))
end

@testset "ParticleDA generic IO unit tests" begin
    output_filename = tempname()
    group_name = "test_group"
    subgroup_name = "test_subgroup"
    dataset_name = "test_dataset"
    test_array = [1, 2, 3]
    test_attributes = Dict("string_attribute" => "value", "int_attribute" => 1)
    # test create group in empty file and write array
    h5open(output_filename, "cw") do file
        group, subgroup = ParticleDA.create_or_open_group(file, group_name)
        check_hdf5_group_valid(file, group, group_name)
        @test isnothing(subgroup)
        ParticleDA.write_array(group, dataset_name, test_array, test_attributes)
    end
    h5open(output_filename, "cw") do file
        @test haskey(file, group_name)
        # test opening existing group in file and array written previously matches
        group, _ = ParticleDA.create_or_open_group(file, group_name)
        check_hdf5_group_valid(file, group, group_name)
        @test read(group, dataset_name) == test_array
        @test all([
            read_attribute(group[dataset_name], k) == test_attributes[k] 
            for k in keys(test_attributes)
        ])
        # test writing to existing dataset name results in warning and does not update
        @test_logs (:warn, r"already exists") ParticleDA.write_array(
            group, dataset_name, []
        )
        @test read(group, dataset_name) == test_array
        # test opening subgroup
        _, subgroup = ParticleDA.create_or_open_group(file, group_name, subgroup_name)
        check_hdf5_group_valid(group, subgroup, subgroup_name)
    end
    # test writing timer data
    timer_strings = ["ab", "cde", "fg", "hij"]
    ParticleDA.write_timers(
        map(length, timer_strings), 
        length(timer_strings), 
        codeunits(join(timer_strings)), 
        output_filename
    )
    h5open(output_filename, "cw") do file
        @test haskey(file, "timer")
        for (i, timer_string) in enumerate(timer_strings)
            timer_dataset_name = "rank$(i-1)"
            @test haskey(file["timer"], timer_dataset_name)
            @test read(file["timer"], timer_dataset_name) == timer_string
        end
    end
end

@testset "ParticleDA model interface unit tests" begin
    seed = 1234
    model_data = Model.init(Dict())
    run_unit_tests_for_generic_model_interface(model_data, seed)
    # Number of samples to use in convergence tests of Monte Carlo estimates
    estimate_n_samples = [10, 100, 1000]
    # Constant factor used in Monte Carlo estimate convergence tests. Set based on some
    # trial and error to keep tests relatively sensitive while avoiding too high
    # probability of false failures but may require tweaking for each model
    estimate_bound_constant = 12.5
    run_tests_for_optimal_proposal_model_interface(
        model_data, seed, estimate_bound_constant, estimate_n_samples
    )
end

@testset "ParticleDA summary statistics unit tests" begin
    MPI.Init()
    seed = 5678
    dimension = 100
    state_eltype = Float64
    n_particle = 5
    master_rank = 0
    rng = StableRNG(seed)
    states = randn(rng, (dimension, n_particle))
    reference_statistics = (
        avg=mean(states; dims=2), var=var(states, corrected=true; dims=2)
    )
    for statistics_type in (
        ParticleDA.NaiveMeanSummaryStat, 
        ParticleDA.NaiveMeanAndVarSummaryStat,
        ParticleDA.MeanSummaryStat,
        ParticleDA.MeanAndVarSummaryStat
    )
        names = ParticleDA.statistic_names(statistics_type)
        @test isa(names, Tuple)
        @test eltype(names) == Symbol
        statistics = ParticleDA.init_statistics(
            statistics_type, state_eltype, dimension
        )
        ParticleDA.update_statistics!(statistics, states, master_rank)
        unpacked_statistics = ParticleDA.init_unpacked_statistics(
            statistics_type, state_eltype, dimension
        )
        @test keys(unpacked_statistics) == names
        ParticleDA.unpack_statistics!(unpacked_statistics, statistics)
        for name in names
            @test all(unpacked_statistics[name] .≈ reference_statistics[name])
        end
    end
end

@testset "ParticleDA filter unit tests" begin
    seed = 1357
    rng = StableRNG(seed)
    summary_stat_type = ParticleDA.MeanAndVarSummaryStat
    model_data = Model.init(Dict())
    filter_params = ParticleDA.get_params()
    nprt_per_rank = filter_params.nprt
    states = ParticleDA.init_states(model_data, nprt_per_rank, rng)
    @test size(states) == (ParticleDA.get_state_dimension(model_data), nprt_per_rank)
    @test eltype(states) == ParticleDA.get_state_eltype(model_data)
    # Sample an observation from model to use for testing filter update
    time_index = 0
    particle_index = 1
    state = copy(states[:, 1])
    ParticleDA.update_state_deterministic!(state, model_data, time_index)
    ParticleDA.update_state_stochastic!(state, model_data, rng)
    observation = Vector{ParticleDA.get_observation_eltype(model_data)}(
        undef, ParticleDA.get_observation_dimension(model_data)
    )
    ParticleDA.sample_observation_given_state!(observation, state, model_data, rng)
    log_weights = Vector{Float64}(undef, nprt_per_rank)
    log_weights .= NaN
    for filter_type in (BootstrapFilter, OptimalFilter)
        filter_data = ParticleDA.init_filter(
            filter_params, model_data, nprt_per_rank, filter_type, summary_stat_type
        )
        @test isa(filter_data, NamedTuple)
        new_states = copy(states)
        rng_2 = copy(rng)
        ParticleDA.sample_proposal_and_compute_log_weights!(
            new_states, 
            log_weights, 
            observation, 
            time_index, 
            model_data, 
            filter_data, 
            filter_type,
            rng
        )
        @test all(new_states != states)
        @test !any(isnan.(log_weights))
        # Test that log weight for particle used to simulate observation is greater
        # than for other particles: this is not guaranteed to be the case, but should be
        # with high probability if the initial particles are widely dispersed
        @test all(log_weights[1] .> log_weights[2:end])
        new_states_2 = copy(states)
        log_weights_2 = Vector{Float64}(undef, nprt_per_rank)
        # Check filter update gives deterministic updates when rng state is fixed
        ParticleDA.sample_proposal_and_compute_log_weights!(
            new_states_2, 
            log_weights_2, 
            observation, 
            time_index, 
            model_data, 
            filter_data, 
            filter_type,
            rng_2
        )
        @test all(log_weights .== log_weights_2)
        @test all(new_states .== new_states_2)
    end
end

@testset "ParticleDA resampling tests" begin
    rng = StableRNG(2468)
    for n_particle in (4, 8, 20, 50)
        log_weights = randn(rng, n_particle)
        weights = copy(log_weights)
        ParticleDA.normalized_exp!(weights)
        @test all(weights .>= 0)
        @test all(weights .<= 1)
        @test sum(weights) ≈ 1
        @test all(weights .≈ (exp.(log_weights) ./ sum(exp.(log_weights))))
        for n_sample in (100, 10000)
            counts = zeros(Int64, n_particle)
            for _ in 1:n_sample
                resampled_indices = Vector{Int64}(undef, n_particle)
                ParticleDA.resample!(resampled_indices, weights, rng)
                for i in resampled_indices
                    counts[i] = counts[i] + 1
                end
            end
            proportions = counts ./ (n_sample * n_particle)
            @test norm(proportions - weights, Inf) < 0.2 / sqrt(n_sample)
        end
    end
    # weight of 1.0 on first particle returns only copies of that particle
    weights = [1., 0., 0., 0., 0.]
    resampled_indices = Vector{Int64}(undef, length(weights))
    ParticleDA.resample!(resampled_indices, weights)
    @test all(resampled_indices .== 1)
    # weight of 1.0 on last particle returns only copies of that particle
    weights = [0., 0., 0., 0., 1.]
    resampled_indices = Vector{Int64}(undef, length(weights))
    ParticleDA.resample!(resampled_indices, weights)
    @test all(resampled_indices .== 5)
end


@testset "Integration test -- $(input_file) with $(filter_type) and $(stat_type)" for 
        filter_type in (ParticleDA.BootstrapFilter, ParticleDA.OptimalFilter),
        stat_type in (ParticleDA.MeanSummaryStat, ParticleDA.MeanAndVarSummaryStat),
        input_file in ["integration_test_$i.yaml" for i in 1:6]
    observation_file_path = tempname()
    ParticleDA.simulate_observations_from_model(
        Model.init, 
        joinpath(@__DIR__, input_file),  
        observation_file_path
    )
    observation_sequence = h5open(
        ParticleDA.read_observation_sequence, observation_file_path, "r"
    )
    @test !any(isnan.(observation_sequence))
    states, statistics = ParticleDA.run_particle_filter(
        Model.init, 
        joinpath(@__DIR__, input_file), 
        observation_file_path, 
        filter_type,
        stat_type,
    )
    @test !any(isnan.(states))
    reference_statistics = (
        avg=mean(states; dims=2), var=var(states, corrected=true; dims=2)
    )
    for name in ParticleDA.statistic_names(stat_type)
        @test size(statistics[name]) == size(states[:, 1])
        @test !any(isnan.(statistics[name]))
        @test all(statistics[name] .≈ reference_statistics[name])
    end

end

@testset "MPI -- $(file)" for file in ("mpi.jl", "copy_states.jl", "mean_and_var.jl")
    julia = joinpath(Sys.BINDIR, Base.julia_exename())
    flags = ["--startup-file=no", "-q", "-t$(Base.Threads.nthreads())"]
    script = joinpath(@__DIR__, file)
    mpiexec() do mpiexec
        @test success(run(ignorestatus(`$(mpiexec) -n 3 $(julia) $(flags) $(script)`)))
    end
end

@testset "Optimal Filter unit tests" begin
    
    MPI.Init()

    seed = 2897353985732341261
    rng = Random.seed!(seed)
    input_file = joinpath(
        dirname(pathof(ParticleDA)), "..", "test", "optimal_filter_test_1.yaml"
    )
    model_params_dict = get(ParticleDA.read_input_file(input_file), "model", Dict())
    nprt_per_rank = 1
    my_rank = 0
    model_data = Model.init(model_params_dict, nprt_per_rank, my_rank, rng)
    
    cov_X_Y = ParticleDA.get_covariance_observation_state_given_previous_state(model_data)
    @test all(isfinite, cov_X_Y)
    cov_Y_Y = ParticleDA.get_covariance_observation_observation_given_previous_state(
        model_data
    )
    # cov(Y, Y) and so its inverse should be positive definite, therefore inner-products
    # v' * inv(cov(Y, Y)) * v should always be positive
    vectors = randn(rng, Float64, (ParticleDA.get_observation_dimension(model_data), 10))
    inner_products = sum(vectors .* (cov_Y_Y \ vectors); dims=1)
    @test all(isfinite, inner_products)
    @test all(inner_products .> 0)
    
    # offline_matrices struct fields should all be matrix-like objects (either subtypes
    # of AbstractMatrix or Factorization) and should all be initialised to finite values
    # by init_offline_matrices
    offline_matrices = ParticleDA.init_offline_matrices(model_data)
    for f in nfields(offline_matrices)
        matrix = getfield(offline_matrices, f)
        @test isa(matrix, AbstractMatrix) || isa(matrix, Factorization)
        @test !isa(matrix, AbstractMatrix) || all(isfinite, matrix)
    end
    
    # online_matrices struct fields should all be AbstractMatrix subtypes but may be
    # unintialised so cannot say anything about values
    online_matrices = ParticleDA.init_online_matrices(model_data, nprt_per_rank)
    for f in nfields(online_matrices)
        matrix = getfield(online_matrices, f)
        @test isa(matrix, AbstractMatrix) 
    end    
    
    # update_particles_given_observations should change at least some elements in
    # particle state arrays
    filter_params = FilterParameters()
    filter_data = ParticleDA.init_filter(
        filter_params, model_data, nprt_per_rank, rng, Float64, OptimalFilter()
    )
    observations = ParticleDA.update_truth!(model_data)
    old_particles = copy(ParticleDA.get_particles(model_data))
    ParticleDA.update_particles_given_observations!(
        model_data, filter_data, observations, nprt_per_rank
    )
    new_particles = ParticleDA.get_particles(model_data)
    @test all(isfinite, new_particles)
    @test any(old_particles .!= new_particles)

end

@testset "Optimal Filter validation" begin
    seed = 1689017430981346891
    MPI.Init()
    my_rank = 0
    input_file = joinpath(
        dirname(pathof(ParticleDA)), "..", "test", "optimal_filter_test_2.yaml"
    )
    filter_type = OptimalFilter()
    rng = Random.seed!(seed)
    user_input_dict = ParticleDA.read_input_file(input_file)
    model_params_dict = get(user_input_dict, "model", Dict())
    filter_params_dict = get(user_input_dict, "filter", Dict())
    nprt_per_rank = 1
    # Compute state noise covariance matrix once only as potentially large and invariant
    # to number of particles
    model_data = Model.init(model_params_dict, nprt_per_rank, my_rank, rng)
    state_dimension = ParticleDA.get_state_dimension(model_data)
    updated_indices = ParticleDA.get_state_indices_correlated_to_observations(model_data)
    cov_X_X = [
        ParticleDA.get_covariance_state_noise(model_data, i, j)
        for i in 1:state_dimension, j in 1:state_dimension
    ]
    # State noise covariance should be positive definite and so symmetric and
    # satisfying the trace inequality tr(C) > 0
    @test issymmetric(cov_X_X) && tr(cov_X_X) > 0
    for nprt in [25, 100, 400, 2500, 10000]
        filter_params_dict["nprt"] = nprt
        filter_params = ParticleDA.get_params(FilterParameters, filter_params_dict)
        nprt_per_rank = nprt
        model_data = Model.init(model_params_dict, nprt_per_rank, my_rank, rng)
        filter_data = ParticleDA.init_filter(
            filter_params, model_data, nprt_per_rank, rng, Float64, filter_type
        )
        observations = ParticleDA.update_truth!(model_data)
        initial_particles = copy(ParticleDA.get_particles(model_data))
        firstonlastaxis(array) = selectdim(array, ndims(array), 1)
        # Force all particles equal to first
        initial_particles .= firstonlastaxis(initial_particles)
        ParticleDA.set_particles!(model_data, initial_particles)
        ParticleDA.update_particle_dynamics!(model_data, nprt_per_rank)
        particles = copy(ParticleDA.get_particles(model_data))
        # update_particle_dynamics should at least some change particle components
        @test any(particles .!= initial_particles)
        # update_particle_dynamics should be deterministic so all particles remain equal 
        # to each other
        @test all(firstonlastaxis(particles) .== particles)
        observation_mean_given_particle = copy(firstonlastaxis(
            ParticleDA.get_particle_observations!(model_data, nprt_per_rank)
        ))
        ParticleDA.update_particle_noise!(model_data, nprt_per_rank)
        noised_particles = copy(ParticleDA.get_particles(model_data))
        noise = noised_particles .- particles
        # Mean of noise added by update_particle_noise! should be zero in all components
        # and empirical mean should therefore be zero to within Monte Carlo error. The
        # constant in the tolerance below was set by looking at scale of typical
        # deviation, the point of check is that errors scale at expected O(1/√N) rate.     
        @test maximum(abs.(mean(noise, dims=2))) < (4. / sqrt(nprt))  
        # Covariance of noise added by update_particle_noise! to observed state
        # components should be cov_X_X as computed above and empirical covariance of
        # these components should therefore be within Monte Carlo error of cov_X_X. The
        # constant in tolerance below was set by looking at scale of typical deviations,
        # the point of check is that errors scale at expected O(1/√N) rate.     
        noise_cov = cov(noise, dims=2)
        @test maximum(abs.(noise_cov .- cov_X_X)) < (6. / sqrt(nprt))         
        ParticleDA.update_particles_given_observations!(
            model_data, filter_data, observations, nprt_per_rank
        )
        updated_particles = ParticleDA.get_particles(model_data)
        updated_particles_mean = mean(updated_particles, dims=2)
        updated_particles_cov = cov(updated_particles, dims=2)
        cov_X_Y = filter_data.offline_matrices.cov_X_Y
        cov_Y_Y = filter_data.offline_matrices.cov_Y_Y
        # Optimal proposal for conditionally Gaussian state-space model with updates
        # X = F(x) + U and Y = HX + V where x is the previous state value, F the forward
        # operator for the deterministic state dynamics, U ~ Normal(0, Q) the additive
        # state noise, X the state at the next time step, H the linear observation
        # operator, V ~ Normal(0, R) the additive observation noise and Y the modelled 
        # observations, is Normal(m, C) where 
        # m = F(x) + QHᵀ(HQHᵀ + R)⁻¹(y − HF(x))
        #   = F(x) + cov(X, Y) @ cov(Y, Y)⁻¹ (y − HF(x)) 
        # and C = Q − QHᵀ(HQHᵀ + R)⁻¹HQ = cov(X, X) - cov(X, Y) cov(Y, Y)⁻¹ cov(X, Y)ᵀ
        analytic_mean = copy(firstonlastaxis(particles))
        @view(analytic_mean[updated_indices]) .+= (
            cov_X_Y * (cov_Y_Y \ (observations .- observation_mean_given_particle))
        )
        analytic_cov = copy(cov_X_X)
        @view(analytic_cov[updated_indices, updated_indices]) .-= cov_X_Y * (cov_Y_Y \ cov_X_Y')
        # Mean and covariance of updated particles should be within O(1/√N) Monte Carlo 
        # error of analytic values - constants in tolerances were set by looking at
        # scale of typical deviations, main point of checks are that errors scale at
        # expected O(1/√N) rate.
        @test maximum(
            abs.(updated_particles_mean .- analytic_mean)
        ) < (4. / sqrt(nprt))
        @test maximum(
            abs.(updated_particles_cov .- analytic_cov)
        ) < (6. / sqrt(nprt))
    end
end
