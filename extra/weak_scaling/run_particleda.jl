using ParticleDA
using TimerOutputs
using MPI

# Initialise MPI
MPI.Init()
mpi_size = MPI.Comm_size(MPI.COMM_WORLD)

# Save some variables for later use
test_dir = joinpath(dirname(pathof(ParticleDA)), "..", "test")
module_src = joinpath(test_dir, "model", "model.jl")
input_file = joinpath(test_dir, "integration_test_1.yaml")
truth_file = "test_observations.h5"
# Instantiate the test environment
using Pkg
Pkg.activate(test_dir)
Pkg.instantiate()

# Include the sample model source code and load it
include(module_src)
using .Model

input_dict = ParticleDA.read_input_file("parametersW1.yaml")
run_custom_params = Dict(input_dict)

# Real run
TimerOutputs.enable_debug_timings(ParticleDA)

run_custom_params["model"]["llw2d"]["padding"]=0
run_custom_params["filter"]["verbose"]=true
run_custom_params["filter"]["enable_timers"]=true
run_custom_params["filter"]["output_filename"]=string("weak_scaling_r",mpi_size,".h5")
run_custom_params["filter"]["nprt"]=mpi_size * 64
ParticleDA.run_particle_filter(Model.init, run_custom_params, BootstrapFilter(), truth_file)
