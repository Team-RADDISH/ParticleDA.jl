#!/bin/bash -l
#SBATCH --job-name=ParticleDAScaling
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=40
#SBATCH --nodes=16
#SBATCH --ntasks-per-node=1
#SBATCH --output=slurm_log/%x-%j.out
#SBATCH --error=slurm_log/%x-%j.err

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

PARTICLEDA_TEST_DIR=$HOME/ParticleDA.jl/test
RESULTS_DIR=$PARTICLEDA_TEST_DIR/output
mkdir -p $RESULTS_DIR
JULIA_DIR=$HOME/.julia

$JULIA_DIR/bin/mpiexecjl -n $SLURM_NNODES\
     julia --project=. \
     $PARTICLEDA_TEST_DIR/mpi_optimized_copy_states.jl -t $RESULTS_DIR/all_timers_$SLURM_NNODES.h5 -o