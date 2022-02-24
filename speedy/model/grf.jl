module Periodic_Cov
using Statistics, LinearAlgebra
using GaussianRandomFields
import GaussianRandomFields: shortname, apply, apply_symmetric!, apply_non_symmetric!

abstract type Distance end

shortname(::Distance) = "custom distance"
function apply(::Distance, x::NTuple{d, Real}, y::NTuple{d, Real}) where d end

struct CustomDistanceCovarianceStructure{T} <: CovarianceStructure{T} 
    distance::Distance
    cov::IsotropicCovarianceStructure{T}
end

apply(s::CustomDistanceCovarianceStructure, ρ::Real) = apply(s.cov, ρ)

shortname(s::CustomDistanceCovarianceStructure) = shortname(s.cov) * " on " * shortname(s.distance)

Statistics.std(c::IsotropicCovarianceStructure) = c.σ
Statistics.std(s::CustomDistanceCovarianceStructure) = Statistics.std(s.cov)
Statistics.std(f::AbstractCovarianceFunction) = Statistics.std(f.cov)

function apply_symmetric!(
    C::Matrix,
    s::CustomDistanceCovarianceStructure,
    x::NTuple{d, AbstractVector},
    y::NTuple{d, AbstractVector}
) where d
    xiterator = enumerate(Iterators.product(x...))
    for (j, idy) in enumerate(Iterators.product(y...))
        for (i, idx) in Iterators.take(xiterator, j)
            @inbounds C[i, j] = apply(s.cov, apply(s.distance, idx, idy))
        end
    end
    Symmetric(C, :U)
end

function apply_non_symmetric!(
    C::Matrix,
    s::CustomDistanceCovarianceStructure,
    x::NTuple{d, AbstractVector},
    y::NTuple{d, AbstractVector}
) where d
    xiterator = enumerate(Iterators.product(x...))
    for (j, idy) in enumerate(Iterators.product(y...))
        for (i, idx) in xiterator
            @inbounds C[i, j] = apply(s.cov, apply(s.distance, idx, idy))
        end
    end
    C
end

struct SphericalDistance <: Distance end

shortname(::SphericalDistance) = "spherical distance"

function apply(::SphericalDistance, (λ₁, φ₁)::Tuple{Float64, Float64}, (λ₂, φ₂)::Tuple{Float64, Float64})
    Δλ = λ₂ - λ₁  # longitude difference
    Δφ = φ₂ - φ₁  # latitude difference
    # haversine formula
    a = sin(Δφ/2)^2 + cos(φ₁)*cos(φ₂)*sin(Δλ/2)^2
    # distance
    2 * ( asin( min(√a, one(a)) ))
end

struct EuclideanDistance <: Distance end
shortname(::EuclideanDistance) = "Euclidean distance"
apply(::EuclideanDistance, x::NTuple{d, Real}, y::NTuple{d, Real}) where d = norm(x .- y)
end
