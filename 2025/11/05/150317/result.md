# Benchmark result

* Pull request commit: [`65eeb8c83849ef51732a4b0687c927bb4b9b2aea`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/65eeb8c83849ef51732a4b0687c927bb4b9b2aea)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/302> ([CI] Save cache on failures)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 5 Nov 2025 - 14:50
    - Baseline: 5 Nov 2025 - 15:03
* Package commits:
    - Target: d29c671
    - Baseline: e314fbd
* Julia commits:
    - Target: bd47eca
    - Baseline: bd47eca
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           | 0.87 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 0.88 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |                1.07 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            |                1.11 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |                1.13 (5%) :x: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 0.90 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            | 0.88 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 0.79 (5%) :white_check_mark: |   1.00 (1%)  |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 0.91 (5%) :white_check_mark: |   1.00 (1%)  |

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
Julia Version 1.10.2
Commit bd47eca2c8a (2024-03-01 10:14 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 24.04.3 LTS
  uname: Linux 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1  3248 MHz       4313 s          0 s        297 s       7009 s          0 s
       #2  3336 MHz       5081 s          0 s        459 s       6087 s          0 s
       #3  3204 MHz       3865 s          0 s        328 s       7434 s          0 s
       #4  3244 MHz       3970 s          0 s        379 s       7276 s          0 s
  Memory: 15.620681762695312 GB (13813.171875 MB free)
  Uptime: 1165.81 sec
  Load Avg:  1.67  1.59  1.23
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-15.0.7 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

### Baseline
```
Julia Version 1.10.2
Commit bd47eca2c8a (2024-03-01 10:14 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 24.04.3 LTS
  uname: Linux 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1  3248 MHz       6277 s          0 s        474 s      12594 s          0 s
       #2  3246 MHz       7682 s          0 s        705 s      10970 s          0 s
       #3  3199 MHz       7594 s          0 s        551 s      11215 s          0 s
       #4  3241 MHz       6926 s          0 s        606 s      11826 s          0 s
  Memory: 15.620681762695312 GB (13889.06640625 MB free)
  Uptime: 1939.88 sec
  Load Avg:  1.9  1.67  1.45
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-15.0.7 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 14:50
* Package commit: d29c671
* Julia commit: bd47eca
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   5.591 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    6.842 s (5%) | 182.862 ms | 430.66 MiB (1%) |    11484838 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 301.057 ms (5%) |            |   1.85 MiB (1%) |       19289 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.408 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    7.478 s (5%) |   1.604 ms | 197.92 MiB (1%) |     1400798 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 321.564 ms (5%) |            |   1.85 MiB (1%) |       19289 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   8.126 μs (5%) |            |  33.88 MiB (1%) |          58 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    7.359 s (5%) |   1.678 ms | 199.94 MiB (1%) |     1404587 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 288.463 ms (5%) |            |   1.85 MiB (1%) |       19289 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   6.973 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    6.546 s (5%) |            | 198.00 MiB (1%) |     1401736 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 305.817 ms (5%) |            |   1.85 MiB (1%) |       19289 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    4.966 s (5%) | 201.744 ms |   3.08 GiB (1%) |    38481050 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.490 s (5%) | 478.071 ms |   3.47 GiB (1%) |    49968334 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 319.857 ms (5%) |            |   2.19 MiB (1%) |       19410 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    4.957 s (5%) | 204.769 ms |   3.08 GiB (1%) |    38481039 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   12.422 s (5%) | 461.240 ms |   3.25 GiB (1%) |    39885238 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 307.912 ms (5%) |            |   2.19 MiB (1%) |       19410 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    4.950 s (5%) | 208.786 ms |   3.08 GiB (1%) |    38481058 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.376 s (5%) | 445.554 ms |   3.25 GiB (1%) |    39888055 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 324.750 ms (5%) |            |   2.19 MiB (1%) |       19410 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    4.930 s (5%) | 190.567 ms |   3.08 GiB (1%) |    38481045 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   12.532 s (5%) | 484.769 ms |   3.25 GiB (1%) |    39885202 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 366.356 ms (5%) |            |   2.19 MiB (1%) |       19410 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.405 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   5.973 ms (5%) |            |   2.51 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    4.680 s (5%) | 152.571 ms |   3.03 GiB (1%) |    38439432 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.771 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 147.272 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.119 ms (5%) |            |  192 bytes (1%) |           4 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   2.015 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 366.674 ms (5%) |            |   1.64 MiB (1%) |       12167 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.510 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.308 ms (5%) |            |   96 bytes (1%) |           2 |

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
Julia Version 1.10.2
Commit bd47eca2c8a (2024-03-01 10:14 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 24.04.3 LTS
  uname: Linux 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1  3248 MHz       4313 s          0 s        297 s       7009 s          0 s
       #2  3336 MHz       5081 s          0 s        459 s       6087 s          0 s
       #3  3204 MHz       3865 s          0 s        328 s       7434 s          0 s
       #4  3244 MHz       3970 s          0 s        379 s       7276 s          0 s
  Memory: 15.620681762695312 GB (13813.171875 MB free)
  Uptime: 1165.81 sec
  Load Avg:  1.67  1.59  1.23
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-15.0.7 (ORCJIT, znver3)
Threads: 2 default, 0 interactive, 1 GC (on 4 virtual cores)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 5 Nov 2025 - 15:03
* Package commit: e314fbd
* Julia commit: bd47eca
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   5.620 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |    7.844 s (5%) |  48.230 ms | 430.66 MiB (1%) |    11484918 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 342.796 ms (5%) |            |   1.85 MiB (1%) |       19289 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.248 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    7.019 s (5%) | 135.137 ms | 197.92 MiB (1%) |     1400798 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 288.854 ms (5%) |            |   1.85 MiB (1%) |       19289 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   8.305 μs (5%) |            |  33.88 MiB (1%) |          58 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    6.522 s (5%) |   1.559 ms | 199.94 MiB (1%) |     1404590 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 320.674 ms (5%) |            |   1.85 MiB (1%) |       19289 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   6.783 μs (5%) |            |  32.05 MiB (1%) |          45 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    7.440 s (5%) |  19.387 ms | 198.00 MiB (1%) |     1401738 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 293.803 ms (5%) |            |   1.85 MiB (1%) |       19289 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |    4.866 s (5%) | 174.110 ms |   3.08 GiB (1%) |    38481050 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   12.415 s (5%) | 418.296 ms |   3.47 GiB (1%) |    49968253 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 334.275 ms (5%) |            |   2.19 MiB (1%) |       19410 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |    4.758 s (5%) | 158.257 ms |   3.08 GiB (1%) |    38481039 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   12.131 s (5%) | 401.734 ms |   3.25 GiB (1%) |    39885238 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 310.069 ms (5%) |            |   2.19 MiB (1%) |       19410 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |    4.830 s (5%) | 171.782 ms |   3.08 GiB (1%) |    38481058 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   12.343 s (5%) | 386.488 ms |   3.25 GiB (1%) |    39888055 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 410.703 ms (5%) |            |   2.19 MiB (1%) |       19410 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |    4.782 s (5%) | 158.805 ms |   3.08 GiB (1%) |    38481045 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   12.324 s (5%) | 438.033 ms |   3.25 GiB (1%) |    39885203 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 400.583 ms (5%) |            |   2.19 MiB (1%) |       19410 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   1.407 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |   6.069 ms (5%) |            |   2.51 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |    4.616 s (5%) | 120.247 ms |   3.03 GiB (1%) |    38439432 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   1.755 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 145.838 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   4.066 ms (5%) |            |  192 bytes (1%) |           4 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   2.019 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 350.581 ms (5%) |            |   1.64 MiB (1%) |       12167 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  12.447 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   4.235 ms (5%) |            |   96 bytes (1%) |           2 |

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
Julia Version 1.10.2
Commit bd47eca2c8a (2024-03-01 10:14 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Ubuntu 24.04.3 LTS
  uname: Linux 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64
  CPU: AMD EPYC 7763 64-Core Processor: 
              speed         user         nice          sys         idle          irq
       #1  3248 MHz       6277 s          0 s        474 s      12594 s          0 s
       #2  3246 MHz       7682 s          0 s        705 s      10970 s          0 s
       #3  3199 MHz       7594 s          0 s        551 s      11215 s          0 s
       #4  3241 MHz       6926 s          0 s        606 s      11826 s          0 s
  Memory: 15.620681762695312 GB (13889.06640625 MB free)
  Uptime: 1939.88 sec
  Load Avg:  1.9  1.67  1.45
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-15.0.7 (ORCJIT, znver3)
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

