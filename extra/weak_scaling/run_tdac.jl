using TDAC
using TimerOutputs
using MPI

MPI.Init()
mpi_size = MPI.Comm_size(MPI.COMM_WORLD)

# Warmup run
warmup_custom_params = Dict(
    "nobs"=>4,
    "padding"=>0,
    "n_time_step"=>1,
    "n_integration_step"=>1,
    "time_step"=>0.1,
    "nprt"=>mpi_size)
warmup_params = TDAC.get_params(warmup_custom_params)
TDAC.tdac(warmup_params)

# Real run
TimerOutputs.enable_debug_timings(TDAC)
custom_params = Dict(
    "nobs"=>64,
    "verbose"=>true,
    "enable_timers"=>true,
    "padding"=>0,
    "output_filename"=>string("weak_scaling_r",mpi_size,".h5"),
    "nprt"=>mpi_size * 64)
params = TDAC.get_params(custom_params)
TDAC.tdac(params)
