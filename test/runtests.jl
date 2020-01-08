using TDAC
import TDAC: matrix_gs!
using LinearAlgebra, Test

@testset "m_matrix" begin
    n = 5

    m = float(collect(I(n)))
    a = Vector{Float64}(undef, n)
    v = ones(n)
    matrix_gs!(m, v, a)
    @test a == v
    v = zeros(n)
    matrix_gs!(m, v, a)
    @test a == v
    v = randn(n)
    matrix_gs!(m, v, a)
    @test a ≈ v

    v = randn(n)
    m = v .* I(5)
    matrix_gs!(m, v, a)
    @test a ≈ ones(n)

    v0 = 1.0:5.0
    m = v0 .* I(5)
    v = randn(n)
    matrix_gs!(m, v, a)
    @test a ≈ v ./ v0

    m = reshape(1.0:(n^2), (n,n)) ./ 10
    m[diagind(m)] *= 1e2
    v = 1.0:5.0
    matrix_gs!(m, v, a)
    @test a ≈ [0.08863042084147274, 0.02683554264812562, 0.022082135935372775,
               0.020330901243131676, 0.019420256962167263]

    m = reshape(1.0:(n^2), (n,n))
    v = (1.0:5.0) .^ 2
    @test_throws ErrorException matrix_gs!(m, v, a)
end
