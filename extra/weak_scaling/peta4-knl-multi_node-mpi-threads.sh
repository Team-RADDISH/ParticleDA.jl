#!/bin/bash
#SBATCH -J scaling_test.jl
#SBATCH -A T2-CS097-KNL
#SBATCH --nodes=16
#SBATCH --ntasks=256
#SBATCH --time=12:00:00
#SBATCH -p knl
#SBATCH --constraint=cache

module purge
module load rhel7/default-peta4   
module load julia/1.4
module load hdf5/impi

#! Work directory (i.e. where the job will run):
workdir="$SLURM_SUBMIT_DIR"  # The value of SLURM_SUBMIT_DIR sets workdir to the directory
                             # in which sbatch is run.

export OMP_NUM_THREADS=4
export JULIA_NUM_THREADS=$OMP_NUM_THREADS


rm -f weak_scaling_r*.h5

for ranks in 16 32 64 128 256
do
    awk '/nprt/ {sub($2, '$ranks'*256)}1' input.yaml > /tmp/input.yaml
    awk '/output_filename/ {sub($2, "weak_scaling_r'$ranks'_t4.h5")}1' /tmp/input.yaml > input_weak_scaling.yaml
    srun -n $ranks julia run_tdac.jl
done

