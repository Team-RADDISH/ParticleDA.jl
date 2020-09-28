using ParticleDA, MPI

# Initialise MPI
MPI.Init()

# Define a convenience method to easily replace some parametres
function (p::ParticleDA.Parameters)(; kwargs...)
    # Extract parameters of the input instance
    fields = Dict(name => getfield(p, name) for name in fieldnames(typeof(p)))
    for (k, v) in kwargs
        # Replace the fields with the new values
        fields[k] = v
    end
    # Return the new instance
    return ParticleDA.Parameters(; fields...)
end

# Get the number or ranks, so that we can set a number of particle as an integer
# multiple of them.
my_size = MPI.Comm_size(MPI.COMM_WORLD)

params = ParticleDA.Parameters(; nprt = my_size, nobs = 4, padding = 0, enable_timers = true,
                               verbose = true, n_time_step = 5, nx = 20, ny = 20)

# Warmup
rm("particle_da.h5"; force = true)
run_particle_filter(params)
# Flush a newline
println()

# Run the command
rm("particle_da.h5"; force = true)
run_particle_filter(params(; nprt = 2 * my_size, nobs = 36))
# Flush a newline
println()
