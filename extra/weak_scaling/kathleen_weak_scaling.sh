#!/bin/bash -l

# Batch script to run a hybrid parallel job under SGE.

# Request wallclock time (format hours:minutes:seconds).
#$ -l h_rt=0:20:0

# Request RAM per core (must be an integer)
#$ -l mem=4G

# Set the name of the job.
#$ -N ParticleDAScaling

# Select the MPI parallel environment and no. cores.
#$ -pe mpi 160

# Set the working directory to somewhere in your scratch space. 
# This directory must exist.
#$ -wd /home/ccaemgr/Scratch/ParticleDA.jl/extra/weak_scaling

module load julia/1.9.0

# Automatically set threads using ppn
export OMP_NUM_THREADS=$(ppn)
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

# Run our MPI job with the default modules. Gerun is a wrapper script for mpirun. 
mpiexecjl -n $NHOSTS julia --project=. /home/ccaemgr/Scratch/ParticleDA.jl/extra/weak_scaling/run_particleda.jl
