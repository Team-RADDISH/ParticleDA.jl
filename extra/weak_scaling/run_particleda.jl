using ParticleDA
using TimerOutputs
using MPI
using LinearAlgebra
using YAML

# Verify BLAS implementation is OpenBLAS
@assert occursin("openblas", string(BLAS.get_config()))

# Set size of thread pool for BLAS operations to 1
BLAS.set_num_threads(1)

# Initialise MPI
MPI.Init()
mpi_size = MPI.Comm_size(MPI.COMM_WORLD)

# Include the sample model source code and load it
llw2d_src = joinpath(dirname(pathof(ParticleDA)), "..", "test", "models", "llw2d.jl")
include(llw2d_src)
using .LLW2d
observation_file = joinpath(dirname(pathof(ParticleDA)), "..", "extra", "weak_scaling", "test_observations.h5")
parameters_file = joinpath(dirname(pathof(ParticleDA)), "..", "extra", "weak_scaling", "parametersW1.yaml")
output_file = joinpath(dirname(pathof(ParticleDA)), "..", "extra", "weak_scaling", "llw2d_filtering.h5")
#filter_type = OptimalFilter
filter_type = BootstrapFilter
summary_stat_type = NaiveMeanSummaryStat

my_rank = MPI.Comm_rank(MPI.COMM_WORLD)

println("Rank $(my_rank): # Julia threads = $(Threads.nthreads()), # BLAS threads = $(BLAS.get_num_threads())")

if my_rank == 0 && !isfile(observation_file)
    observation_sequence = simulate_observations_from_model(
      LLW2d.init, parameters_file, observation_file
    )
end
if my_rank == 0 && isfile(output_file)
    rm(output_file)
end

MPI.Barrier(MPI.COMM_WORLD)

TimerOutputs.enable_debug_timings(ParticleDA)
optimize = "-o" in ARGS || "--optimize-copy-states" in ARGS
println("Optimized copy states enabled: ", optimize)

# update parameters to enable weak scaling
parameters = YAML.load_file(parameters_file)
parameters["filter"]["nprt"] = mpi_size * 1000
open(parameters_file, "w") do io
    YAML.write(io, parameters)
end

final_states, final_statistics = run_particle_filter(
  LLW2d.init, parameters_file, observation_file, filter_type, summary_stat_type, optimize_copy_states=optimize
)
