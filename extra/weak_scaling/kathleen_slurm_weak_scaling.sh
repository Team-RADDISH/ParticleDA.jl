#!/bin/bash -l
#SBATCH --job-name=ParticleDAScaling
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=40
#SBATCH --chdir=/home/ucabc46/ParticleDA.jl/extra/weak_scaling
#SBATCH --output=slurm_log/%x-%j.out
#SBATCH --error=slurm_log/%x-%j.err

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

PARTICLEDA_WEAKSCALING_DIR=$HOME/ParticleDA.jl/extra/weak_scaling
JULIA_DIR=$HOME/.julia

$JULIA_DIR/bin/mpiexecjl -n $SLURM_NNODES\
     julia --project=. \
     $PARTICLEDA_WEAKSCALING_DIR/run_particleda.jl