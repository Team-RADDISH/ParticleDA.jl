using ParticleDA
using LinearAlgebra
using TimerOutputs
using MPI
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

observation_file = "test_observations_$(mpi_size)_ranks.h5"
base_parameters_file = "parametersW1.yaml"
parameters_file = "parameters_$(mpi_size)_ranks.yaml"
output_file = "llw2d_filtering_$(mpi_size)_ranks.h5"
filter_type = BootstrapFilter
summary_stat_type = NaiveMeanSummaryStat

my_rank = MPI.Comm_rank(MPI.COMM_WORLD)

if my_rank == 0
    println("# MPI ranks $(mpi_size), # Julia threads = $(Threads.nthreads()), # BLAS threads = $(BLAS.get_num_threads())")
    input_dict = YAML.load_file(base_parameters_file)
    input_dict["filter"]["output_filename"] = output_file
    input_dict["configuration"] = Dict(
        "num_ranks" => mpi_size,
        "num_threads_per_rank" => Threads.nthreads(),
        "filter_type" => string(filter_type),
        "summary_stat_type" => string(summary_stat_type)
    )
    YAML.write_file(parameters_file, input_dict)
end

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

final_states, final_statistics = run_particle_filter(
  LLW2d.init, parameters_file, observation_file, filter_type, summary_stat_type
)
