using ParticleDA, MPI

include(joinpath(@__DIR__, "model", "model.jl"))
using .Model

# Initialise MPI
MPI.Init()

# Get the number or ranks, so that we can set a number of particle as an integer
# multiple of them.
my_size = MPI.Comm_size(MPI.COMM_WORLD)

params = Dict(
    "filter" => Dict(
        "nprt" => my_size,
        "enable_timers" => true,
        "verbose"=> false,
        "n_time_step" => 5,
        "output_filename" => "warmup.h5",
    ),
    "model" => Dict(
        "llw2d" => Dict(
            "nx" => 20,
            "ny" => 20,
            "nobs" => 4,
            "padding" => 0,
        ),
    ),
)

# Warmup
run_particle_filter(Model.init, params, BootstrapFilter())
# Flush a newline
println()

# Run the command
params["filter"]["output_filename"] = "bootstrap_filter.h5"
params["filter"]["verbose"] = true
params["filter"]["nprt"] = 2 * my_size
params["model"]["llw2d"]["nobs"] = 36
run_particle_filter(Model.init, params, BootstrapFilter())
# Flush a newline
println()

# Run the command
params["filter"]["output_filename"] = "optimal_filter.h5"
run_particle_filter(Model.init, params, OptimalFilter())
# Flush a newline
println()
