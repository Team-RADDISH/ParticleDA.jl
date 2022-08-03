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

@testset "ParticleDA unit tests" begin
    dx = dy = 2e3

    x = collect(reshape(1.0:9.0, 3, 3, 1))
    # stations at (1,1) (2,2) and (3,3) return diagonal of x[3,3]
    station_grid_indices = [1 1; 2 2; 3 3]
    obs = Vector{Float64}(undef, 3)
    Model.get_obs!(obs, x, [1], station_grid_indices)
    @test obs ≈ [1.,5.,9.]

    y = [1.0, 2.0]
    cov_obs = ScalMat(2, 1)
    weights = Vector{Float64}(undef, 3)
    # model observations with equal distance from true observation return equal weights
    hx = [0.5 0.9 1.5; 2.1 2.5 1.9]
    ParticleDA.get_log_weights!(weights, y, hx, (cov_observation_noise=cov_obs,), BootstrapFilter())
    @test diff(weights) ≈ zeros(2)
    ParticleDA.normalized_exp!(weights)
    @test weights ≈ ones(3) / 3
    # model observations with decreasing distance from true observation return decreasing weights
    hx = [0.9 0.5 1.5; 2.1 2.5 3.5]
    ParticleDA.get_log_weights!(weights, y, hx, (cov_observation_noise=cov_obs,), BootstrapFilter())
    ParticleDA.normalized_exp!(weights)
    @test weights[1] > weights[2] > weights[3]

    id = zeros(Int, 5)
    # equal weights return the same particles
    w = ones(5) * .2
    ParticleDA.resample!(id,w)
    @test sort(id) == [1,2,3,4,5]
    # weight of 1.0 on first particle returns only copies of that particle
    w = zeros(5)
    w[1] = 1.0
    ParticleDA.resample!(id,w)
    @test id == [1,1,1,1,1]
    # weight of 1.0 on last particle returns only copies of that particle
    w = zeros(5)
    w[end] = 1.0
    ParticleDA.resample!(id,w)
    @test id == [5,5,5,5,5]
    # weights of .4 and .6 on particles 2 and 4 return a 40/60 mix of those particles
    w = zeros(5)
    w[2] = .4
    w[4] = .6
    ParticleDA.resample!(id,w)
    @test sort(id) == [2,2,4,4,4]

    nx = 10
    ny = 10
    dt = 1.0
    nt = 1
    # 0 input gives 0 output
    x0 = x = zeros(nx, ny, 3)
    model_matrices = LLW2d.setup(nx,ny,3.0e4, 0.1, 0.015, 10.0)
    @test size(model_matrices.absorbing_boundary) ==
        size(model_matrices.ocean_depth) ==
        size(model_matrices.x_averaged_depth) ==
        size(model_matrices.land_filter_m) ==
        size(model_matrices.land_filter_n) ==
        size(model_matrices.land_filter_e) == (nx, ny)
    dxeta = Matrix{Float64}(undef, nx, ny)
    dyeta = Matrix{Float64}(undef, nx, ny)
    Model.tsunami_update!(dxeta, dyeta, x, nt, dx, dy, dt, model_matrices)
    @test x ≈ x0

    # Initialise and update a tsunami on a small grid
    s = 4e3
    peak_position = [floor(Int, nx/4) * dx, floor(Int, ny/4) * dy]
    eta = @view(x[:,:,1])
    LLW2d.initheight!(eta, model_matrices, dx, dy, s, 1.0, peak_position)
    @test eta[2,2] ≈ 1.0
    @test sum(eta) ≈ 4.0
    Model.tsunami_update!(dxeta, dyeta, x, nt, dx, dy, dt, model_matrices)
    @test sum(eta, dims=1) ≈ [0.98161253125 1.8161253125 0.98161253125 0.073549875 0.0 0.0 0.0 0.0 0.0 0.0]
    @test sum(eta, dims=2) ≈ [0.98161253125 1.8161253125 0.98161253125 0.073549875 0.0 0.0 0.0 0.0 0.0 0.0]'

    # Test gaussian random field sampling
    x = 1.:2.
    y = 1.:2.
    sigma = lambda = nu = fill(1.0,3)
    grf = Model.init_gaussian_random_field_generator(lambda, nu, sigma,x,y,0,false)
    f = zeros(2, 2)
    rnn = [9.,9.,9.,9.]
    Model.sample_gaussian_random_field!(f,grf[1],rnn)
    @test f ≈ [16.2387054353321 5.115956753643808; 5.115956753643809 2.8210669567042155]

    # Test IO
    params_dict = YAML.load_file(joinpath(@__DIR__, "io_unit_test.yaml"))
    filter_params = ParticleDA.get_params(FilterParameters, params_dict["filter"])
    model_params = ParticleDA.get_params(ModelParameters, params_dict["model"]["llw2d"])
    rm(filter_params.output_filename, force=true)
    data1 = collect(reshape(1.0:(model_params.nx * model_params.ny), model_params.nx, model_params.ny, 1))
    data2 = randn(model_params.nx, model_params.ny, 1)
    tstep = 0
    h5open(filter_params.output_filename, "cw") do file
        Model.write_field(file, @view(data1[:,:,1]), tstep, "m", model_params.title_syn, "height", "unit test", model_params)
        Model.write_field(file, @view(data2[:,:,1]), tstep, "inch", model_params.title_avg,  "height", "unit test", model_params)
    end
    @test h5read(filter_params.output_filename, model_params.state_prefix * "_" * model_params.title_syn * "/t0000/height") ≈ data1
    @test h5read(filter_params.output_filename, model_params.state_prefix * "_" * model_params.title_avg * "/t0000/height") ≈ data2
    attr = h5readattr(filter_params.output_filename, model_params.state_prefix * "_" * model_params.title_syn * "/t0000/height")
    @test attr["Unit"] == "m"
    @test attr["Time step"] == tstep
    attr = h5readattr(filter_params.output_filename, model_params.state_prefix * "_" * model_params.title_avg * "/t0000/height")
    @test attr["Unit"] == "inch"
    @test attr["Time step"] == tstep
    Model.write_params(filter_params.output_filename, model_params)
    attr = h5readattr(filter_params.output_filename, model_params.title_params)
    @test attr["nx"] == model_params.nx
    @test attr["ny"] == model_params.ny
    @test attr["dx"] == model_params.dx
    @test attr["dy"] == model_params.dy
    @test attr["title_avg"] == model_params.title_avg
    @test attr["title_syn"] == model_params.title_syn
    Model.write_grid(filter_params.output_filename, model_params)
    attr = h5readattr(filter_params.output_filename, model_params.title_grid * "/x")
    @test attr["Unit"] == "m"
    attr = h5readattr(filter_params.output_filename, model_params.title_grid * "/y")
    @test attr["Unit"] == "m"

    station_grid_indices = Model.get_station_grid_indices(model_params)
    @test station_grid_indices[:, 1] == [5, 5, 10, 10]
    @test sstation_grid_indices[:, 2] == [5, 10, 5, 10]
    Model.write_stations(filter_params.output_filename, stations.ist, stations.jst, model_params)
    @test h5read(filter_params.output_filename, model_params.title_stations * "/x") ≈ (
        (station_grid_indices[:, 1] .- 1) .* model_params.dx
    )
    @test h5read(filter_params.output_filename, model_params.title_stations * "/y") ≈ (
        (station_grid_indices[:, 2] .- 1) .* model_params.dy
    )
    attr = h5readattr(filter_params.output_filename, model_params.title_stations * "/x")
    @test attr["Unit"] == "m"
    attr = h5readattr(filter_params.output_filename, model_params.title_stations * "/y")
    @test attr["Unit"] == "m"

    rm(filter_params.output_filename, force=true)

    # Model data and get particles
    input_file = joinpath(dirname(pathof(ParticleDA)), "..", "test", "integration_test_1.yaml")
    model_params_dict = get(ParticleDA.read_input_file(input_file), "model", Dict())
    nprt_per_rank = 1
    my_rank = 0
    model_data = Model.init(model_params_dict, nprt_per_rank, my_rank, Random.TaskLocalRNG())
    # Make sure `get_particles` always returns the same array
    @test pointer(ParticleDA.get_particles(model_data)) == pointer(ParticleDA.get_particles(model_data))
end

@testset "ParticleDA integration tests" begin

    # Test true state with standard parameters
    x_true,x_avg,x_var = ParticleDA.run_particle_filter(Model.init, joinpath(@__DIR__, "integration_test_1.yaml"), BootstrapFilter())
    data_true = h5read(joinpath(@__DIR__, "reference_data.h5"), "integration_test_1")
    @test all(x_true .≈ data_true)

    # Test true state with different parameters
    x_true,x_avg,x_var = ParticleDA.run_particle_filter(Model.init, joinpath(@__DIR__, "integration_test_2.yaml"), BootstrapFilter())
    data_true = h5read(joinpath(@__DIR__, "reference_data.h5"), "integration_test_2")
    @test all(x_true .≈ data_true)

    # Test particle state with ~zero noise
    x_true,x_avg,x_var = ParticleDA.run_particle_filter(Model.init, joinpath(@__DIR__, "integration_test_3.yaml"), BootstrapFilter())
    @test x_true ≈ x_avg
    @test x_var .+ 1.0 ≈ ones(size(x_var))

    if Threads.nthreads() == 1

        avg_ref = h5read(joinpath(@__DIR__, "reference_data.h5"), "integration_test_4")
        # Test particle state with noise
        rng = StableRNG(123)
        x_true,x_avg,x_var = ParticleDA.run_particle_filter(Model.init, joinpath(@__DIR__, "integration_test_4.yaml"), BootstrapFilter(); rng)
        @test all(x_avg .≈ avg_ref)

        # Test that different seed gives different result
        rng = StableRNG(124)
        x_true,x_avg,x_var = ParticleDA.run_particle_filter(Model.init, joinpath(@__DIR__, "integration_test_4.yaml"), BootstrapFilter(); rng)
        @test !all(x_avg .≈ avg_ref)

        # Test optimal filter
        avg_ref = h5read(joinpath(@__DIR__, "reference_data.h5"), "integration_test_6")
        rng = StableRNG(123)
        x_true,x_avg,x_var = ParticleDA.run_particle_filter(Model.init, joinpath(@__DIR__, "optimal_filter_test_1.yaml"), OptimalFilter(); rng)
        @test all(x_avg .≈ avg_ref)

    end

end

@testset "MPI -- $(file)" for file in ("mpi.jl", "copy_states.jl", "mean_and_var.jl")
    julia = joinpath(Sys.BINDIR, Base.julia_exename())
    flags = ["--startup-file=no", "-q", "-t$(Base.Threads.nthreads())"]
    script = joinpath(@__DIR__, file)
    mpiexec() do mpiexec
        mktempdir() do dir
            cd(dir) do
                @test success(run(ignorestatus(`$(mpiexec) -n 3 $(julia) $(flags) $(script)`)))
            end
        end
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
