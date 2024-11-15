"""
    AbstractSummaryStat
    
Abstract type for summary statistics of particle ensemble. Concrete subtypes can be
passed as the `filter_type` argument to [`run_particle_filter`](@ref) to specify which
summary statistics to record and how they are computed.

See also: [`AbstractSumReductionSummaryStat`](@ref), 
[`AbstractCustomReductionSummaryStat`](@ref).
"""
abstract type AbstractSummaryStat{T} end

"""
    AbstractSumReductionSummaryStat <: AbstractSummaryStat

Abstract type for summary statistics computed using standard MPI sum reductions. 
Compatible with a wider range of CPU architectures but may require less numerically
stable implementations.
"""
abstract type AbstractSumReductionSummaryStat{T} <: AbstractSummaryStat{T} end

"""
    AbstractCustomReductionSummaryStat <: AbstractSummaryStat

Abstract type for summary statistics computed using custom MPI reductions. Allows
greater flexibility in computing statistics which can support more numerically stable
implementations, but at a cost of not being compatible with all CPU architectures. In
particular, `MPI.jl` does not currently support custom operators 
[on Power PC and ARM architecures](https://github.com/JuliaParallel/MPI.jl/issues/404).
"""
abstract type AbstractCustomReductionSummaryStat{T} <: AbstractSummaryStat{T} end

"""
    NaiveMeanSummaryStat <: AbstractSumReductionSummaryStat
    
Sum reduction based summary statistic type which computes the means of the particle
ensemble for each state dimension. The mean is computed by directly accumulating the 
sums of the particle values and number of particles on each rank. If custom reductions 
are supported by the CPU architecture in use the more numerically stable 
[`MeanSummaryStat`](@ref) should be used instead.
"""
struct NaiveMeanSummaryStat{T} <: AbstractSumReductionSummaryStat{T}
    sum::T
    n::Int
end

compute_statistic(::Type{<:NaiveMeanSummaryStat}, x::AbstractVector) = (
    NaiveMeanSummaryStat(sum(x), length(x))
)

statistic_names(::Type{<:NaiveMeanSummaryStat}) = (:avg,)

unpack(S::NaiveMeanSummaryStat) = (; avg=S.sum / S.n)


"""
    NaiveMeanAndVarSummaryStat <: AbstractSumReductionSummaryStat
    
Sum reduction based summary statistic type which computes the means and variances of the
particle ensemble for each state dimension. The mean and variance are computed by
directly accumulating the  sums of the particle values, the squared particle values and
number of particles on each rank, with the variance computed as the scaled difference
between the sum of the squares and square of the sums. This 'naive' implementation
avoids custom MPI reductions but can be numerically unstable for large ensembles or
state components with large values. If custom reductions are supported by the CPU
architecture in use the more numerically stable [`MeanAndVarSummaryStat`](@ref) should
be used instead.
"""
struct NaiveMeanAndVarSummaryStat{T} <: AbstractSumReductionSummaryStat{T}
    sum::T
    sum_sq::T
    n::Int
end

compute_statistic(::Type{<:NaiveMeanAndVarSummaryStat}, x::AbstractVector) = (
    NaiveMeanAndVarSummaryStat(sum(x), sum(abs2, x), length(x))
)

statistic_names(::Type{<:NaiveMeanAndVarSummaryStat}) = (:avg, :var)

unpack(S::NaiveMeanAndVarSummaryStat) = (
    avg=S.sum / S.n, var=(S.sum_sq - S.sum^2 / S.n) / (S.n - 1)
)

function init_statistics(
    S::Type{<:AbstractSumReductionSummaryStat}, T::Type, dimension::Int
)
    return StructVector{S{T}}(undef, dimension)
end

function update_statistics!(
    statistics::StructVector{S}, states::AbstractMatrix{T}, master_rank::Int,
) where {T, S <: AbstractSumReductionSummaryStat{T}}
    Threads.@threads for i in eachindex(statistics)
        statistics[i] = compute_statistic(S, selectdim(states, 1, i))
    end
    for name in fieldnames(S)
        MPI.Reduce!(getproperty(statistics, name), +, master_rank, MPI.COMM_WORLD)
    end
end

function unpack_statistics!(
    unpacked_statistics::NamedTuple, statistics::StructVector{S}
) where {T, S <: AbstractSumReductionSummaryStat{T}}
        Threads.@threads for i in eachindex(statistics)
        for (name, val) in pairs(unpack(statistics[i]))
            unpacked_statistics[name][i] = val
        end
    end     
end


"""
    MeanSummaryStat <: AbstractCustomReductionSummaryStat
    
Custom reduction based summary statistic type which computes the means of the particle
ensemble for each state dimension. On CPU architectures which do not support custom
reductions [`NaiveMeanSummaryStat`](@ref) can be used instead.
"""
struct MeanSummaryStat{T} <: AbstractCustomReductionSummaryStat{T}
    avg::T
    n::Int
end

compute_statistic(::Type{<:MeanSummaryStat}, x::AbstractVector) = (
    MeanSummaryStat(mean(x), length(x))
)

statistic_names(::Type{<:MeanSummaryStat}) = (:avg,)

function combine_statistics(s1::MeanSummaryStat, s2::MeanSummaryStat)
    n = s1.n + s2.n
    m = (s1.avg * s1.n + s2.avg * s2.n) / n
    MeanSummaryStat(m, n)
end

"""
    MeanAndVarSummaryStat <: AbstractCustomReductionSummaryStat
    
Custom reduction based summary statistic type which computes the means and variances o
the particle ensemble for each state dimension. On CPU architectures which do not
support custom reductions [`NaiveMeanAndVarSummaryStat`](@ref) can be used instead.
"""
struct MeanAndVarSummaryStat{T} <: AbstractCustomReductionSummaryStat{T}
    avg::T
    var::T
    n::Int
end

function compute_statistic(::Type{<:MeanAndVarSummaryStat}, x::AbstractVector)
    m = mean(x)
    v = varm(x, m, corrected=true)
    n = length(x)
    MeanAndVarSummaryStat(m, v, n)
end

statistic_names(::Type{<:MeanAndVarSummaryStat}) = (:avg, :var)

function combine_statistics(s1::MeanAndVarSummaryStat, s2::MeanAndVarSummaryStat)
    n = s1.n + s2.n
    m = (s1.avg * s1.n + s2.avg * s2.n) / n
    # Calculate pooled unbiased sample variance of two groups.
    # From https://stats.stackexchange.com/q/384951
    # Can be found in https://www.tandfonline.com/doi/abs/10.1080/00031305.2014.966589
    v = (
        (s1.n - 1) * s1.var 
        + (s2.n - 1) * s2.var 
        + s1.n * s2.n / n * (s2.avg - s1.avg)^2
    ) / (n - 1)
    MeanAndVarSummaryStat(m, v, n)
end

# Register the custom reduction operator.  This is necessary only on platforms
# where Julia doesn't support closures as cfunctions (e.g. ARM), but can be used
# on all platforms for consistency.
MPI.@RegisterOp(combine_statistics, AbstractCustomReductionSummaryStat)

function init_statistics(
    S::Type{<:AbstractCustomReductionSummaryStat}, T::Type, dimension::Int
)
    return Array{S{T}}(undef, dimension)
end

function update_statistics!(
    statistics::AbstractVector{S}, states::AbstractMatrix{T}, master_rank::Int,
) where {T, S <: AbstractCustomReductionSummaryStat{T}}
    Threads.@threads for i in eachindex(statistics)
        statistics[i] = compute_statistic(S, selectdim(states, 1, i))
    end
    MPI.Reduce!(statistics, combine_statistics, master_rank, MPI.COMM_WORLD)
end

function unpack_statistics!(
    unpacked_statistics::NamedTuple, statistics::AbstractVector{S}
) where {T, S <: AbstractCustomReductionSummaryStat{T}}
    Threads.@threads for i in eachindex(statistics)
        for name in statistic_names(S)
            unpacked_statistics[name][i] = getfield(statistics[i], name)
        end
    end     
end

init_unpacked_statistics(S::Type{<:AbstractSummaryStat}, T::Type, dimension::Int) = (;
    (name => Array{T}(undef, dimension) for name in statistic_names(S))...
)
