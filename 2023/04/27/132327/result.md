# Benchmark result

* Pull request commit: [`67a7ffb6a44866a6212a3f4d62ff60ed3a1a585f`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/67a7ffb6a44866a6212a3f4d62ff60ed3a1a585f)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/238> (Bump version number to v1.0.0)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 27 Apr 2023 - 13:11
    - Baseline: 27 Apr 2023 - 13:22
* Package commits:
    - Target: 673677
    - Baseline: 619d88
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   | 0.91 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |                1.13 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              | 0.91 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             | 0.78 (5%) :white_check_mark: | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 0.21 (5%) :white_check_mark: | 0.01 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 0.59 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |                   0.99 (5%)  | 0.98 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |                   0.96 (5%)  | 0.98 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 0.67 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |                   0.98 (5%)  | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |                   0.96 (5%)  | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 0.71 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 0.79 (5%) :white_check_mark: |                   1.00 (1%)  |

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
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz      11030 s          0 s        330 s       9955 s          0 s
       #2  2593 MHz      13710 s          0 s        418 s       7154 s          0 s
  Memory: 6.781208038330078 GB (4019.9453125 MB free)
  Uptime: 2140.53 sec
  Load Avg:  1.72  1.39  1.19
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, skylake-avx512)
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
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz      13034 s          0 s        356 s      14943 s          0 s
       #2  2593 MHz      20564 s          0 s        560 s       7200 s          0 s
  Memory: 6.781208038330078 GB (4315.11328125 MB free)
  Uptime: 2844.73 sec
  Load Avg:  1.73  1.38  1.24
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, skylake-avx512)
  Threads: 2 on 2 virtual cores
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 27 Apr 2023 - 13:11
* Package commit: 673677
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.200 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    9.902 s (5%) |  41.123 ms | 588.11 MiB (1%) |    16557024 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 432.138 ms (5%) |            |   2.01 MiB (1%) |       20654 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   5.100 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    9.403 s (5%) |   5.748 ms | 201.61 MiB (1%) |     1433160 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 431.744 ms (5%) |            |   2.01 MiB (1%) |       20654 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.200 μs (5%) |            |  33.88 MiB (1%) |          64 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    9.777 s (5%) |  66.722 ms | 472.76 MiB (1%) |    11517215 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 439.917 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   8.000 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    9.792 s (5%) |   9.713 ms | 201.62 MiB (1%) |     1433286 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 445.654 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   27.776 s (5%) | 447.691 ms |   3.12 GiB (1%) |    38481037 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   38.784 s (5%) | 673.291 ms |   3.67 GiB (1%) |    55041029 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 446.678 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   27.764 s (5%) | 453.572 ms |   3.12 GiB (1%) |    38481026 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   38.493 s (5%) | 591.211 ms |   3.29 GiB (1%) |    39917149 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 463.091 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   27.755 s (5%) | 448.459 ms |   3.12 GiB (1%) |    38481049 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   38.648 s (5%) | 671.372 ms |   3.55 GiB (1%) |    50001196 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 527.723 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   27.720 s (5%) | 448.137 ms |   3.12 GiB (1%) |    38481034 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   38.299 s (5%) | 592.683 ms |   3.29 GiB (1%) |    39917264 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 540.667 ms (5%) |            |   2.37 MiB (1%) |       20801 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   2.278 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  41.826 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   27.436 s (5%) | 411.521 ms |   3.07 GiB (1%) |    38439432 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   2.911 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 193.997 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   6.335 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   3.800 μs (5%) |            |   1.78 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 567.503 ms (5%) |            |   1.73 MiB (1%) |       13069 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  19.676 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   7.489 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz      11030 s          0 s        330 s       9955 s          0 s
       #2  2593 MHz      13710 s          0 s        418 s       7154 s          0 s
  Memory: 6.781208038330078 GB (4019.9453125 MB free)
  Uptime: 2140.53 sec
  Load Avg:  1.72  1.39  1.19
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, skylake-avx512)
  Threads: 2 on 2 virtual cores
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 27 Apr 2023 - 13:22
* Package commit: 619d88
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.800 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |   10.262 s (5%) | 140.625 ms | 588.11 MiB (1%) |    16557031 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 439.046 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.500 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    9.758 s (5%) |  24.614 ms | 201.52 MiB (1%) |     1432067 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 445.711 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |  10.100 μs (5%) |            |  33.88 MiB (1%) |          64 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    9.936 s (5%) | 130.892 ms | 472.76 MiB (1%) |    11517204 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 443.096 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   7.900 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    9.635 s (5%) |   9.210 ms | 201.62 MiB (1%) |     1433267 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 434.716 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   27.941 s (5%) | 487.318 ms |   3.13 GiB (1%) |    38626040 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   49.906 s (5%) | 881.857 ms |   3.78 GiB (1%) |    57045336 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        |    2.100 s (5%) |  71.400 ms | 213.31 MiB (1%) |     4416187 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   27.757 s (5%) | 495.560 ms |   3.12 GiB (1%) |    38492955 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   39.506 s (5%) | 620.175 ms |   3.32 GiB (1%) |    40602767 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 784.127 ms (5%) |            |  12.89 MiB (1%) |      257609 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   28.127 s (5%) | 510.997 ms |   3.17 GiB (1%) |    39547134 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   40.294 s (5%) | 752.529 ms |   3.61 GiB (1%) |    51180102 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 788.510 ms (5%) |  22.688 ms |  12.89 MiB (1%) |      257580 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   28.389 s (5%) | 545.753 ms |   3.21 GiB (1%) |    40260055 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   40.076 s (5%) | 625.555 ms |   3.38 GiB (1%) |    41763243 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 763.620 ms (5%) |            |  12.88 MiB (1%) |      257583 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   2.289 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  41.811 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   27.445 s (5%) | 443.265 ms |   3.07 GiB (1%) |    38474245 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   2.967 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 245.945 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   6.510 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   3.812 μs (5%) |            |   1.78 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 580.890 ms (5%) |            |   1.73 MiB (1%) |       13069 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  19.739 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   7.688 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz      13034 s          0 s        356 s      14943 s          0 s
       #2  2593 MHz      20564 s          0 s        560 s       7200 s          0 s
  Memory: 6.781208038330078 GB (4315.11328125 MB free)
  Uptime: 2844.73 sec
  Load Avg:  1.73  1.38  1.24
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, skylake-avx512)
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
    Model name:                      Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz
    CPU family:                      6
    Model:                           85
    Thread(s) per core:              1
    Core(s) per socket:              2
    Socket(s):                       1
    Stepping:                        7
    BogoMIPS:                        5187.81
    Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm avx512f avx512dq rdseed adx smap clflushopt avx512cd avx512bw avx512vl xsaveopt xsavec xsaves md_clear
    Hypervisor vendor:               Microsoft
    Virtualization type:             full
    L1d cache:                       64 KiB (2 instances)
    L1i cache:                       64 KiB (2 instances)
    L2 cache:                        2 MiB (2 instances)
    L3 cache:                        35.8 MiB (1 instance)
    NUMA node(s):                    1
    NUMA node0 CPU(s):               0,1
    Vulnerability Itlb multihit:     KVM: Mitigation: VMX unsupported
    Vulnerability L1tf:              Mitigation; PTE Inversion
    Vulnerability Mds:               Mitigation; Clear CPU buffers; SMT Host state unknown
    Vulnerability Meltdown:          Mitigation; PTI
    Vulnerability Mmio stale data:   Vulnerable: Clear CPU buffers attempted, no microcode; SMT Host state unknown
    Vulnerability Retbleed:          Vulnerable
    Vulnerability Spec store bypass: Vulnerable
    Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:        Mitigation; Retpolines, STIBP disabled, RSB filling, PBRSB-eIBRS Not affected
    Vulnerability Srbds:             Not affected
    Vulnerability Tsx async abort:   Mitigation; Clear CPU buffers; SMT Host state unknown
    

| Cpu Property       | Value                                                   |
|:------------------ |:------------------------------------------------------- |
| Brand              | Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz          |
| Vendor             | :Intel                                                  |
| Architecture       | :Skylake                                                |
| Model              | Family: 0x06, Model: 0x55, Stepping: 0x07, Type: 0x00   |
| Cores              | 2 physical cores, 2 logical cores (on executing CPU)    |
|                    | No Hyperthreading hardware capability detected          |
| Clock Frequencies  | Not supported by CPU                                    |
| Data Cache         | Level 1:3 : (32, 1024, 36608) kbytes                    |
|                    | 64 byte cache line size                                 |
| Address Size       | 48 bits virtual, 46 bits physical                       |
| SIMD               | 512 bit = 64 byte max. SIMD vector size                 |
| Time Stamp Counter | TSC is accessible via `rdtsc`                           |
|                    | TSC increased at every clock cycle (non-invariant TSC)  |
| Perf. Monitoring   | Performance Monitoring Counters (PMC) are not supported |
| Hypervisor         | Yes, Microsoft                                          |

