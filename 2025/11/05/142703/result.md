# Benchmark result

* Pull request commit: [`d90d2eb2242942eaabab295a53e1d5236e5b15c9`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/d90d2eb2242942eaabab295a53e1d5236e5b15c9)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/299> (Run benchmarks using Julia v1.11)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 5 Nov 2025 - 14:16
    - Baseline: 5 Nov 2025 - 14:26
* Package commits:
    - Target: 2f8795c
    - Baseline: e314fbd
* Julia commits:
    - Target: f2b3dbd
    - Baseline: f2b3dbd
* Julia command flags:
    - Target: None
    - Baseline: None
* Environment variables:
    - Target: `JULIA_NUM_THREADS => 2`
    - Baseline: `JULIA_NUM_THREADS => 2`

## Results
A ratio greater than `1.0` denotes a possible regression (marked with :x:), while a ratio less
than `1.0` denotes a possible improvement (marked with :white_check_mark:). Brackets display [tolerances](https://juliaci.github.io/BenchmarkTools.jl/stable/manual/#Benchmark-Parameters) for the benchmark estimates. Only significant results - results
that indicate possible regressions or improvements - are shown below (thus, an empty table means that all
benchmark results remained invariant between builds).

| ID                                                                                                        | time ratio                   | memory ratio |
|-----------------------------------------------------------------------------------------------------------|------------------------------|--------------|
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |                1.10 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      |                1.36 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 | 0.90 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            |                1.13 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 0.90 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        |                1.19 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |                1.10 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              |                1.22 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   |                1.06 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         |                1.20 (5%) :x: |   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)"]`
- `["Filtering (BootstrapFilter, MeanSummaryStat)"]`
- `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)"]`
- `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)"]`
- `["Filtering (OptimalFilter, MeanAndVarSummaryStat)"]`
- `["Filtering (OptimalFilter, MeanSummaryStat)"]`
- `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)"]`
- `["Filtering (OptimalFilter, NaiveMeanSummaryStat)"]`
- `["Model interface"]`

## Julia versioninfo

### Target
```
Julia Version 1.11.7
Commit f2b3dbda30a (2025-09-08 12:10 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 24.04.3 LTS
  uname: Linux 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1     0 MHz       3632 s          0 s        141 s       7581 s          0 s
       #2     0 MHz       2999 s          0 s        133 s       8218 s          0 s
       #3     0 MHz       3561 s          0 s        142 s       7658 s          0 s
       #4     0 MHz       4278 s          0 s        132 s       6948 s          0 s
  Memory: 15.620677947998047 GB (13314.25 MB free)
  Uptime: 1138.83 sec
  Load Avg:  1.79  1.58  1.05
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

### Baseline
```
Julia Version 1.11.7
Commit f2b3dbda30a (2025-09-08 12:10 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 24.04.3 LTS
  uname: Linux 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1     0 MHz       5802 s          0 s        169 s      11628 s          0 s
       #2     0 MHz       4989 s          0 s        156 s      12453 s          0 s
       #3     0 MHz       6126 s          0 s        200 s      11286 s          0 s
       #4     0 MHz       7227 s          0 s        180 s      10202 s          0 s
  Memory: 15.620677947998047 GB (13641.48828125 MB free)
  Uptime: 1764.34 sec
  Load Avg:  1.82  1.59  1.28
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 14:16
* Package commit: 2f8795c
* Julia commit: f2b3dbd
* Julia command flags: None
* Environment variables: `JULIA_NUM_THREADS => 2`

## Results
Below is a table of this job's results, obtained by running the benchmarks.
The values listed in the `ID` column have the structure `[parent_group, child_group, ..., key]`, and can be used to
index into the BaseBenchmarks suite to retrieve the corresponding benchmarks.
The percentages accompanying time and memory values in the below table are noise tolerances. The "true"
time/memory value for a given benchmark is expected to fall within this percentage of the reported value.
An empty cell means that the value was zero.

| ID                                                                                                        | time            | GC time    | memory          | allocations |
|-----------------------------------------------------------------------------------------------------------|----------------:|-----------:|----------------:|------------:|
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.132 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    9.411 s (5%) |   2.551 ms | 438.57 MiB (1%) |    12013509 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 415.982 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.739 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    7.373 s (5%) | 191.854 ms | 205.88 MiB (1%) |     1929786 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 365.947 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.267 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    7.905 s (5%) |  17.473 ms | 207.86 MiB (1%) |     1933441 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 373.357 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.844 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    7.652 s (5%) |  11.995 ms | 205.97 MiB (1%) |     1930803 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 314.599 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.121 s (5%) | 273.586 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.785 s (5%) | 529.265 ms |   3.48 GiB (1%) |    60748401 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 392.782 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.089 s (5%) | 271.257 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   13.777 s (5%) | 495.648 ms |   3.25 GiB (1%) |    50665473 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 487.299 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.063 s (5%) | 270.895 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.550 s (5%) | 435.669 ms |   3.26 GiB (1%) |    50668323 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 426.034 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.080 s (5%) | 266.991 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   12.476 s (5%) | 441.289 ms |   3.25 GiB (1%) |    50665429 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 495.291 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.259 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.157 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.068 s (5%) | 271.704 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.514 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  87.057 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.199 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.787 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 369.806 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  13.036 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.375 ms (5%) |            |   48 bytes (1%) |           1 |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)"]`
- `["Filtering (BootstrapFilter, MeanSummaryStat)"]`
- `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)"]`
- `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)"]`
- `["Filtering (OptimalFilter, MeanAndVarSummaryStat)"]`
- `["Filtering (OptimalFilter, MeanSummaryStat)"]`
- `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)"]`
- `["Filtering (OptimalFilter, NaiveMeanSummaryStat)"]`
- `["Model interface"]`

## Julia versioninfo
```
Julia Version 1.11.7
Commit f2b3dbda30a (2025-09-08 12:10 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 24.04.3 LTS
  uname: Linux 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1     0 MHz       3632 s          0 s        141 s       7581 s          0 s
       #2     0 MHz       2999 s          0 s        133 s       8218 s          0 s
       #3     0 MHz       3561 s          0 s        142 s       7658 s          0 s
       #4     0 MHz       4278 s          0 s        132 s       6948 s          0 s
  Memory: 15.620677947998047 GB (13314.25 MB free)
  Uptime: 1138.83 sec
  Load Avg:  1.79  1.58  1.05
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 14:26
* Package commit: e314fbd
* Julia commit: f2b3dbd
* Julia command flags: None
* Environment variables: `JULIA_NUM_THREADS => 2`

## Results
Below is a table of this job's results, obtained by running the benchmarks.
The values listed in the `ID` column have the structure `[parent_group, child_group, ..., key]`, and can be used to
index into the BaseBenchmarks suite to retrieve the corresponding benchmarks.
The percentages accompanying time and memory values in the below table are noise tolerances. The "true"
time/memory value for a given benchmark is expected to fall within this percentage of the reported value.
An empty cell means that the value was zero.

| ID                                                                                                        | time            | GC time    | memory          | allocations |
|-----------------------------------------------------------------------------------------------------------|----------------:|-----------:|----------------:|------------:|
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.302 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    8.528 s (5%) | 182.829 ms | 438.57 MiB (1%) |    12013506 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 306.568 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.638 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    8.193 s (5%) |  13.595 ms | 205.88 MiB (1%) |     1929786 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 324.961 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.227 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    7.790 s (5%) | 182.292 ms | 207.86 MiB (1%) |     1933441 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 356.376 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.504 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    7.524 s (5%) | 187.258 ms | 205.97 MiB (1%) |     1930800 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 350.480 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.087 s (5%) | 255.445 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.694 s (5%) | 493.830 ms |   3.48 GiB (1%) |    60748416 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 331.374 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.069 s (5%) | 261.241 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   12.547 s (5%) | 431.815 ms |   3.25 GiB (1%) |    50665553 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 400.719 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.077 s (5%) | 262.638 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.619 s (5%) | 435.580 ms |   3.26 GiB (1%) |    50668182 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 403.684 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.057 s (5%) | 256.616 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   12.109 s (5%) | 438.807 ms |   3.25 GiB (1%) |    50665428 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 413.791 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.232 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.187 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.067 s (5%) | 251.829 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.487 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  88.394 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.137 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.742 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 363.657 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.927 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.335 ms (5%) |            |   48 bytes (1%) |           1 |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)"]`
- `["Filtering (BootstrapFilter, MeanSummaryStat)"]`
- `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)"]`
- `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)"]`
- `["Filtering (OptimalFilter, MeanAndVarSummaryStat)"]`
- `["Filtering (OptimalFilter, MeanSummaryStat)"]`
- `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)"]`
- `["Filtering (OptimalFilter, NaiveMeanSummaryStat)"]`
- `["Model interface"]`

## Julia versioninfo
```
Julia Version 1.11.7
Commit f2b3dbda30a (2025-09-08 12:10 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 24.04.3 LTS
  uname: Linux 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1     0 MHz       5802 s          0 s        169 s      11628 s          0 s
       #2     0 MHz       4989 s          0 s        156 s      12453 s          0 s
       #3     0 MHz       6126 s          0 s        200 s      11286 s          0 s
       #4     0 MHz       7227 s          0 s        180 s      10202 s          0 s
  Memory: 15.620677947998047 GB (13641.48828125 MB free)
  Uptime: 1764.34 sec
  Load Avg:  1.82  1.59  1.28
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Runtime information
| Runtime Info | |
|:--|:--|
| BLAS #threads | 2 |
| `BLAS.vendor()` | `lbt` |
| `Sys.CPU_THREADS` | 4 |

`lscpu` output:

    Architecture:                         x86_64
    CPU op-mode(s):                       32-bit, 64-bit
    Address sizes:                        48 bits physical, 48 bits virtual
    Byte Order:                           Little Endian
    CPU(s):                               4
    On-line CPU(s) list:                  0-3
    Vendor ID:                            AuthenticAMD
    Model name:                           AMD EPYC 7763 64-Core Processor
    CPU family:                           25
    Model:                                1
    Thread(s) per core:                   2
    Core(s) per socket:                   2
    Socket(s):                            1
    Stepping:                             1
    BogoMIPS:                             4890.85
    Flags:                                fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good nopl tsc_reliable nonstop_tsc cpuid extd_apicid aperfmperf tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm cmp_legacy svm cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw topoext vmmcall fsgsbase bmi1 avx2 smep bmi2 erms invpcid rdseed adx smap clflushopt clwb sha_ni xsaveopt xsavec xgetbv1 xsaves user_shstk clzero xsaveerptr rdpru arat npt nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold v_vmsave_vmload umip vaes vpclmulqdq rdpid fsrm
    Virtualization:                       AMD-V
    Hypervisor vendor:                    Microsoft
    Virtualization type:                  full
    L1d cache:                            64 KiB (2 instances)
    L1i cache:                            64 KiB (2 instances)
    L2 cache:                             1 MiB (2 instances)
    L3 cache:                             32 MiB (1 instance)
    NUMA node(s):                         1
    NUMA node0 CPU(s):                    0-3
    Vulnerability Gather data sampling:   Not affected
    Vulnerability Itlb multihit:          Not affected
    Vulnerability L1tf:                   Not affected
    Vulnerability Mds:                    Not affected
    Vulnerability Meltdown:               Not affected
    Vulnerability Mmio stale data:        Not affected
    Vulnerability Reg file data sampling: Not affected
    Vulnerability Retbleed:               Not affected
    Vulnerability Spec rstack overflow:   Vulnerable: Safe RET, no microcode
    Vulnerability Spec store bypass:      Vulnerable
    Vulnerability Spectre v1:             Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:             Mitigation; Retpolines; STIBP disabled; RSB filling; PBRSB-eIBRS Not affected; BHI Not affected
    Vulnerability Srbds:                  Not affected
    Vulnerability Tsx async abort:        Not affected
    

| Cpu Property       | Value                                                      |
|:------------------ |:---------------------------------------------------------- |
| Brand              | AMD EPYC 7763 64-Core Processor                            |
| Vendor             | :AMD                                                       |
| Architecture       | :Unknown                                                   |
| Model              | Family: 0xaf, Model: 0x01, Stepping: 0x01, Type: 0x00      |
| Cores              | 16 physical cores, 16 logical cores (on executing CPU)     |
|                    | No Hyperthreading hardware capability detected             |
| Clock Frequencies  | Not supported by CPU                                       |
| Data Cache         | Level 1:3 : (32, 512, 32768) kbytes                        |
|                    | 64 byte cache line size                                    |
| Address Size       | 48 bits virtual, 48 bits physical                          |
| SIMD               | 256 bit = 32 byte max. SIMD vector size                    |
| Time Stamp Counter | TSC is accessible via `rdtsc`                              |
|                    | TSC runs at constant rate (invariant from clock frequency) |
| Perf. Monitoring   | Performance Monitoring Counters (PMC) are not supported    |
| Hypervisor         | Yes, Microsoft                                             |

