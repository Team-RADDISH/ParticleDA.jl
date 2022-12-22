using Documenter, ParticleDA

# Load the `LLW2d` module from the test/models to show the docstring of the parameters
test_dir = joinpath(dirname(pathof(ParticleDA)), "..", "test")
include(joinpath(test_dir, "models", "llw2d.jl"))
using .LLW2d

makedocs(
    modules = [ParticleDA, LLW2d],
    sitename = "ParticleDA",
)

deploydocs(
    repo = "github.com/Team-RADDISH/ParticleDA.jl",
    target = "build",
    deps = nothing,
    make = nothing,
)
