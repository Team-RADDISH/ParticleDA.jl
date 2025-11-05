# Benchmark result

* Pull request commit: [`19063d9661923989df19bd1347afa021712e6ecc`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/19063d9661923989df19bd1347afa021712e6ecc)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/300> (Run Aqua tests)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 5 Nov 2025 - 17:31
    - Baseline: 5 Nov 2025 - 17:40
* Package commits:
    - Target: 81ad3f3
    - Baseline: a813e98
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           | 0.90 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 0.95 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      | 0.93 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            | 0.95 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   |                1.25 (5%) :x: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         |                1.11 (5%) :x: |   1.00 (1%)  |

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
       #1     0 MHz       2974 s          0 s        129 s       4270 s          0 s
       #2     0 MHz       3127 s          0 s        121 s       4133 s          0 s
       #3     0 MHz       2658 s          0 s        114 s       4606 s          0 s
       #4     0 MHz       2743 s          0 s        105 s       4529 s          0 s
  Memory: 15.620681762695312 GB (13562.1796875 MB free)
  Uptime: 741.37 sec
  Load Avg:  1.74  1.6  0.99
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
       #1     0 MHz       5532 s          0 s        182 s       7523 s          0 s
       #2     0 MHz       5741 s          0 s        176 s       7329 s          0 s
       #3     0 MHz       4102 s          0 s        146 s       8995 s          0 s
       #4     0 MHz       5019 s          0 s        131 s       8094 s          0 s
  Memory: 15.620681762695312 GB (13349.984375 MB free)
  Uptime: 1328.55 sec
  Load Avg:  1.8  1.61  1.26
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 17:31
* Package commit: 81ad3f3
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.182 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    6.608 s (5%) |  97.189 ms | 438.57 MiB (1%) |    12013503 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 287.746 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.658 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    6.503 s (5%) |   2.072 ms | 205.88 MiB (1%) |     1929785 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 293.565 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.247 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    6.646 s (5%) |  15.274 ms | 207.86 MiB (1%) |     1933440 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 292.713 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.524 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    6.631 s (5%) |  12.406 ms | 205.97 MiB (1%) |     1930796 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 306.464 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.079 s (5%) | 260.943 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.364 s (5%) | 495.150 ms |   3.48 GiB (1%) |    60748397 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 366.160 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.055 s (5%) | 255.638 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   11.867 s (5%) | 408.114 ms |   3.25 GiB (1%) |    50665506 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 399.926 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.065 s (5%) | 263.126 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.377 s (5%) | 413.226 ms |   3.26 GiB (1%) |    50668181 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 398.006 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.099 s (5%) | 267.332 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   12.042 s (5%) | 433.761 ms |   3.25 GiB (1%) |    50665551 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 357.472 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.241 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.129 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.058 s (5%) | 263.896 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.507 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  86.923 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.204 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.776 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 349.020 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  13.056 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.358 ms (5%) |            |   48 bytes (1%) |           1 |

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
       #1     0 MHz       2974 s          0 s        129 s       4270 s          0 s
       #2     0 MHz       3127 s          0 s        121 s       4133 s          0 s
       #3     0 MHz       2658 s          0 s        114 s       4606 s          0 s
       #4     0 MHz       2743 s          0 s        105 s       4529 s          0 s
  Memory: 15.620681762695312 GB (13562.1796875 MB free)
  Uptime: 741.37 sec
  Load Avg:  1.74  1.6  0.99
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 17:40
* Package commit: a813e98
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.171 μs (5%) |            |  33.88 MiB (1%) |          57 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    7.379 s (5%) |  30.505 ms | 438.57 MiB (1%) |    12013509 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 303.810 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.729 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    6.387 s (5%) |   7.306 ms | 205.88 MiB (1%) |     1929786 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 303.053 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.217 μs (5%) |            |  33.88 MiB (1%) |          65 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    7.167 s (5%) |   2.170 ms | 207.86 MiB (1%) |     1933440 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 301.647 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.514 μs (5%) |            |  32.05 MiB (1%) |          50 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    6.993 s (5%) |   2.333 ms | 205.97 MiB (1%) |     1930800 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 292.898 ms (5%) |            |   1.85 MiB (1%) |       19353 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    5.035 s (5%) | 256.688 ms |   3.08 GiB (1%) |    48731467 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   11.974 s (5%) | 483.031 ms |   3.48 GiB (1%) |    60748373 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 379.206 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    5.048 s (5%) | 279.642 ms |   3.08 GiB (1%) |    48731455 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   11.626 s (5%) | 435.110 ms |   3.25 GiB (1%) |    50665540 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 411.866 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    5.013 s (5%) | 258.552 ms |   3.08 GiB (1%) |    48731477 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.169 s (5%) | 429.678 ms |   3.26 GiB (1%) |    50668183 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 318.091 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    5.028 s (5%) | 257.522 ms |   3.08 GiB (1%) |    48731462 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   11.778 s (5%) | 426.318 ms |   3.25 GiB (1%) |    50665465 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 321.505 ms (5%) |            |   2.19 MiB (1%) |       19507 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.231 μs (5%) |            |  576 bytes (1%) |           2 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.124 ms (5%) |            |   2.51 MiB (1%) |       51945 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    5.019 s (5%) | 256.127 ms |   3.03 GiB (1%) |    48679434 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.490 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |  86.713 ns (5%) |            |   48 bytes (1%) |           1 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.279 ms (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.747 μs (5%) |            |   1.17 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 350.896 ms (5%) |            |   1.64 MiB (1%) |       12148 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.451 ms (5%) |            |  35.20 KiB (1%) |         601 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.464 ms (5%) |            |   48 bytes (1%) |           1 |

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
       #1     0 MHz       5532 s          0 s        182 s       7523 s          0 s
       #2     0 MHz       5741 s          0 s        176 s       7329 s          0 s
       #3     0 MHz       4102 s          0 s        146 s       8995 s          0 s
       #4     0 MHz       5019 s          0 s        131 s       8094 s          0 s
  Memory: 15.620681762695312 GB (13349.984375 MB free)
  Uptime: 1328.55 sec
  Load Avg:  1.8  1.61  1.26
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

