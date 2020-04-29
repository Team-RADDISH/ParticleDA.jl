using TDAC
using LinearAlgebra, Test, HDF5, Random

@testset "LLW2d" begin
    using TDAC.LLW2d

    dx = dy = 2e3
    
    ### set_stations!
    ist = Vector{Int}(undef, 4)
    jst = Vector{Int}(undef, 4)
    LLW2d.set_stations!(ist, jst, 20, 150, 1e3, 1e3, dx, dy)                         
    @test ist == [75, 75, 85, 85]
    @test jst == [75, 85, 75, 85]
    ist = rand(Int, 9)
    jst = rand(Int, 9)
    LLW2d.set_stations!(ist, jst, 20, 150, 1e3, 1e3, dx, dy)

    @test ist == [75, 75, 75, 85, 85, 85, 95, 95, 95]
    @test jst == [75, 85, 95, 75, 85, 95, 75, 85, 95]

    ### initheight!
    eta = ones(2, 2)
    hh  = ones(2, 2)
    LLW2d.initheight!(eta, hh, dx, dy, 3e4)
    @test eta ≈ [0.978266982572228  0.9463188389826958;
                 0.9463188389826958 0.9154140546161575]
    eta = ones(2, 2)
    hh  = zeros(2, 2)
    LLW2d.initheight!(eta, hh, dx, dy, 3e4)
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
    hn = rand(n, n)
    hm = rand(n, n)
    fm = rand(n, n)
    fn = rand(n, n)
    fe = rand(n,n)
    gg = rand(n,n)
    LLW2d.timestep!(eta1, mm1, nn1, eta0, mm0, nn0, hm, hn, fm, fn, fe, gg, dx, dy, 1)

    # setup.  TODO: add real tests.  So far we're just making sure code won't
    # crash
    LLW2d.setup(n, n, 3e4)
end

@testset "TDAC unit tests" begin
    dx = dy = 2e3
    
    @test TDAC.get_distance(3/2000, 4/2000, 0, 0, dx, dy) == 5
    @test TDAC.get_distance(10, 23, 5, 11, dx, dy) == 26000.0

    x = Vector(1.:9.)
    # stations at (1,1) (2,2) and (3,3) return diagonal of x[3,3]
    ist = [1,2,3]
    jst = [1,2,3]
    obs = Vector{Float64}(undef, 3)
    TDAC.get_obs!(obs,x,3,ist,jst)
    @test obs ≈ [1.,5.,9.]

    # Observation covariances are ~exp(-sqrt(dx^2+dy^2)/r) 
    d11 = exp(-(sqrt(0.8e7) * 5e-5) ^ 2)
    d22 = exp(-(sqrt(3.2e7) * 5e-5) ^ 2)
    @test TDAC.get_obs_covariance(3,5.0e-5,dx,dy,ist,jst) ≈ [1.0 d11 d22; d11 1.0 d11; d22 d11 1.0]

    y = [1.0, 2.0]
    cov_obs = float(I(2))
    weights = Vector{Float64}(undef, 3)
    # model observations with equal distance from true observation return equal weights
    hx = [0.5 0.9 1.5; 2.1 2.5 1.9]
    TDAC.get_weights!(weights, y, hx, cov_obs)
    @test weights ≈ ones(3) / 3
    # model observations with decreasing distance from true observation return decreasing weights
    hx = [0.9 0.5 1.5; 2.1 2.5 3.5]
    TDAC.get_weights!(weights, y, hx, cov_obs)
    @test weights[1] > weights[2] > weights[3]
    # TODO: test with cov != I

    x = reshape(Vector(1.:10.),2,5)
    xrs = zero(x)
    # equal weights return the same particles
    w = ones(5) * .2
    TDAC.resample!(xrs,x,w)
    @test xrs ≈ x
    # weight of 1.0 on first particle returns only copies of that particle
    w = zeros(5)
    w[1] = 1.0
    TDAC.resample!(xrs,x,w)
    @test xrs ≈ ones(2,5) .* x[:,1]
    # weight of 1.0 on last particle returns only copies of that particle
    w = zeros(5)
    w[end] = 1.0
    TDAC.resample!(xrs,x,w)
    @test xrs ≈ ones(2,5) .* x[:,end]
    # weights of .4 and .6 on particles 2 and 4 return a 40/60 mix of those particles
    w = zeros(5)
    w[2] = .4
    w[4] = .6
    TDAC.resample!(xrs,x,w)
    @test sum(xrs, dims=2)[:] ≈ 2 .* x[:,2] + 3 .* x[:,4]
    
    nx = 10
    ny = 10
    dt = 1.0
    # 0 input gives 0 output
    x0 = x = zeros(nx * ny * 3)
    gg, hh, hm, hn, fm, fn, fe = TDAC.LLW2d.setup(nx,ny,3.0e4)
    @test size(gg) == size(hh) == size(hm) == size(fm) == size(fn) == size(fe) == (nx,ny)
    TDAC.tsunami_update!(x, nx, ny, nx*ny, dx, dy, dt, hm, hn, fm, fn, fe, gg)
    @test x ≈ x0

    # Initialise and update a tsunami on a small grid
    s = 4e3
    eta = reshape(@view(x[1:nx*ny]), nx, ny)
    TDAC.LLW2d.initheight!(eta, hh, dx, dy, s)
    @test eta[2,2] ≈ 1.0
    @test sum(eta) ≈ 4.0
    TDAC.tsunami_update!(x, nx, ny, nx*ny, dx, dy, dt, hm, hn, fm, fn, fe, gg)
    @test sum(eta, dims=1) ≈ [0.9140901416339269 1.7010577375770561 0.9140901416339269 0.06356127284539884 0.0 0.0 0.0 0.0 0.0 0.0]
    @test sum(eta, dims=2) ≈ [0.9068784611641829; 1.6999564781646717; 0.9204175965604575; 0.06554675780099671; 0.0; 0.0; 0.0; 0.0; 0.0; 0.0]
    
    # Test gaussian random field sampling
    x = 1.:2.
    y = 1.:2.
    grf = TDAC.init_gaussian_random_field_generator(1.0,1.0,1.0,x,y,0)
    f = zeros(4)
    rnn = [9.,9.,9.,9.]
    TDAC.sample_gaussian_random_field!(f,grf,rnn)
    @test f ≈ [16.2387054353321, 5.115956753643808, 5.115956753643809, 2.8210669567042155]

    # Test IO
    params = TDAC.get_params("io_unit_test.yaml")
    rm(params.output_filename, force=true)
    data1 = ones(params.dim_grid)
    data2 = ones(params.dim_grid) .* 2
    tstep = 1
    TDAC.write_snapshot(data1, data2, tstep, params)
    @test h5read(params.output_filename, params.state_prefix * "_" * params.title_syn * "/t0/height") ≈ data1
    @test h5read(params.output_filename, params.state_prefix * "_" * params.title_da * "/t0/height") ≈ data2
    attr = h5readattr(params.output_filename, params.state_prefix * "_" * params.title_syn * "/t0/height")
    @test attr["Unit"] == "m"
    @test attr["Time_step"] == tstep
    attr = h5readattr(params.output_filename, params.state_prefix * "_" * params.title_da * "/t0/height")
    @test attr["Unit"] == "m"
    @test attr["Time_step"] == tstep
    TDAC.write_grid(params)
    attr = h5readattr(params.output_filename, params.title_grid)
    @test attr["nx"] == params.nx
    @test attr["ny"] == params.ny
    @test attr["dx"] == params.dx
    @test attr["dy"] == params.dy
    attr = h5readattr(params.output_filename, params.title_grid * "/x")
    @test attr["Unit"] == "m"
    attr = h5readattr(params.output_filename, params.title_grid * "/y")
    @test attr["Unit"] == "m"    
    rm(params.output_filename, force=true)
end

@testset "TDAC integration tests" begin

    x_true,x_da = TDAC.tdac("integration_test_1.yaml")
    data_true = h5read("reference_data.h5", "integration_test_1")
    @test x_true ≈ data_true
    
end
