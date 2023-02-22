# Benchmark result

* Pull request commit: [`8a9967910478e6da5528cfefe06b1eab89eaa439`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/8a9967910478e6da5528cfefe06b1eab89eaa439)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/236> (Remove useless dependency on `DifferentialEquations`)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 22 Feb 2023 - 16:09
    - Baseline: 22 Feb 2023 - 16:20
* Package commits:
    - Target: b0c37d
    - Baseline: 9b39f6
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
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |                1.19 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 | 0.79 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |                   1.03 (5%)  | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 0.36 (5%) :white_check_mark: | 0.01 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |                1.20 (5%) :x: |                   0.99 (1%)  |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              |                   1.01 (5%)  | 0.18 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |                   0.99 (5%)  | 0.98 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |                1.13 (5%) :x: | 0.98 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 0.59 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |                   0.97 (5%)  | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              | 0.85 (5%) :white_check_mark: | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 0.59 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |                1.08 (5%) :x: |                   1.00 (1%)  |

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
      Ubuntu 22.04.1 LTS
  uname: Linux 5.15.0-1033-azure #40-Ubuntu SMP Mon Jan 23 20:36:59 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz: 
              speed         user         nice          sys         idle          irq
       #1  2793 MHz      16212 s          0 s        389 s       3933 s          0 s
       #2  2793 MHz       8646 s          0 s        239 s      11614 s          0 s
  Memory: 6.781219482421875 GB (4066.9765625 MB free)
  Uptime: 2058.63 sec
  Load Avg:  1.71  1.43  1.22
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, icelake-server)
  Threads: 2 on 2 virtual cores
```

### Baseline
```
Julia Version 1.8.5
Commit 17cfb8e65ea (2023-01-08 06:45 UTC)
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 22.04.1 LTS
  uname: Linux 5.15.0-1033-azure #40-Ubuntu SMP Mon Jan 23 20:36:59 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz: 
              speed         user         nice          sys         idle          irq
       #1  2793 MHz      19094 s          0 s        433 s       7377 s          0 s
       #2  2793 MHz      14021 s          0 s        354 s      12500 s          0 s
  Memory: 6.781219482421875 GB (4248.9609375 MB free)
  Uptime: 2696.6 sec
  Load Avg:  1.77  1.43  1.29
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, icelake-server)
  Threads: 2 on 2 virtual cores
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 22 Feb 2023 - 16:9
* Package commit: b0c37d
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.299 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    9.796 s (5%) |  83.491 ms | 588.11 MiB (1%) |    16557027 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 443.209 ms (5%) |            |   2.01 MiB (1%) |       20654 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   5.099 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    9.382 s (5%) |   4.303 ms | 201.61 MiB (1%) |     1433138 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 441.834 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.800 μs (5%) |            |  33.88 MiB (1%) |          64 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    9.720 s (5%) |  60.464 ms | 472.76 MiB (1%) |    11517190 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 445.619 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   8.200 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    9.349 s (5%) |   4.246 ms | 201.62 MiB (1%) |     1433292 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 440.288 ms (5%) |            |   2.01 MiB (1%) |       20654 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   23.263 s (5%) | 404.391 ms |   3.12 GiB (1%) |    38481037 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   39.219 s (5%) | 618.443 ms |   3.67 GiB (1%) |    55041017 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 724.974 ms (5%) |            |   2.37 MiB (1%) |       20800 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   23.295 s (5%) | 407.496 ms |   3.12 GiB (1%) |    38481026 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   41.527 s (5%) | 546.689 ms |   3.29 GiB (1%) |    39917114 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 763.628 ms (5%) |            |   2.37 MiB (1%) |       20800 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   23.240 s (5%) | 400.154 ms |   3.12 GiB (1%) |    38481049 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   39.523 s (5%) | 613.881 ms |   3.55 GiB (1%) |    50001158 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 447.174 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   23.255 s (5%) | 403.142 ms |   3.12 GiB (1%) |    38481034 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   35.669 s (5%) | 540.935 ms |   3.29 GiB (1%) |    39917265 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 452.240 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.980 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  34.632 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   23.063 s (5%) | 343.198 ms |   3.07 GiB (1%) |    38439432 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   2.489 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 178.284 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   6.694 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   3.556 μs (5%) |            |   1.78 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 574.918 ms (5%) |            |   1.73 MiB (1%) |       13069 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  20.529 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   7.220 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
      Ubuntu 22.04.1 LTS
  uname: Linux 5.15.0-1033-azure #40-Ubuntu SMP Mon Jan 23 20:36:59 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz: 
              speed         user         nice          sys         idle          irq
       #1  2793 MHz      16212 s          0 s        389 s       3933 s          0 s
       #2  2793 MHz       8646 s          0 s        239 s      11614 s          0 s
  Memory: 6.781219482421875 GB (4066.9765625 MB free)
  Uptime: 2058.63 sec
  Load Avg:  1.71  1.43  1.22
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, icelake-server)
  Threads: 2 on 2 virtual cores
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 22 Feb 2023 - 16:20
* Package commit: 9b39f6
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.400 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    9.988 s (5%) | 135.115 ms | 588.11 MiB (1%) |    16557060 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 444.300 ms (5%) |            |   2.01 MiB (1%) |       20654 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.300 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |   11.912 s (5%) |  32.148 ms | 201.52 MiB (1%) |     1432090 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 444.852 ms (5%) |            |   2.01 MiB (1%) |       20654 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.900 μs (5%) |            |  33.88 MiB (1%) |          64 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    9.873 s (5%) | 121.959 ms | 472.76 MiB (1%) |    11517220 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 450.745 ms (5%) |            |   2.01 MiB (1%) |       20654 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   8.000 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    9.488 s (5%) |   6.217 ms | 201.62 MiB (1%) |     1433261 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 449.930 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   23.376 s (5%) | 422.054 ms |   3.13 GiB (1%) |    38626039 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   38.049 s (5%) | 800.273 ms |   3.78 GiB (1%) |    57045337 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        |    2.025 s (5%) |  53.903 ms | 213.30 MiB (1%) |     4416183 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   23.212 s (5%) | 418.703 ms |   3.12 GiB (1%) |    38492955 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   34.470 s (5%) | 559.719 ms |   3.32 GiB (1%) |    40602791 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 754.784 ms (5%) |            |  12.89 MiB (1%) |      257610 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   23.510 s (5%) | 441.861 ms |   3.17 GiB (1%) |    39547333 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   35.100 s (5%) | 650.112 ms |   3.61 GiB (1%) |    51180109 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 758.194 ms (5%) |            |  12.89 MiB (1%) |      257581 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   23.891 s (5%) | 504.573 ms |   3.21 GiB (1%) |    40261801 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   41.910 s (5%) | 549.734 ms |   3.38 GiB (1%) |    41763231 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 768.735 ms (5%) |            |  12.88 MiB (1%) |      257582 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.840 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  33.920 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   23.098 s (5%) | 373.128 ms |   3.07 GiB (1%) |    38474245 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   2.456 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 185.571 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   6.933 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   3.533 μs (5%) |            |   1.78 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 567.820 ms (5%) |            |   1.73 MiB (1%) |       13069 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  19.892 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   7.390 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
      Ubuntu 22.04.1 LTS
  uname: Linux 5.15.0-1033-azure #40-Ubuntu SMP Mon Jan 23 20:36:59 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz: 
              speed         user         nice          sys         idle          irq
       #1  2793 MHz      19094 s          0 s        433 s       7377 s          0 s
       #2  2793 MHz      14021 s          0 s        354 s      12500 s          0 s
  Memory: 6.781219482421875 GB (4248.9609375 MB free)
  Uptime: 2696.6 sec
  Load Avg:  1.77  1.43  1.29
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, icelake-server)
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
    Model name:                      Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz
    CPU family:                      6
    Model:                           106
    Thread(s) per core:              1
    Core(s) per socket:              2
    Socket(s):                       1
    Stepping:                        6
    BogoMIPS:                        5586.87
    Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm avx512f avx512dq rdseed adx smap clflushopt avx512cd avx512bw avx512vl xsaveopt xsavec xsaves md_clear
    Hypervisor vendor:               Microsoft
    Virtualization type:             full
    L1d cache:                       96 KiB (2 instances)
    L1i cache:                       64 KiB (2 instances)
    L2 cache:                        2.5 MiB (2 instances)
    L3 cache:                        48 MiB (1 instance)
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
| Brand              | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz           |
| Vendor             | :Intel                                                  |
| Architecture       | :UnknownIntel                                           |
| Model              | Family: 0x06, Model: 0x6a, Stepping: 0x06, Type: 0x00   |
| Cores              | 2 physical cores, 2 logical cores (on executing CPU)    |
|                    | No Hyperthreading hardware capability detected          |
| Clock Frequencies  | Not supported by CPU                                    |
| Data Cache         | Level 1:3 : (48, 1280, 49152) kbytes                    |
|                    | 64 byte cache line size                                 |
| Address Size       | 48 bits virtual, 46 bits physical                       |
| SIMD               | 512 bit = 64 byte max. SIMD vector size                 |
| Time Stamp Counter | TSC is accessible via `rdtsc`                           |
|                    | TSC increased at every clock cycle (non-invariant TSC)  |
| Perf. Monitoring   | Performance Monitoring Counters (PMC) are not supported |
| Hypervisor         | Yes, Microsoft                                          |

