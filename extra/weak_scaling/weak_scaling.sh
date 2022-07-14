#!/bin/bash -l

# Add scheduler commands here if running on a HPC system


# Set the number of threads. Since the number of threads
# is limited by the number of cores per node, I've kept
# the number of threads fixed and varied the number of
# ranks below. In the past I've used 4 threads but theoretically
# this can go up to number of particles per rank, which is set
# in parametersW1.yaml. For good performance you probably
# want a larger number of particles per thread.
export OMP_NUM_THREADS=1
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

rm -f weak_scaling_r*.h5

# Update the number of ranks in the list to what is required.
# In the past we've run up to 256 ranks on CSD3
for ranks in 1 2 4
do
    mpirun -np $ranks julia run_particleda.jl
done

