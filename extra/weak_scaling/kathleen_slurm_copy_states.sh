#!/bin/bash -l
#SBATCH --job-name=ParticleDAScaling
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=40
#SBATCH --nodes=16
#SBATCH --ntasks-per-node=1
#SBATCH --chdir=/home/ucabc46/exp/ParticleDA.jl
#SBATCH --output=test/slurm_log/%x-%j.out
#SBATCH --error=test/slurm_log/%x-%j.err

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

/home/ucabc46/.julia/bin/mpiexecjl -n $SLURM_NNODES\
     julia --project=. \
     /home/ucabc46/exp/ParticleDA.jl/test/mpi_copy_states.jl -t /home/ucabc46/exp/ParticleDA.jl/test/output/all_timers_$SLURM_NNODES.h5 -d