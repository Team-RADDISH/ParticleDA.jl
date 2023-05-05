# Benchmark result

* Pull request commit: [`81f212e0ebeb7e07111a8dcb92eb86cdd781308b`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/81f212e0ebeb7e07111a8dcb92eb86cdd781308b)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/241> (Update installation instructions)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 5 May 2023 - 12:45
    - Baseline: 5 May 2023 - 12:59
* Package commits:
    - Target: 50b043
    - Baseline: 20b6ad
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

| ID                                                                                                        | time ratio                   | memory ratio                 |
|-----------------------------------------------------------------------------------------------------------|------------------------------|------------------------------|
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |                1.07 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 0.95 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |                1.20 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     | 0.94 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             | 0.88 (5%) :white_check_mark: | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 0.25 (5%) :white_check_mark: | 0.01 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 0.68 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                | 0.93 (5%) :white_check_mark: | 0.98 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        | 0.91 (5%) :white_check_mark: | 0.98 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 0.56 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      | 0.84 (5%) :white_check_mark: | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              | 0.94 (5%) :white_check_mark: | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 0.58 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            | 0.92 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 0.92 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["Model interface", "update_state_stochastic!"]`                                                         | 0.89 (5%) :white_check_mark: |                   1.00 (1%)  |

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
      Ubuntu 22.04.2 LTS
  uname: Linux 5.15.0-1036-azure #43-Ubuntu SMP Wed Mar 29 16:11:05 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz      17690 s          0 s        512 s       5466 s          0 s
       #2  2294 MHz      10774 s          0 s        390 s      12456 s          0 s
  Memory: 6.781208038330078 GB (4215.89453125 MB free)
  Uptime: 2376.24 sec
  Load Avg:  1.77  1.44  1.27
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, broadwell)
  Threads: 2 on 2 virtual cores
```

### Baseline
```
Julia Version 1.8.5
Commit 17cfb8e65ea (2023-01-08 06:45 UTC)
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 22.04.2 LTS
  uname: Linux 5.15.0-1036-azure #43-Ubuntu SMP Wed Mar 29 16:11:05 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz      21308 s          0 s        573 s       9804 s          0 s
       #2  2294 MHz      17293 s          0 s        532 s      13824 s          0 s
  Memory: 6.781208038330078 GB (4409.51953125 MB free)
  Uptime: 3180.0 sec
  Load Avg:  1.84  1.45  1.32
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, broadwell)
  Threads: 2 on 2 virtual cores
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 May 2023 - 12:45
* Package commit: 50b043
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   5.900 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |   15.064 s (5%) |  45.954 ms | 588.11 MiB (1%) |    16557043 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 605.900 ms (5%) |            |   2.01 MiB (1%) |       20654 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.800 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |   13.208 s (5%) |  11.650 ms | 201.61 MiB (1%) |     1433152 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 611.883 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   8.500 μs (5%) |            |  33.88 MiB (1%) |          64 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |   13.707 s (5%) |  69.465 ms | 472.76 MiB (1%) |    11517206 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 592.731 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.400 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |   13.421 s (5%) |  10.979 ms | 201.62 MiB (1%) |     1433270 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 603.716 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   31.752 s (5%) | 480.482 ms |   3.12 GiB (1%) |    38481037 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   45.263 s (5%) | 683.713 ms |   3.67 GiB (1%) |    55041023 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 668.143 ms (5%) |            |   2.37 MiB (1%) |       20800 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   32.557 s (5%) | 500.528 ms |   3.12 GiB (1%) |    38481026 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   46.092 s (5%) | 572.618 ms |   3.29 GiB (1%) |    39917138 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 640.458 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   30.067 s (5%) | 468.550 ms |   3.12 GiB (1%) |    38481049 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   45.514 s (5%) | 698.408 ms |   3.55 GiB (1%) |    50001193 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 632.456 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   29.431 s (5%) | 459.101 ms |   3.12 GiB (1%) |    38481034 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   45.521 s (5%) | 574.294 ms |   3.29 GiB (1%) |    39917234 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 633.404 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.910 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  38.714 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   29.057 s (5%) | 421.768 ms |   3.07 GiB (1%) |    38439432 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   3.022 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 201.003 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   7.049 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   3.525 μs (5%) |            |   1.78 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 732.249 ms (5%) |            |   1.73 MiB (1%) |       13069 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  26.527 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   7.487 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
      Ubuntu 22.04.2 LTS
  uname: Linux 5.15.0-1036-azure #43-Ubuntu SMP Wed Mar 29 16:11:05 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz      17690 s          0 s        512 s       5466 s          0 s
       #2  2294 MHz      10774 s          0 s        390 s      12456 s          0 s
  Memory: 6.781208038330078 GB (4215.89453125 MB free)
  Uptime: 2376.24 sec
  Load Avg:  1.77  1.44  1.27
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, broadwell)
  Threads: 2 on 2 virtual cores
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 May 2023 - 12:59
* Package commit: 20b6ad
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   5.700 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |   14.101 s (5%) | 152.282 ms | 588.11 MiB (1%) |    16557043 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 640.458 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.000 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |   13.385 s (5%) |  63.216 ms | 202.26 MiB (1%) |     1446813 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 628.052 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   8.600 μs (5%) |            |  33.88 MiB (1%) |          64 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |   14.020 s (5%) | 156.934 ms | 472.76 MiB (1%) |    11517195 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 610.076 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.300 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |   13.178 s (5%) |   8.374 ms | 201.62 MiB (1%) |     1433255 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 612.419 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   33.783 s (5%) | 528.597 ms |   3.13 GiB (1%) |    38626040 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   51.478 s (5%) | 922.049 ms |   3.78 GiB (1%) |    57045305 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        |    2.646 s (5%) |  82.457 ms | 213.30 MiB (1%) |     4416185 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   31.881 s (5%) | 488.567 ms |   3.12 GiB (1%) |    38492955 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   47.377 s (5%) | 608.155 ms |   3.32 GiB (1%) |    40602762 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 938.509 ms (5%) |            |  12.89 MiB (1%) |      257609 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   32.225 s (5%) | 513.799 ms |   3.17 GiB (1%) |    39547277 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   49.849 s (5%) | 758.779 ms |   3.61 GiB (1%) |    51180078 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   |    1.124 s (5%) |  24.856 ms |  12.89 MiB (1%) |      257582 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   35.018 s (5%) | 602.910 ms |   3.21 GiB (1%) |    40260721 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   48.495 s (5%) | 626.218 ms |   3.38 GiB (1%) |    41763253 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         |    1.098 s (5%) |            |  12.88 MiB (1%) |      257583 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.870 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  39.976 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   31.655 s (5%) | 471.840 ms |   3.07 GiB (1%) |    38474245 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   2.933 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 203.670 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   7.191 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   3.487 μs (5%) |            |   1.78 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 798.503 ms (5%) |            |   1.73 MiB (1%) |       13069 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  26.634 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   8.447 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
      Ubuntu 22.04.2 LTS
  uname: Linux 5.15.0-1036-azure #43-Ubuntu SMP Wed Mar 29 16:11:05 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz      21308 s          0 s        573 s       9804 s          0 s
       #2  2294 MHz      17293 s          0 s        532 s      13824 s          0 s
  Memory: 6.781208038330078 GB (4409.51953125 MB free)
  Uptime: 3180.0 sec
  Load Avg:  1.84  1.45  1.32
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, broadwell)
  Threads: 2 on 2 virtual cores
```

---
# Runtime information
| Runtime Info | |
|:--|:--|
| BLAS #threads | 1 |
| `BLAS.vendor()` | `openblas64` |
| `Sys.CPU_THREADS` | 2 |

`lscpu` output:

    Architecture:                    x86_64
    CPU op-mode(s):                  32-bit, 64-bit
    Address sizes:                   46 bits physical, 48 bits virtual
    Byte Order:                      Little Endian
    CPU(s):                          2
    On-line CPU(s) list:             0,1
    Vendor ID:                       GenuineIntel
    Model name:                      Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz
    CPU family:                      6
    Model:                           79
    Thread(s) per core:              1
    Core(s) per socket:              2
    Socket(s):                       1
    Stepping:                        1
    BogoMIPS:                        4589.37
    Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm rdseed adx smap xsaveopt md_clear
    Hypervisor vendor:               Microsoft
    Virtualization type:             full
    L1d cache:                       64 KiB (2 instances)
    L1i cache:                       64 KiB (2 instances)
    L2 cache:                        512 KiB (2 instances)
    L3 cache:                        50 MiB (1 instance)
    NUMA node(s):                    1
    NUMA node0 CPU(s):               0,1
    Vulnerability Itlb multihit:     KVM: Mitigation: VMX unsupported
    Vulnerability L1tf:              Mitigation; PTE Inversion
    Vulnerability Mds:               Mitigation; Clear CPU buffers; SMT Host state unknown
    Vulnerability Meltdown:          Mitigation; PTI
    Vulnerability Mmio stale data:   Vulnerable: Clear CPU buffers attempted, no microcode; SMT Host state unknown
    Vulnerability Retbleed:          Not affected
    Vulnerability Spec store bypass: Vulnerable
    Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:        Mitigation; Retpolines, STIBP disabled, RSB filling, PBRSB-eIBRS Not affected
    Vulnerability Srbds:             Not affected
    Vulnerability Tsx async abort:   Mitigation; Clear CPU buffers; SMT Host state unknown
    

| Cpu Property       | Value                                                   |
|:------------------ |:------------------------------------------------------- |
| Brand              | Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz               |
| Vendor             | :Intel                                                  |
| Architecture       | :Broadwell                                              |
| Model              | Family: 0x06, Model: 0x4f, Stepping: 0x01, Type: 0x00   |
| Cores              | 2 physical cores, 2 logical cores (on executing CPU)    |
|                    | No Hyperthreading hardware capability detected          |
| Clock Frequencies  | Not supported by CPU                                    |
| Data Cache         | Level 1:3 : (32, 256, 51200) kbytes                     |
|                    | 64 byte cache line size                                 |
| Address Size       | 48 bits virtual, 46 bits physical                       |
| SIMD               | 256 bit = 32 byte max. SIMD vector size                 |
| Time Stamp Counter | TSC is accessible via `rdtsc`                           |
|                    | TSC increased at every clock cycle (non-invariant TSC)  |
| Perf. Monitoring   | Performance Monitoring Counters (PMC) are not supported |
| Hypervisor         | Yes, Microsoft                                          |

