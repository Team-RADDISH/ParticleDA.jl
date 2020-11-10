using Documenter, ParticleDA

makedocs(
    modules = [ParticleDA],
    sitename = "ParticleDA",
)

deploydocs(
    repo = "github.com/Team-RADDISH/ParticleDA.jl",
    target = "build",
    deps = nothing,
    make = nothing,
)
