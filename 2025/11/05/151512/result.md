# Benchmark result

* Pull request commit: [`8b3d2ba337875ba2f67ba2ed49625aa1deb2faf4`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/8b3d2ba337875ba2f67ba2ed49625aa1deb2faf4)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/299> (Run benchmarks using Julia v1.11)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 5 Nov 2025 - 15:04
    - Baseline: 5 Nov 2025 - 15:14
* Package commits:
    - Target: aa4ab35
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           | 0.85 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |                1.09 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 0.90 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |                1.19 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        |                1.15 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   | 0.95 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              |                1.05 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   |                1.13 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         |                1.06 (5%) :x: |   1.00 (1%)  |

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
       #1     0 MHz       2962 s          0 s        119 s       5526 s          0 s
       #2     0 MHz       3443 s          0 s        114 s       5051 s          0 s
       #3     0 MHz       2252 s          0 s         81 s       6282 s          0 s
       #4     0 MHz       3104 s          0 s         97 s       5409 s          0 s
  Memory: 15.620681762695312 GB (13503.71875 MB free)
  Uptime: 864.05 sec
  Load Avg:  1.81  1.51  0.93
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
       #1     0 MHz       4947 s          0 s        160 s       9460 s          0 s
       #2     0 MHz       6608 s          0 s        171 s       7793 s          0 s
       #3     0 MHz       3824 s          0 s        110 s      10646 s          0 s
       #4     0 MHz       5458 s          0 s        133 s       8984 s          0 s
  Memory: 15.620681762695312 GB (13508.5546875 MB free)
  Uptime: 1461.13 sec
  Load Avg:  1.75  1.65  1.27
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 15:04
* Package commit: aa4ab35
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.021 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    6.823 s (5%) | 223.153 ms | 438.57 MiB (1%) |    12013507 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 295.308 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.599 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    6.340 s (5%) |            | 205.88 MiB (1%) |     1929785 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 292.027 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.077 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    6.909 s (5%) |   2.691 ms | 207.86 MiB (1%) |     1933440 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 291.739 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.754 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    7.473 s (5%) |            | 205.97 MiB (1%) |     1930800 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 298.877 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.123 s (5%) | 278.419 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.116 s (5%) | 510.050 ms |   3.48 GiB (1%) |    60748359 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 350.905 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.122 s (5%) | 280.113 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   11.886 s (5%) | 448.324 ms |   3.25 GiB (1%) |    50665543 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 346.391 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.062 s (5%) | 260.001 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.182 s (5%) | 472.460 ms |   3.26 GiB (1%) |    50668287 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 388.653 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.104 s (5%) | 276.841 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   11.981 s (5%) | 438.620 ms |   3.25 GiB (1%) |    50665509 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 326.924 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.263 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.182 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.077 s (5%) | 272.594 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.521 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  86.674 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.209 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.799 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 364.292 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  13.133 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.359 ms (5%) |            |   48 bytes (1%) |           1 |

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
       #1     0 MHz       2962 s          0 s        119 s       5526 s          0 s
       #2     0 MHz       3443 s          0 s        114 s       5051 s          0 s
       #3     0 MHz       2252 s          0 s         81 s       6282 s          0 s
       #4     0 MHz       3104 s          0 s         97 s       5409 s          0 s
  Memory: 15.620681762695312 GB (13503.71875 MB free)
  Uptime: 864.05 sec
  Load Avg:  1.81  1.51  0.93
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 15:14
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.142 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    7.983 s (5%) | 105.988 ms | 438.57 MiB (1%) |    12013505 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 296.465 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.599 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    6.337 s (5%) |  14.679 ms | 205.88 MiB (1%) |     1929786 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 303.607 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.027 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    6.329 s (5%) |            | 207.86 MiB (1%) |     1933437 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 324.690 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.434 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    6.293 s (5%) |  16.193 ms | 205.97 MiB (1%) |     1930802 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 305.970 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.082 s (5%) | 266.954 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.270 s (5%) | 486.164 ms |   3.48 GiB (1%) |    60748397 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 306.058 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.083 s (5%) | 283.581 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   12.544 s (5%) | 450.812 ms |   3.25 GiB (1%) |    50665476 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 329.357 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.030 s (5%) | 252.323 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   11.974 s (5%) | 462.520 ms |   3.26 GiB (1%) |    50668163 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 344.249 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.033 s (5%) | 252.359 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   11.969 s (5%) | 444.921 ms |   3.25 GiB (1%) |    50665538 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 307.355 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.261 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.165 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.059 s (5%) | 260.483 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.513 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  88.186 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.167 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.765 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 361.475 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  13.048 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.390 ms (5%) |            |   48 bytes (1%) |           1 |

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
       #1     0 MHz       4947 s          0 s        160 s       9460 s          0 s
       #2     0 MHz       6608 s          0 s        171 s       7793 s          0 s
       #3     0 MHz       3824 s          0 s        110 s      10646 s          0 s
       #4     0 MHz       5458 s          0 s        133 s       8984 s          0 s
  Memory: 15.620681762695312 GB (13508.5546875 MB free)
  Uptime: 1461.13 sec
  Load Avg:  1.75  1.65  1.27
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

