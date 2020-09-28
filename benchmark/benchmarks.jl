using BenchmarkTools
using ParticleDA

include(joinpath(joinpath(@__DIR__, "..", "test"), "model", "model.jl"))
using .Model

const SUITE = BenchmarkGroup()

const params = Dict(
    "filter" => Dict(
        "nprt" => 32,
        "enable_timers" => true,
        "verbose" => true,
        "n_time_step" => 20,
    ),
    "model" => Dict(
        "llw2d" => Dict(
            "nx" => 200,
            "ny" => 200,
            "nobs" => 64,
            "padding" => 0,
        ),
    ),
)

SUITE["default"] = @benchmarkable ParticleDA.run_particle_filter($(Model.init), $(params), $(BootstrapFilter())) seconds=30 setup=(cd(mktempdir()))

#=

# Example of use:

using PkgBenchmark, ParticleDA

benchmarkpkg(ParticleDA, BenchmarkConfig(; env = Dict("JULIA_NUM_THREADS" => 2)))

=#
