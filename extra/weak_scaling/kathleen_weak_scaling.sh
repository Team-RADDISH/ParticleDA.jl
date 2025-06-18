#!/bin/bash -l

# Batch script to run a hybrid parallel job under SGE.

# Request wallclock time (format hours:minutes:seconds).
#$ -l h_rt=0:10:0

# Request RAM per core (must be an integer)
#$ -l mem=4G

# Set the name of the job.
#$ -N ParticleDAScaling

# Select the MPI parallel environment and no. cores.
#$ -pe mpi 160

# Set the working directory to somewhere in your scratch space. 
# This directory must exist.
#$ -wd /home/ucabc46/ParticleDA.jl/extra/weak_scaling

module load julia/1.8.5
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.add("MPI"); Pkg.add("TimerOutputs"); Pkg.add("LinearAlgebra"); Pkg.add("HDF5"); Pkg.add("GaussianRandomFields")'

# Automatically set threads using ppn
export OMP_NUM_THREADS=$(ppn)
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

# /home/ucabc46/.julia/bin/mpiexecjl -n 1 julia --project=. /home/ucabc46/ParticleDA.jl/extra/weak_scaling/run_particleda.jl
/home/ucabc46/.julia/bin/mpiexecjl -n $NHOSTS julia --project=. /home/ucabc46/ParticleDA.jl/extra/weak_scaling/run_particleda.jl