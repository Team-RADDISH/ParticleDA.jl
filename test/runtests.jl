using TDAC
using LinearAlgebra, Test

@testset "Matrix_ls" begin
    using TDAC.Matrix_ls

    ### gs!
    n = 5

    m = float(collect(I(n)))
    a = Vector{Float64}(undef, n)
    v = ones(n)
    gs!(m, v, a)
    @test a == v
    v = zeros(n)
    gs!(m, v, a)
    @test a == v
    v = randn(n)
    gs!(m, v, a)
    @test a ≈ v

    v = randn(n)
    m = v .* I(5)
    gs!(m, v, a)
    @test a ≈ ones(n)

    v0 = 1.0:5.0
    m = v0 .* I(5)
    v = randn(n)
    gs!(m, v, a)
    @test a ≈ v ./ v0

    m = reshape(1.0:(n^2), (n,n)) ./ 10
    m[diagind(m)] *= 1e2
    v = 1.0:5.0
    gs!(m, v, a)
    @test a ≈ [0.08863042084147274, 0.02683554264812562, 0.022082135935372775,
               0.020330901243131676, 0.019420256962167263]

    m = reshape(1.0:(n^2), (n,n))
    v = (1.0:5.0) .^ 2
    @test_throws ErrorException gs!(m, v, a)
end

@testset "LLW2d" begin
    using TDAC.LLW2d

    ### set_stations!
    ist = Vector{Int}(undef, 4)
    jst = Vector{Int}(undef, 4)
    set_stations!(ist, jst)
    @test ist == [75, 75, 85, 85]
    @test jst == [75, 85, 75, 85]
    ist = rand(Int, 9)
    jst = rand(Int, 9)
    set_stations!(ist, jst)
    @test ist == [75, 75, 75, 85, 85, 85, 95, 95, 95]
    @test jst == [75, 85, 95, 75, 85, 95, 75, 85, 95]

    ### initheight!
    eta = ones(2, 2)
    hh  = ones(2, 2)
    initheight!(eta, hh)
    @test eta ≈ [0.978266982572228  0.9463188389826958;
                 0.9463188389826958 0.9154140546161575]
    eta = ones(2, 2)
    hh  = zeros(2, 2)
    initheight!(eta, hh)
    @test eta ≈ zeros(2, 2)
end
