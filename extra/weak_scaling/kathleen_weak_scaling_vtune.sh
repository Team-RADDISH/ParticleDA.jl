#!/bin/bash -l
#------------------------------------------------------------
#  ParticleDA weak-scaling + VTune (user-mode hotspots)
#------------------------------------------------------------
#$ -l h_rt=0:10:0
#$ -l mem=4G
#$ -N ParticleDAScaling
#$ -pe mpi 160
#$ -wd /home/ucabc46/ParticleDA.jl/extra/weak_scaling
#------------------------------------------------------------

module purge
module load julia/1.8.5
module load compilers/intel/2024.0.1

julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.add("MPI"); Pkg.add("TimerOutputs"); Pkg.add("LinearAlgebra"); Pkg.add("HDF5"); Pkg.add("GaussianRandomFields"); Pkg.add("PDMats")'

#------------------------------------------------------------
export OMP_NUM_THREADS=40
export JULIA_NUM_THREADS=$OMP_NUM_THREADS

#------------------------------------------------------------
export TMPDIR=$SGE_O_WORKDIR/tmp_rank${rank}
export VTUNE_TMP=$TMPDIR

#------------------------------------------------------------
/home/ucabc46/.julia/bin/mpiexecjl -n $NHOSTS \
  amplxe-cl -collect hotspots -r vtune_mpi_hotspots \
  -- julia --project=. \
  /home/ucabc46/ParticleDA.jl/extra/weak_scaling/run_particleda.jl

# /home/ucabc46/.julia/bin/mpiexecjl -n 1 \
#   amplxe-cl -collect hotspots -r vtune_mpi_hotspots_1rank \
#   -- julia --project=. \
#   /home/ucabc46/ParticleDA.jl/extra/weak_scaling/run_particleda.jl

