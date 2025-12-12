# Weak Scaling

This directory contains

- Julia script `run_particleda.jl` that runs the particle filter using parameters in `parametersW1.yaml`
- Batch script `kathleen_slurm_weak_scaling.sh` that runs a weak scaling experiment on a slurm-based HPC system. It has been used on the UCL Kathleen cluster but should be adaptable with minor modifications to other clusters.
- Julia script `optimized_copy_states.jl` that runs a number of performance tests on the `copy_states` function.
- Batch script `kathleen_slurm_copy_states.sh` that runs the tests on the parallel performance of the `copy_states` function done in Chenge Sun's Master's thesis to demonstrate optimisations to the algorithm.
