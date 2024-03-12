# Benchmark result

* Pull request commit: [`93b48cb75a8daa3ba1737a515825056256be9630`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/93b48cb75a8daa3ba1737a515825056256be9630)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/259> (Reduce LLW2d model mesh dimensions for test)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 12 Mar 2024 - 19:09
    - Baseline: 12 Mar 2024 - 19:22
* Package commits:
    - Target: 078ddb
    - Baseline: 9284bb
* Julia commits:
    - Target: 17cfb8
    - Baseline: 17cfb8
* Julia command flags:
    - Target: None
    - Baseline: None
* Environment variables:
    - Target: `JULIA_NUM_THREADS => 2`
    - Baseline: `JULIA_NUM_THREADS => 2`

## Results
A ratio greater than `1.0` denotes a possible regression (marked with :x:), while a ratio less
than `1.0` denotes a possible improvement (marked with :white_check_mark:). Only significant results - results
that indicate possible regressions or improvements - are shown below (thus, an empty table means that all
benchmark results remained invariant between builds).

| ID                                                                                                        | time ratio                   | memory ratio |
|-----------------------------------------------------------------------------------------------------------|------------------------------|--------------|
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |                1.08 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            |                1.18 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            | 0.81 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 0.71 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Model interface", "get_observation_mean_given_state!"]`                                                |                1.05 (5%) :x: |   1.00 (1%)  |

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
Julia Version 1.8.5
Commit 17cfb8e65ea (2023-01-08 06:45 UTC)
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 22.04.4 LTS
  uname: Linux 6.5.0-1015-azure #15~22.04.1-Ubuntu SMP Tue Feb 13 01:15:12 UTC 2024 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1  2445 MHz       3947 s          0 s        309 s      27793 s          0 s
       #2  2588 MHz       4447 s          0 s        344 s      27255 s          0 s
       #3  2445 MHz       4374 s          0 s        338 s      27320 s          0 s
       #4  3242 MHz       3853 s          0 s        394 s      27819 s          0 s
  Memory: 15.606491088867188 GB (12980.54296875 MB free)
  Uptime: 3212.92 sec
  Load Avg:  1.7  1.37  1.06
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, znver3)
  Threads: 2 on 4 virtual cores
```

### Baseline
```
Julia Version 1.8.5
Commit 17cfb8e65ea (2023-01-08 06:45 UTC)
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 22.04.4 LTS
  uname: Linux 6.5.0-1015-azure #15~22.04.1-Ubuntu SMP Tue Feb 13 01:15:12 UTC 2024 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1  3243 MHz       6143 s          0 s        449 s      33476 s          0 s
       #2  3248 MHz       6892 s          0 s        491 s      32682 s          0 s
       #3  3203 MHz       6824 s          0 s        489 s      32739 s          0 s
       #4  2445 MHz       6541 s          0 s        560 s      32987 s          0 s
  Memory: 15.606491088867188 GB (12972.42578125 MB free)
  Uptime: 4016.41 sec
  Load Avg:  1.75  1.39  1.2
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, znver3)
  Threads: 2 on 4 virtual cores
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 12 Mar 2024 - 19:9
* Package commit: 078ddb
* Julia commit: 17cfb8
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   5.120 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    8.267 s (5%) | 112.117 ms | 588.09 MiB (1%) |    16556858 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 302.915 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   3.637 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    7.712 s (5%) |  13.629 ms | 202.22 MiB (1%) |     1446231 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 323.740 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   7.334 μs (5%) |            |  33.88 MiB (1%) |          62 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    7.855 s (5%) |  99.801 ms | 472.74 MiB (1%) |    11517003 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 315.241 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   6.231 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    6.896 s (5%) |   3.521 ms | 201.60 MiB (1%) |     1433081 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 294.247 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   18.883 s (5%) | 465.678 ms |   3.12 GiB (1%) |    38481037 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   27.032 s (5%) | 622.164 ms |   3.67 GiB (1%) |    55040422 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 314.387 ms (5%) |            |   2.35 MiB (1%) |       20792 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   18.855 s (5%) | 450.362 ms |   3.12 GiB (1%) |    38481026 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   25.832 s (5%) | 704.343 ms |   3.29 GiB (1%) |    39916551 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 303.755 ms (5%) |            |   2.35 MiB (1%) |       20793 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   18.911 s (5%) | 454.807 ms |   3.12 GiB (1%) |    38481047 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   26.475 s (5%) | 544.293 ms |   3.55 GiB (1%) |    50000588 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 312.640 ms (5%) |            |   2.35 MiB (1%) |       20793 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   18.988 s (5%) | 444.502 ms |   3.12 GiB (1%) |    38481034 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   26.113 s (5%) | 530.863 ms |   3.29 GiB (1%) |    39916658 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 305.926 ms (5%) |            |   2.35 MiB (1%) |       20793 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.410 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  26.525 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   18.548 s (5%) | 290.701 ms |   3.07 GiB (1%) |    38439432 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.709 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 138.585 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.035 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.981 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 349.028 ms (5%) |            |   1.72 MiB (1%) |       13049 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.342 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.238 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
Julia Version 1.8.5
Commit 17cfb8e65ea (2023-01-08 06:45 UTC)
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 22.04.4 LTS
  uname: Linux 6.5.0-1015-azure #15~22.04.1-Ubuntu SMP Tue Feb 13 01:15:12 UTC 2024 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1  2445 MHz       3947 s          0 s        309 s      27793 s          0 s
       #2  2588 MHz       4447 s          0 s        344 s      27255 s          0 s
       #3  2445 MHz       4374 s          0 s        338 s      27320 s          0 s
       #4  3242 MHz       3853 s          0 s        394 s      27819 s          0 s
  Memory: 15.606491088867188 GB (12980.54296875 MB free)
  Uptime: 3212.92 sec
  Load Avg:  1.7  1.37  1.06
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, znver3)
  Threads: 2 on 4 virtual cores
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 12 Mar 2024 - 19:22
* Package commit: 9284bb
* Julia commit: 17cfb8
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   5.129 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    8.383 s (5%) |  96.226 ms | 588.09 MiB (1%) |    16556851 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 288.945 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   3.366 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    7.581 s (5%) |            | 201.50 MiB (1%) |     1431754 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 274.692 ms (5%) |            |   2.01 MiB (1%) |       20666 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   7.343 μs (5%) |            |  33.88 MiB (1%) |          62 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    8.181 s (5%) |   5.398 ms | 472.74 MiB (1%) |    11517014 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 322.120 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   6.041 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    8.492 s (5%) |   3.449 ms | 201.60 MiB (1%) |     1433088 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 283.754 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   18.792 s (5%) | 466.759 ms |   3.12 GiB (1%) |    38481037 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   27.860 s (5%) | 795.415 ms |   3.67 GiB (1%) |    55040434 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 326.589 ms (5%) |            |   2.35 MiB (1%) |       20793 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   18.725 s (5%) | 337.084 ms |   3.12 GiB (1%) |    38481026 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   26.268 s (5%) | 653.188 ms |   3.29 GiB (1%) |    39916538 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 312.364 ms (5%) |            |   2.35 MiB (1%) |       20793 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   18.719 s (5%) | 330.917 ms |   3.12 GiB (1%) |    38481047 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   26.422 s (5%) | 585.263 ms |   3.55 GiB (1%) |    50000592 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 438.037 ms (5%) |            |   2.35 MiB (1%) |       20792 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   18.723 s (5%) | 427.492 ms |   3.12 GiB (1%) |    38481034 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   25.760 s (5%) | 527.281 ms |   3.29 GiB (1%) |    39916648 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 308.789 ms (5%) |            |   2.35 MiB (1%) |       20793 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.414 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  26.948 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   18.442 s (5%) | 269.845 ms |   3.07 GiB (1%) |    38439432 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.717 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 131.732 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   3.979 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   1.951 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 342.082 ms (5%) |            |   1.72 MiB (1%) |       13049 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.130 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.134 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
Julia Version 1.8.5
Commit 17cfb8e65ea (2023-01-08 06:45 UTC)
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 22.04.4 LTS
  uname: Linux 6.5.0-1015-azure #15~22.04.1-Ubuntu SMP Tue Feb 13 01:15:12 UTC 2024 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1  3243 MHz       6143 s          0 s        449 s      33476 s          0 s
       #2  3248 MHz       6892 s          0 s        491 s      32682 s          0 s
       #3  3203 MHz       6824 s          0 s        489 s      32739 s          0 s
       #4  2445 MHz       6541 s          0 s        560 s      32987 s          0 s
  Memory: 15.606491088867188 GB (12972.42578125 MB free)
  Uptime: 4016.41 sec
  Load Avg:  1.75  1.39  1.2
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, znver3)
  Threads: 2 on 4 virtual cores
```

---
# Runtime information
| Runtime Info | |
|:--|:--|
| BLAS #threads | 2 |
| `BLAS.vendor()` | `openblas64` |
| `Sys.CPU_THREADS` | 4 |

`lscpu` output:

    Architecture:                       x86_64
    CPU op-mode(s):                     32-bit, 64-bit
    Address sizes:                      48 bits physical, 48 bits virtual
    Byte Order:                         Little Endian
    CPU(s):                             4
    On-line CPU(s) list:                0-3
    Vendor ID:                          AuthenticAMD
    Model name:                         AMD EPYC 7763 64-Core Processor
    CPU family:                         25
    Model:                              1
    Thread(s) per core:                 2
    Core(s) per socket:                 2
    Socket(s):                          1
    Stepping:                           1
    BogoMIPS:                           4890.86
    Flags:                              fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good nopl tsc_reliable nonstop_tsc cpuid extd_apicid aperfmperf pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm cmp_legacy svm cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw topoext invpcid_single vmmcall fsgsbase bmi1 avx2 smep bmi2 erms invpcid rdseed adx smap clflushopt clwb sha_ni xsaveopt xsavec xgetbv1 xsaves clzero xsaveerptr rdpru arat npt nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold v_vmsave_vmload umip vaes vpclmulqdq rdpid fsrm
    Virtualization:                     AMD-V
    Hypervisor vendor:                  Microsoft
    Virtualization type:                full
    L1d cache:                          64 KiB (2 instances)
    L1i cache:                          64 KiB (2 instances)
    L2 cache:                           1 MiB (2 instances)
    L3 cache:                           32 MiB (1 instance)
    NUMA node(s):                       1
    NUMA node0 CPU(s):                  0-3
    Vulnerability Gather data sampling: Not affected
    Vulnerability Itlb multihit:        Not affected
    Vulnerability L1tf:                 Not affected
    Vulnerability Mds:                  Not affected
    Vulnerability Meltdown:             Not affected
    Vulnerability Mmio stale data:      Not affected
    Vulnerability Retbleed:             Not affected
    Vulnerability Spec rstack overflow: Mitigation; safe RET, no microcode
    Vulnerability Spec store bypass:    Vulnerable
    Vulnerability Spectre v1:           Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:           Mitigation; Retpolines, STIBP disabled, RSB filling, PBRSB-eIBRS Not affected
    Vulnerability Srbds:                Not affected
    Vulnerability Tsx async abort:      Not affected
    

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

