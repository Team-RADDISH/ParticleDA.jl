#!/bin/bash -l
#SBATCH --job-name=ParticleDAScaling
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=40
#SBATCH --chdir=/home/ucabc46/exp/ParticleDA.jl
#SBATCH --output=slurm_log/%x-%j.out
#SBATCH --error=slurm_log/%x-%j.err

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

/home/ucabc46/.julia/bin/mpiexecjl -n $SLURM_NNODES\
     julia --project=. \
     /home/ucabc46/exp/ParticleDA.jl/extra/weak_scaling/run_particleda.jl -o