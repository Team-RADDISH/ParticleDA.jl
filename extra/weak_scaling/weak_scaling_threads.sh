#!/bin/bash
# Slurm job options (job-name, compute nodes, job time)
#SBATCH --job-name=scaling
#SBATCH --time=01:00:00

#SBATCH --nodes=16
#SBATCH --tasks-per-node=8
#SBATCH --cpus-per-task=16

#SBATCH --qos=lowpriority

#SBATCH --account=e723-dangiles
#SBATCH --partition=standard

# Setup the job environment (this module needs to be loaded before any other modules)
module load PrgEnv-cray
module load cray-mpich/8.1.4

# Define some paths
export WORK=/work/e723/e723/dangiles

export JULIA="$WORK/julia-1.7.3/bin/julia"  # The julia executable
export PATH="$PATH:$WORK/julia-1.7.3/bin"  # The folder of the julia executable
export JULIA_DEPOT_PATH="$WORK/.julia"
export MPIEXECJL="$JULIA_DEPOT_PATH/bin/mpiexecjl"  # The path to the mpiexexjl executable
export PATH="$PATH:$WORK/.julia/packages"


# Set the number of threads. Since the number of threads
# is limited by the number of cores per node, I've kept
# the number of threads fixed and varied the number of
# ranks below. In the past I've used 4 threads but theoretically
# this can go up to number of particles per rank, which is set
# in parametersW1.yaml. For good performance you probably
# want a larger number of particles per thread.
export OMP_NUM_THREADS=16
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

rm -f weak_scaling_r*.h5

# Update the number of ranks in the list to what is required.
# In the past we've run up to 256 ranks on CSD3
for ranks in 128 64 32 16 8 4 2 1 
do
    let num_nodes=$ranks/8
    if [ $num_nodes -lt 1 ]
    then
	 let num_nodes=1
    fi
    echo $num_nodes
    $MPIEXECJL --nodes=$num_nodes -n $ranks $JULIA ./run_particleda.jl
done

