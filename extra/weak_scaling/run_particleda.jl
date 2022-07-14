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

# Instantiate the test environment
using Pkg
Pkg.activate(test_dir)
Pkg.instantiate()

# Include the sample model source code and load it
include(module_src)
using .Model

input_dict = ParticleDA.read_input_file("parametersW1.yaml")
warmup_custom_params = Dict(input_dict)

# Warmup run
warmup_custom_params["model"]["llw2d"]["nobs"]=4
warmup_custom_params["model"]["llw2d"]["station_filename"]=""
warmup_custom_params["model"]["llw2d"]["padding"]=0
warmup_custom_params["model"]["llw2d"]["n_integration_step"]=1
warmup_custom_params["model"]["llw2d"]["time_step"]=0.1
warmup_custom_params["filter"]["n_time_step"]=1
warmup_custom_params["filter"]["nprt"]=mpi_size
warmup_custom_params["filter"]["verbose"]=false
warmup_custom_params["filter"]["enable_timers"]=false
ParticleDA.run_particle_filter(Model.init, warmup_custom_params, BootstrapFilter())

input_dict = ParticleDA.read_input_file("parametersW1.yaml")
run_custom_params = Dict(input_dict)

# Real run
TimerOutputs.enable_debug_timings(ParticleDA)

run_custom_params["model"]["llw2d"]["padding"]=0
run_custom_params["filter"]["nprt"]=mpi_size
run_custom_params["filter"]["verbose"]=true
run_custom_params["filter"]["enable_timers"]=true
run_custom_params["filter"]["output_filename"]=string("weak_scaling_r",mpi_size,".h5")
run_custom_params["filter"]["nprt"]=mpi_size * 64
ParticleDA.run_particle_filter(Model.init, run_custom_params, BootstrapFilter())
