using ParticleDA
using TimerOutputs
using MPI

# Initialise MPI
MPI.Init()
mpi_size = MPI.Comm_size(MPI.COMM_WORLD)

# Save some variables for later use
test_dir = joinpath(dirname(pathof(ParticleDA)), "..", "test")
llw2d_src = joinpath(test_dir, "models", "llw2d.jl")
observation_file = "observations.h5"

# Instantiate the test environment
using Pkg
Pkg.activate(test_dir)
Pkg.instantiate()

# Include the sample model source code and load it
include(llw2d_src)
using .LLW2d

input_dict = ParticleDA.read_input_file("parametersW1.yaml")
run_custom_params = Dict(input_dict)

# Real run
TimerOutputs.enable_debug_timings(ParticleDA)
run_custom_params["model"]["llw2d"]["padding"] = 0
run_custom_params["filter"]["verbose"] = true
run_custom_params["filter"]["enable_timers"] = true
run_custom_params["filter"]["output_filename"] = string("weak_scaling_r", mpi_size, ".h5")
run_custom_params["filter"]["nprt"] = mpi_size * 40

# Run the (optimal proposal) particle filter with simulated observations computing the
# mean and variance of the particle ensemble. On non-Intel architectures you may need
# to use NaiveMeanAndVarSummaryStat instead
final_states, final_statistics = run_particle_filter(
  LLW2d.init, run_custom_params, observation_file, OptimalFilter, ParticleDA.NaiveMeanSummaryStat
)

