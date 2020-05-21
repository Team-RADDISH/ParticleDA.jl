using TDAC, FFTW, MPI

# Disable FFTW threads
FFTW.set_num_threads(1)

# Initialise MPI
MPI.Init()

# Get the number or ranks, so that we can set a number of particle as an integer
# multiple of them.
my_size = MPI.Comm_size(MPI.COMM_WORLD)

# Warmup
rm("tdac.h5"; force = true)
tdac(TDAC.tdac_params(; nprt = my_size, nobs = 4, padding = 0, enable_timers = true, verbose = true))
# Flush a newline
println()

# Run the command
rm("tdac.h5"; force = true)
tdac(TDAC.tdac_params(; nprt = 2 * my_size, nobs = 36, padding = 0, enable_timers = true, verbose = true))
# Flush a newline
println()
