# Benchmark result

* Pull request commit: [`78f91ab49518b9e738228a74885c0c3221bb8024`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/78f91ab49518b9e738228a74885c0c3221bb8024)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/312> (Bump julia-actions/cache from 2 to 3)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 9 Mar 2026 - 10:24
    - Baseline: 9 Mar 2026 - 10:34
* Package commits:
    - Target: e9c2324
    - Baseline: 118b0bb
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           | 0.91 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |                1.07 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      | 0.89 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 0.93 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 0.81 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   |                1.14 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 0.75 (5%) :white_check_mark: |   1.00 (1%)  |

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
  uname: Linux 6.14.0-1017-azure #17~24.04.1-Ubuntu SMP Mon Dec  1 20:10:50 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1     0 MHz       3032 s          0 s        174 s       5586 s          0 s
       #2     0 MHz       3414 s          0 s        165 s       5211 s          0 s
       #3     0 MHz       2843 s          0 s        156 s       5786 s          0 s
       #4     0 MHz       3443 s          0 s        156 s       5211 s          0 s
  Memory: 15.619781494140625 GB (13446.50390625 MB free)
  Uptime: 883.98 sec
  Load Avg:  1.71  1.51  1.01
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
  uname: Linux 6.14.0-1017-azure #17~24.04.1-Ubuntu SMP Mon Dec  1 20:10:50 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1     0 MHz       5139 s          0 s        218 s       9418 s          0 s
       #2     0 MHz       5836 s          0 s        214 s       8726 s          0 s
       #3     0 MHz       5070 s          0 s        201 s       9503 s          0 s
       #4     0 MHz       5679 s          0 s        216 s       8904 s          0 s
  Memory: 15.619781494140625 GB (13300.0390625 MB free)
  Uptime: 1483.49 sec
  Load Avg:  1.76  1.58  1.26
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 9 Mar 2026 - 10:24
* Package commit: e9c2324
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.202 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    6.656 s (5%) |   4.327 ms | 438.79 MiB (1%) |    12017504 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 290.317 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.509 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    7.037 s (5%) |   2.184 ms | 206.04 MiB (1%) |     1932851 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 297.790 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.087 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    6.583 s (5%) |  12.375 ms | 208.08 MiB (1%) |     1937406 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 291.251 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.565 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    7.004 s (5%) |  14.806 ms | 206.18 MiB (1%) |     1934772 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 301.287 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.268 s (5%) | 338.382 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.335 s (5%) | 573.575 ms |   3.48 GiB (1%) |    60755351 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 309.066 ms (5%) |   3.389 ms |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.265 s (5%) | 338.754 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   11.888 s (5%) | 514.274 ms |   3.25 GiB (1%) |    50672088 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 298.147 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.227 s (5%) | 331.470 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.329 s (5%) | 506.106 ms |   3.26 GiB (1%) |    50675178 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 382.511 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.285 s (5%) | 343.706 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   11.800 s (5%) | 505.893 ms |   3.25 GiB (1%) |    50672796 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 307.216 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.261 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.187 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.241 s (5%) | 331.954 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.518 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  87.257 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.184 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.781 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 354.074 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.513 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.322 ms (5%) |            |   48 bytes (1%) |           1 |

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
  uname: Linux 6.14.0-1017-azure #17~24.04.1-Ubuntu SMP Mon Dec  1 20:10:50 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1     0 MHz       3032 s          0 s        174 s       5586 s          0 s
       #2     0 MHz       3414 s          0 s        165 s       5211 s          0 s
       #3     0 MHz       2843 s          0 s        156 s       5786 s          0 s
       #4     0 MHz       3443 s          0 s        156 s       5211 s          0 s
  Memory: 15.619781494140625 GB (13446.50390625 MB free)
  Uptime: 883.98 sec
  Load Avg:  1.71  1.51  1.01
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 9 Mar 2026 - 10:34
* Package commit: 118b0bb
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.202 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    7.284 s (5%) | 122.114 ms | 438.79 MiB (1%) |    12017490 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 296.722 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.388 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    6.570 s (5%) |  15.148 ms | 206.04 MiB (1%) |     1932807 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 293.866 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.187 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    7.369 s (5%) |  14.645 ms | 208.08 MiB (1%) |     1937449 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 287.832 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.424 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    7.061 s (5%) |   2.398 ms | 206.18 MiB (1%) |     1934825 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 297.966 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.205 s (5%) | 332.812 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.641 s (5%) | 558.870 ms |   3.48 GiB (1%) |    60754723 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 333.826 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.199 s (5%) | 342.933 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   12.118 s (5%) | 508.474 ms |   3.25 GiB (1%) |    50672200 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 367.426 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.162 s (5%) | 324.400 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.638 s (5%) | 510.574 ms |   3.26 GiB (1%) |    50674991 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 334.581 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.219 s (5%) | 332.348 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   12.002 s (5%) | 503.541 ms |   3.25 GiB (1%) |    50672634 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 411.768 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.234 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.205 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.147 s (5%) | 324.497 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.496 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  87.831 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.331 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.763 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 353.141 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.419 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.473 ms (5%) |            |   48 bytes (1%) |           1 |

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
  uname: Linux 6.14.0-1017-azure #17~24.04.1-Ubuntu SMP Mon Dec  1 20:10:50 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1     0 MHz       5139 s          0 s        218 s       9418 s          0 s
       #2     0 MHz       5836 s          0 s        214 s       8726 s          0 s
       #3     0 MHz       5070 s          0 s        201 s       9503 s          0 s
       #4     0 MHz       5679 s          0 s        216 s       8904 s          0 s
  Memory: 15.619781494140625 GB (13300.0390625 MB free)
  Uptime: 1483.49 sec
  Load Avg:  1.76  1.58  1.26
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

    Architecture:                            x86_64
    CPU op-mode(s):                          32-bit, 64-bit
    Address sizes:                           48 bits physical, 48 bits virtual
    Byte Order:                              Little Endian
    CPU(s):                                  4
    On-line CPU(s) list:                     0-3
    Vendor ID:                               AuthenticAMD
    Model name:                              AMD EPYC 7763 64-Core Processor
    CPU family:                              25
    Model:                                   1
    Thread(s) per core:                      2
    Core(s) per socket:                      2
    Socket(s):                               1
    Stepping:                                1
    BogoMIPS:                                4890.85
    Flags:                                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good nopl tsc_reliable nonstop_tsc cpuid extd_apicid aperfmperf tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm cmp_legacy svm cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw topoext vmmcall fsgsbase bmi1 avx2 smep bmi2 erms invpcid rdseed adx smap clflushopt clwb sha_ni xsaveopt xsavec xgetbv1 xsaves user_shstk clzero xsaveerptr rdpru arat npt nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold v_vmsave_vmload umip vaes vpclmulqdq rdpid fsrm
    Virtualization:                          AMD-V
    Hypervisor vendor:                       Microsoft
    Virtualization type:                     full
    L1d cache:                               64 KiB (2 instances)
    L1i cache:                               64 KiB (2 instances)
    L2 cache:                                1 MiB (2 instances)
    L3 cache:                                32 MiB (1 instance)
    NUMA node(s):                            1
    NUMA node0 CPU(s):                       0-3
    Vulnerability Gather data sampling:      Not affected
    Vulnerability Ghostwrite:                Not affected
    Vulnerability Indirect target selection: Not affected
    Vulnerability Itlb multihit:             Not affected
    Vulnerability L1tf:                      Not affected
    Vulnerability Mds:                       Not affected
    Vulnerability Meltdown:                  Not affected
    Vulnerability Mmio stale data:           Not affected
    Vulnerability Reg file data sampling:    Not affected
    Vulnerability Retbleed:                  Not affected
    Vulnerability Spec rstack overflow:      Vulnerable: Safe RET, no microcode
    Vulnerability Spec store bypass:         Vulnerable
    Vulnerability Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:                Mitigation; Retpolines; STIBP disabled; RSB filling; PBRSB-eIBRS Not affected; BHI Not affected
    Vulnerability Srbds:                     Not affected
    Vulnerability Tsa:                       Vulnerable: Clear CPU buffers attempted, no microcode
    Vulnerability Tsx async abort:           Not affected
    Vulnerability Vmscape:                   Not affected
    

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

