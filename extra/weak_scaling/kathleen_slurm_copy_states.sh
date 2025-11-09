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

PARTICLEDA_WEAKSCALING_DIR=$HOME/ParticleDA.jl/extra/weak_scaling
RESULTS_DIR=$PARTICLEDA_WEAKSCALING_DIR/output
mkdir -p $RESULTS_DIR
JULIA_DIR=$HOME/.julia

cd $PARTICLEDA_WEAKSCALING_DIR

$JULIA_DIR/bin/mpiexecjl -n $SLURM_NNODES\
     julia --project=. \
     $PARTICLEDA_WEAKSCALING_DIR/optimized_copy_states.jl -t $RESULTS_DIR/all_timers_$SLURM_NNODES.h5 -o