# To update the reference data, run
#   julia --project=. update_reference_data.jl
using ParticleDA, HDF5, StableRNGs
include(joinpath(@__DIR__, "model", "model.jl"))
using .Model

reference_file = joinpath(@__DIR__, "reference_data.h5")
rm(reference_file; force=true)

x_true, _, _ = ParticleDA.run_particle_filter(Model.init, joinpath(@__DIR__, "integration_test_1.yaml"), BootstrapFilter())
h5write(reference_file, "integration_test_1", x_true)
x_true, _, _ = ParticleDA.run_particle_filter(Model.init, joinpath(@__DIR__, "integration_test_2.yaml"), BootstrapFilter())
h5write(reference_file, "integration_test_2", x_true)
rng = StableRNG(123)
init_with_rng = (model_params_dict, nprt_per_rank, my_rank) -> Model.init(model_params_dict, nprt_per_rank, my_rank, rng)
_, x_avg, _ = ParticleDA.run_particle_filter(init_with_rng, joinpath(@__DIR__, "integration_test_4.yaml"), BootstrapFilter())
h5write(reference_file, "integration_test_4", x_avg)
