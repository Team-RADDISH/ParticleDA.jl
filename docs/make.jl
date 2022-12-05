using Documenter, ParticleDA

# Load the `Model` module from the tests to show the docstring of the parameters
test_dir = joinpath(dirname(pathof(ParticleDA)), "..", "test")
module_src = joinpath(test_dir, "models", "ll2wd.jl")
include(module_src)
using .LLW2d

makedocs(
    modules = [ParticleDA, Model],
    sitename = "ParticleDA",
)

deploydocs(
    repo = "github.com/Team-RADDISH/ParticleDA.jl",
    target = "build",
    deps = nothing,
    make = nothing,
)
