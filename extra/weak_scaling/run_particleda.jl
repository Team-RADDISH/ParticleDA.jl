using ParticleDA
using TimerOutputs
using MPI
using ThreadPinning

# Initialise MPI
MPI.Init()
comm = MPI.COMM_WORLD
mpi_size = MPI.Comm_size(comm)
my_rank = MPI.Comm_rank(comm)

cores_per_numa = 16
threads_per_rank = Threads.nthreads()
ranks_per_numa = div(cores_per_numa, threads_per_rank)

# Pin threads so that threads of a MPI rank will be pinned to cores with
# contiguous IDs. This will ensure that
#  - When running 16 or less threads per rank, all threads will be pinned to the same
#    NUMA region as their master (sharing a memory controller within Infinity fabric)
#  - When running 8 or less threads per rank, all threads will be pinned to the same
#    Core Complex Die
#  - When running 4 or less threads per rank, all threads will be pinned to the same
#    Core Complex (sharing a L3 cache)

my_numa, my_id_in_numa = divrem(my_rank, ranks_per_numa) .+ (1, 0)
pinthreads( numa( my_numa, 1:Threads.nthreads() ) .+ threads_per_rank .* my_id_in_numa )

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
run_custom_params["model"]["llw2d"]["padding"]=0
run_custom_params["filter"]["verbose"]=true
run_custom_params["filter"]["enable_timers"]=true
run_custom_params["filter"]["output_filename"]=string("weak_scaling_r",mpi_size,".h5")
run_custom_params["filter"]["nprt"]=mpi_size * 2048

# Run the (optimal proposal) particle filter with simulated observations computing the
# mean and variance of the particle ensemble. On non-Intel architectures you may need
# to use NaiveMeanAndVarSummaryStat instead
final_states, final_statistics = run_particle_filter(
  LLW2d.init, run_custom_params, observation_file, OptimalFilter, ParticleDA.NaiveMeanSummaryStat
)

