#!/bin/bash -l
#SBATCH --job-name=ParticleDAScaling
#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=4G
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=40
#SBATCH --chdir=/home/ucabc46/ParticleDA.jl/extra/weak_scaling
#SBATCH --output=slurm_log/%x-%j.out
#SBATCH --error=slurm_log/%x-%j.err


# julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.add.(["MPI","TimerOutputs","LinearAlgebra","HDF5","GaussianRandomFields"])'

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

/home/ucabc46/.julia/bin/mpiexecjl \
     julia --project=. \
     /home/ucabc46/ParticleDA.jl/extra/weak_scaling/run_particleda.jl