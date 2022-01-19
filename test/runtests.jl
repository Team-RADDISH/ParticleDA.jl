using ParticleDA
using LinearAlgebra, Test, HDF5, Random, YAML
using MPI
using StableRNGs
using FFTW

using ParticleDA: FilterParameters

include(joinpath(@__DIR__, "model", "model.jl"))

using .Model, .Model.LLW2d
using .Model: ModelParameters

@testset "LLW2d" begin
    dx = dy = 2e3

    ### set_stations!
    ist = Vector{Int}(undef, 4)
    jst = Vector{Int}(undef, 4)
    LLW2d.set_stations!(ist, jst, 20e3, 20e3, 150e3, 150e3, dx, dy)
    @test ist == [75, 75, 85, 85]
    @test jst == [75, 85, 75, 85]
    ist = rand(Int, 9)
    jst = rand(Int, 9)
    LLW2d.set_stations!(ist, jst, 20e3, 20e3, 150e3, 150e3, dx, dy)

    @test ist == [75, 75, 75, 85, 85, 85, 95, 95, 95]
    @test jst == [75, 85, 95, 75, 85, 95, 75, 85, 95]

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
    ist = [1,2,3]
    jst = [1,2,3]
    obs = Vector{Float64}(undef, 3)
    Model.get_obs!(obs,x,3,ist,jst)
    @test obs ≈ [1.,5.,9.]

    y = [1.0, 2.0]
    cov_obs = float(I(2))
    weights = Vector{Float64}(undef, 3)
    # model observations with equal distance from true observation return equal weights
    hx = [0.5 0.9 1.5; 2.1 2.5 1.9]
    ParticleDA.get_log_weights!(weights, y, hx, cov_obs)
    @test weights ≈ [-1.9678770664093457, -1.9678770664093457, -1.9678770664093457]
    ParticleDA.normalized_exp!(weights)
    @test weights ≈ ones(3) / 3
    # model observations with decreasing distance from true observation return decreasing weights
    hx = [0.9 0.5 1.5; 2.1 2.5 3.5]
    ParticleDA.get_log_weights!(weights, y, hx, cov_obs)
    ParticleDA.normalized_exp!(weights)
    @test weights[1] > weights[2] > weights[3]

    # multivariate and independent methods give same weights when covariance matrix is diagonal
    weights2 = Vector{Float64}(undef, 3)
    ParticleDA.get_log_weights!(weights2, y, hx, 1.0)
    ParticleDA.normalized_exp!(weights2)
    @test weights2 ≈ weights

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

    stations = Model.StationVectors(zeros(Int,4), zeros(Int,4))
    Model.set_stations!(stations, model_params)
    @test stations.ist == [4, 4, 9, 9]
    @test stations.jst == [4, 9, 4, 9]
    Model.write_stations(filter_params.output_filename, stations.ist, stations.jst, model_params)
    @test h5read(filter_params.output_filename, model_params.title_stations * "/x") ≈ stations.ist .* model_params.dx
    @test h5read(filter_params.output_filename, model_params.title_stations * "/y") ≈ stations.jst .* model_params.dy
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
    _rng = [Random.MersenneTwister()]
    model_data = Model.init(model_params_dict, nprt_per_rank, my_rank, _rng)
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

    seed = 123
    Random.seed!(seed)

    # Use default parameters
    model_params = ModelParameters()
    filter_params = FilterParameters()
    grid = ParticleDA.Grid(model_params.nx,
                           model_params.ny,
                           model_params.dx,
                           model_params.dy,
                           model_params.x_length,
                           model_params.y_length)
    grid_ext = ParticleDA.Grid((grid.nx-1)*2,
                               (grid.ny-1)*2,
                               grid.dx,
                               grid.dy,
                               (grid.x_length-grid.dx)*2,
                               (grid.y_length-grid.dy)*2)
    noise_params = (sigma = model_params.sigma[1], lambda = model_params.lambda[1], nu = model_params.nu[1])

    # Set station coordinates
    ist = rand(1:model_params.nx, model_params.nobs)
    jst = rand(1:model_params.ny, model_params.nobs)
    stations = (nst = model_params.nobs, ist = ist, jst = jst)
    cov_ext = ParticleDA.extended_covariance(0.0, 0.5 * grid.y_length, grid, noise_params)
    @test cov_ext ≈ exp(-0.5 * model_params.y_length / (2 * noise_params.lambda))
    @test cov_ext ≈ ParticleDA.extended_covariance(2.0 * grid.x_length, 0.5 * grid.y_length, grid, noise_params)
    @test cov_ext ≈ ParticleDA.extended_covariance(0.0, 1.5 * grid.y_length, grid, noise_params)
    arr = rand(ComplexF64,10,10)
    arr2 = zeros(ComplexF64,10,10)
    arr3 = zeros(ComplexF64,10,10)
    fft_plan, fft_plan! = FFTW.plan_fft(arr), FFTW.plan_fft!(arr)
    ParticleDA.normalized_2d_fft!(arr2, arr, fft_plan, fft_plan!, grid_ext)
    ParticleDA.normalized_2d_fft!(arr3, arr2, fft_plan, fft_plan!, grid_ext, inv)
    @test arr ≈ arr3

    cov_1 = zeros(stations.nst, grid_ext.nx * grid_ext.ny)
    cov_2 = zeros(grid.nx * grid.ny, stations.nst)
    cov_3 = zeros(stations.nst,stations.nst)
    ParticleDA.covariance_stations_extended_grid!(cov_1,grid,grid_ext,stations,noise_params)
    ParticleDA.covariance_grid_stations!(cov_2,grid,stations,noise_params)
    ParticleDA.covariance_stations!(cov_3,grid,stations,noise_params,model_params.obs_noise_std)
    @test all(isfinite, cov_1)
    @test all(isfinite, cov_2)
    @test all(isfinite, cov_3)
    @test cov_3 == Symmetric(cov_3)

    height = rand(grid.nx, grid.ny, filter_params.nprt)
    obs = randn(stations.nst)
    tmp_array = Matrix{ComplexF64}(undef, grid_ext.nx, grid_ext.ny)
    fft_plan, fft_plan! = FFTW.plan_fft(tmp_array), FFTW.plan_fft!(tmp_array)
    mat_off = ParticleDA.init_offline_matrices(grid, grid_ext, stations, noise_params, model_params.obs_noise_std, fft_plan, fft_plan!, Float64)
    mat_on = ParticleDA.init_online_matrices(grid, grid_ext, stations, filter_params.nprt, Float64)
    @test minimum(mat_off.Lambda) > 0.0
    ParticleDA.calculate_mean_height!(mat_on.mean, height, mat_off, obs, stations, grid, grid_ext, fft_plan, fft_plan!, filter_params.nprt, model_params.obs_noise_std)
    @test all(isfinite, mat_on.mean)

    rng = Random.MersenneTwister(seed)
    ParticleDA.sample_height_proposal!(height, mat_off, mat_on, obs, stations, grid, grid_ext, fft_plan, fft_plan!, filter_params.nprt, rng, model_params.obs_noise_std)
    @test all(isfinite, mat_on.samples)

end

@testset "Optimal Filter validation" begin

    seed = 123
    Random.seed!(seed)
    rng = Random.MersenneTwister(seed)

    include(joinpath(@__DIR__,"optimal_filter_validation.jl"));

    params_dict = YAML.load_file(joinpath(@__DIR__, "optimal_filter_validation.yaml"))
    filter_params = ParticleDA.get_params(FilterParameters, params_dict["filter"])
    model_params = ParticleDA.get_params(ModelParameters, params_dict["model"]["llw2d"])

    grid = ParticleDA.Grid(model_params.nx,
                           model_params.ny,
                           model_params.dx,
                           model_params.dy,
                           model_params.x_length,
                           model_params.y_length)
    grid_ext = ParticleDA.Grid((grid.nx-1)*2,
                               (grid.ny-1)*2,
                               grid.dx,
                               grid.dy,
                               (grid.x_length-grid.dx)*2,
                               (grid.y_length-grid.dy)*2)

    noise_params = (sigma = model_params.sigma[1], lambda = model_params.lambda[1], nu = model_params.nu[1])

    stations = (nst = model_params.nobs, ist = st.st_ij[:,1].+1, jst = st.st_ij[:,2].+1)

    h(x,y) = sin(x)^2 + cos(y)^2
    height = zeros(model_params.nx, model_params.ny, filter_params.nprt)
    x = (1:model_params.nx) .* 2 * pi / model_params.nx
    y = (1:model_params.ny) .* 4 * pi / model_params.ny
    for i = 1:filter_params.nprt
        height[:,:,i] .= h.(x',y)
    end

    obs = zeros(model_params.nobs)
    for i = 1:model_params.nobs
        obs[i] = height[stations.ist[i], stations.jst[i],1] + rand()
    end

    tmp_array = Matrix{ComplexF64}(undef, grid_ext.nx, grid_ext.ny)
    fft_plan, fft_plan! = FFTW.plan_fft(tmp_array), FFTW.plan_fft!(tmp_array)
    mat_off = ParticleDA.init_offline_matrices(grid, grid_ext, stations, noise_params, model_params.obs_noise_std, fft_plan, fft_plan!, Float64)
    mat_on = ParticleDA.init_online_matrices(grid, grid_ext, stations, filter_params.nprt, Float64)

    ParticleDA.sample_height_proposal!(height, mat_off, mat_on, obs, stations, grid, grid_ext, fft_plan, fft_plan!, filter_params.nprt, rng, model_params.obs_noise_std)

    Yobs_t = copy(obs)
    FH_t = copy(reshape(permutedims(height, [3 1 2]), filter_params.nprt, (model_params.nx)*(model_params.ny)))

    Mean_height = Calculate_Mean(FH_t, th, st, Yobs_t, Sobs, gr)
    Samples = Sample_Height_Proposal(FH_t, th, st, Yobs_t, Sobs, gr)

    @test mat_on.mean ≈ permutedims(reshape(Mean_height, filter_params.nprt, model_params.nx, model_params.ny), [2 3 1])
    @test mat_on.samples ≈ permutedims(reshape(Samples, filter_params.nprt, model_params.nx, model_params.ny), [2 3 1])

    # print("old mean height: ")
    # @btime Mean_height = Calculate_Mean($FH_t, $th, $st, $Yobs_t, $Sobs, $gr)
    # print("new mean height: ")
    # @btime calculate_mean_height!($mat_on.mean, $height, $mat_off, $obs, $stations, $params)
    # print("old sampling: ")
    # @btime Samples = Sample_Height_Proposal($FH_t, $th, $st, $Yobs_t, $Sobs, $gr)
    # print("new sampling: ")
    # @btime sample_height_proposal!($height, $mat_off, $mat_on, $obs, $stations, $params, $rng)

end
