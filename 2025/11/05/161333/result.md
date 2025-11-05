# Benchmark result

* Pull request commit: [`ee8a342044a5ad46900b457b822499898357b120`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/ee8a342044a5ad46900b457b822499898357b120)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/299> (Run benchmarks using Julia v1.11)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 5 Nov 2025 - 15:59
    - Baseline: 5 Nov 2025 - 16:13
* Package commits:
    - Target: faea2c5
    - Baseline: c101d0d
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |                1.13 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 0.85 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |                1.30 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 0.91 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |                1.07 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 0.87 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   | 0.93 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 0.78 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 0.74 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         |                1.26 (5%) :x: |   1.00 (1%)  |

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
       #1     0 MHz       2433 s          0 s         94 s       4243 s          0 s
       #2     0 MHz       2376 s          0 s         92 s       4295 s          0 s
       #3     0 MHz       2298 s          0 s         78 s       4402 s          0 s
       #4     0 MHz       2811 s          0 s         88 s       3865 s          0 s
  Memory: 15.620681762695312 GB (13576.21875 MB free)
  Uptime: 680.72 sec
  Load Avg:  1.76  1.47  0.85
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
       #1     0 MHz       4605 s          0 s        134 s      10211 s          0 s
       #2     0 MHz       4462 s          0 s        124 s      10359 s          0 s
       #3     0 MHz       6051 s          0 s        164 s       8749 s          0 s
       #4     0 MHz       6433 s          0 s        164 s       8354 s          0 s
  Memory: 15.620681762695312 GB (13337.12890625 MB free)
  Uptime: 1499.98 sec
  Load Avg:  1.86  1.63  1.27
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 15:59
* Package commit: faea2c5
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.181 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    7.956 s (5%) |   4.340 ms | 438.57 MiB (1%) |    12013506 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 278.061 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.659 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    7.011 s (5%) |   1.984 ms | 205.88 MiB (1%) |     1929786 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 289.966 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.217 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    8.400 s (5%) |   2.452 ms | 207.86 MiB (1%) |     1933441 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 296.516 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.514 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    7.094 s (5%) |            | 205.97 MiB (1%) |     1930800 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 281.527 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.170 s (5%) | 279.284 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.829 s (5%) | 516.380 ms |   3.48 GiB (1%) |    60748403 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 337.736 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.203 s (5%) | 291.952 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   12.168 s (5%) | 461.849 ms |   3.25 GiB (1%) |    50665559 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 325.595 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.186 s (5%) | 280.324 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.822 s (5%) | 519.590 ms |   3.26 GiB (1%) |    50668247 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 301.508 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.162 s (5%) | 276.233 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   12.372 s (5%) | 444.277 ms |   3.25 GiB (1%) |    50665524 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 399.964 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.235 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.305 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.152 s (5%) | 277.508 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.527 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  88.008 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.315 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.815 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 354.751 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.499 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.489 ms (5%) |            |   48 bytes (1%) |           1 |

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
       #1     0 MHz       2433 s          0 s         94 s       4243 s          0 s
       #2     0 MHz       2376 s          0 s         92 s       4295 s          0 s
       #3     0 MHz       2298 s          0 s         78 s       4402 s          0 s
       #4     0 MHz       2811 s          0 s         88 s       3865 s          0 s
  Memory: 15.620681762695312 GB (13576.21875 MB free)
  Uptime: 680.72 sec
  Load Avg:  1.76  1.47  0.85
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 16:13
* Package commit: c101d0d
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   5.941 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    7.069 s (5%) | 231.150 ms | 438.57 MiB (1%) |    12013505 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 326.336 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.628 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    7.277 s (5%) |   2.512 ms | 205.88 MiB (1%) |     1929785 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 291.934 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.068 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    6.464 s (5%) |   2.513 ms | 207.86 MiB (1%) |     1933440 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 326.219 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.824 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    6.605 s (5%) |  13.697 ms | 205.97 MiB (1%) |     1930800 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 325.249 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.194 s (5%) | 285.139 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.827 s (5%) | 532.455 ms |   3.48 GiB (1%) |    60748397 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 325.972 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.153 s (5%) | 283.293 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   13.050 s (5%) | 508.280 ms |   3.25 GiB (1%) |    50665542 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 414.918 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.127 s (5%) | 276.728 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.268 s (5%) | 482.653 ms |   3.26 GiB (1%) |    50668287 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 405.380 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.139 s (5%) | 279.141 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   11.916 s (5%) | 458.591 ms |   3.25 GiB (1%) |    50665468 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 318.281 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.230 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.160 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.156 s (5%) | 296.279 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.509 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  87.872 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.271 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.819 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 369.370 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.606 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.424 ms (5%) |            |   48 bytes (1%) |           1 |

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
       #1     0 MHz       4605 s          0 s        134 s      10211 s          0 s
       #2     0 MHz       4462 s          0 s        124 s      10359 s          0 s
       #3     0 MHz       6051 s          0 s        164 s       8749 s          0 s
       #4     0 MHz       6433 s          0 s        164 s       8354 s          0 s
  Memory: 15.620681762695312 GB (13337.12890625 MB free)
  Uptime: 1499.98 sec
  Load Avg:  1.86  1.63  1.27
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
    BogoMIPS:                             4890.86
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

