# Grid parametrs
const nx = 200   # grid size (NS)
const ny = 200   # grid size (EW)
const nobs = 4   # Number of stations
const dx = 2.0e3 # grid cell width of x-direction (m)
const dy = 2.0e3 # grid cell width of y-direction (m)
const station_separation = 20
const station_boundary = 150
const station_dx = 1.0e3
const station_dy = 1.0e3


# Run parameters
const dt = 1.0    # time step (sec)
const ntmax = 500 # Number of time steps

# Output parameters
const title_da  = "da"  # output file title
const title_syn = "syn" # output file title for synthetic data
const ntdec = 50        # decimation factor for visualization

# Data assimilation parameters
const nprt = 4       # number of particles
const da_period = 50 # length of data assimilation steps (in time steps)
const rr = 2.0e4     # Cutoff distance of error covariance (m)
