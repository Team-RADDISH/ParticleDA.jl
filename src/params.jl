module Params

export g0, nx, ny, nobs, dx, dy, dt, dim_state_vector, title_da, title_syn, rr, ntmax, ntdec, nprt, da_period

## Parameters

const g0 = 9.80665 #  Gravity Constant

# finite differnce method parametrs
const nx = 200  # grid number (NS)
const ny = 200  # grid number (EW)
const nobs = 4   # Number of stations
const dx = 2000 # grid width of x-direction (m)
const dy = 2000 # grid width of y-direction (m)
const dt = 1    # time step width (sec)

# model sizes
const dim_state_vector    = 3 * nx * ny

const title_da  = "da"  # output file title
const title_syn = "syn" # output file title for synthetic data

# control parameters for optimum interpolations: See document
const rr = 20000 # Cutoff distance of error covariance (m)

const ntmax = 500  # Number of time steps

# visualization
const ntdec = 50 # decimation factor for visualization
#const ntdec = ntmax # decimation factor for visualization

# particle filter
const nprt = 4 # number of particles
const da_period = 50 # length of data assimilation steps (in time steps)


end # module
