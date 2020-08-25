using TDAC, FFTW, MPI

# Disable FFTW threads
FFTW.set_num_threads(1)

# Initialise MPI
MPI.Init()

# Define a convenience method to easily replace some parametres
function (p::TDAC.Parameters)(; kwargs...)
    # Extract parameters of the input instance
    fields = Dict(name => getfield(p, name) for name in fieldnames(typeof(p)))
    for (k, v) in kwargs
        # Replace the fields with the new values
        fields[k] = v
    end
    # Return the new instance
    return TDAC.Parameters(; fields...)
end

# Get the number or ranks, so that we can set a number of particle as an integer
# multiple of them.
my_size = MPI.Comm_size(MPI.COMM_WORLD)

params = TDAC.Parameters(; nprt = my_size, nobs = 4, padding = 0, enable_timers = true,
                          verbose = true, n_time_step = 5, nx = 20, ny = 20)

# Warmup
rm("tdac.h5"; force = true)
tdac(params)
# Flush a newline
println()

# Run the command
rm("tdac.h5"; force = true)
tdac(params(; nprt = 2 * my_size, nobs = 36))
# Flush a newline
println()
