using ParticleDA
using TimerOutputs
using MPI

MPI.Init()
mpi_size = MPI.Comm_size(MPI.COMM_WORLD)

test_dir = joinpath(dirname(pathof(ParticleDA)), "..", "test")
module_src = joinpath(test_dir, "model", "model.jl")

include(module_src)
using .Model

# Warmup run
warmup_custom_filter_params = Dict(
    "n_time_step"=>1,
    "nprt"=>mpi_size)
warmup_custom_llw2d_params = Dict(
    "nobs"=>4,
    "n_integration_step"=>1,
    "time_step"=>0.1,
    "padding"=>0)
warmup_custom_params = Dict(
    "filter" => warmup_custom_filter_params,
    "model" => Dict("llw2d" => warmup_custom_llw2d_params))

ParticleDA.run_particle_filter(Model.init, warmup_custom_params,ParticleDA.BootstrapFilter())

# Real run
TimerOutputs.enable_debug_timings(ParticleDA)
custom_filter_params = Dict(
    "verbose"=>true,
    "enable_timers"=>true,
    "output_filename"=>string("weak_scaling_r",mpi_size,".h5"),
    "nprt"=>mpi_size * 64)
custom_llw2d_params = Dict(
    "nobs"=>64,
    "padding"=>0)
custom_params = Dict(
    "filter" => custom_filter_params,
    "model" => Dict("llw2d" => custom_llw2d_params))

ParticleDA.run_particle_filter(Model.init,custom_params,ParticleDA.BootstrapFilter())
