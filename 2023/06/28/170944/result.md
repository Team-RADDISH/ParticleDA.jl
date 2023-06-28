# Benchmark result

* Pull request commit: [`fc9becdaaed4bbe4923481bdecc39e2c5b021862`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/fc9becdaaed4bbe4923481bdecc39e2c5b021862)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/247> (fix: Replacing Threads.@threads :static)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 28 Jun 2023 - 16:57
    - Baseline: 28 Jun 2023 - 17:09
* Package commits:
    - Target: 58e275
    - Baseline: a0e7ea
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |                1.09 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           | 0.74 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      |                1.12 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |                1.29 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |                1.11 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |                1.13 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |                1.10 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` |                1.11 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |                1.09 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |                1.11 (5%) :x: |                   1.00 (1%)  |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             | 0.83 (5%) :white_check_mark: | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 0.22 (5%) :white_check_mark: | 0.01 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 0.65 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |                   0.99 (5%)  | 0.98 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |                   0.96 (5%)  | 0.98 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 0.63 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |                   0.97 (5%)  | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |                   0.98 (5%)  | 0.97 (1%) :white_check_mark: |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 0.57 (5%) :white_check_mark: | 0.18 (1%) :white_check_mark: |
| `["Model interface", "update_state_stochastic!"]`                                                         |                1.06 (5%) :x: |                   1.00 (1%)  |

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
  uname: Linux 5.15.0-1040-azure #47-Ubuntu SMP Thu Jun 1 19:38:24 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz      12706 s          0 s        386 s       8537 s          0 s
       #2  2593 MHz      12012 s          0 s        394 s       9225 s          0 s
  Memory: 6.7694854736328125 GB (4448.69921875 MB free)
  Uptime: 2171.09 sec
  Load Avg:  1.72  1.38  1.19
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
  uname: Linux 5.15.0-1040-azure #47-Ubuntu SMP Thu Jun 1 19:38:24 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz      18513 s          0 s        511 s       9846 s          0 s
       #2  2593 MHz      15217 s          0 s        469 s      13180 s          0 s
  Memory: 6.7694854736328125 GB (4213.01171875 MB free)
  Uptime: 2895.73 sec
  Load Avg:  1.83  1.41  1.25
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, skylake-avx512)
  Threads: 2 on 2 virtual cores
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 28 Jun 2023 - 16:57
* Package commit: 58e275
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   7.100 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |   10.711 s (5%) | 129.768 ms | 588.12 MiB (1%) |    16557292 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 471.941 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   5.800 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |   10.476 s (5%) |   2.741 ms | 201.62 MiB (1%) |     1433415 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 462.153 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |  10.600 μs (5%) |            |  33.88 MiB (1%) |          64 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |   10.729 s (5%) |  53.429 ms | 472.77 MiB (1%) |    11517447 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 453.437 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   8.700 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |   10.667 s (5%) |   4.661 ms | 201.63 MiB (1%) |     1433509 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 444.813 ms (5%) |            |   2.01 MiB (1%) |       20665 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   28.274 s (5%) | 408.201 ms |   3.12 GiB (1%) |    38481037 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   39.500 s (5%) | 716.036 ms |   3.67 GiB (1%) |    55041504 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        | 483.747 ms (5%) |            |   2.37 MiB (1%) |       20824 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   28.242 s (5%) | 408.137 ms |   3.12 GiB (1%) |    38481026 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   39.163 s (5%) | 585.982 ms |   3.29 GiB (1%) |    39917625 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 474.542 ms (5%) |            |   2.37 MiB (1%) |       20825 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   28.261 s (5%) | 408.305 ms |   3.12 GiB (1%) |    38481049 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   39.307 s (5%) | 593.780 ms |   3.55 GiB (1%) |    50001669 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 472.843 ms (5%) |            |   2.37 MiB (1%) |       20824 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   28.242 s (5%) | 407.599 ms |   3.12 GiB (1%) |    38481034 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   39.354 s (5%) | 584.837 ms |   3.29 GiB (1%) |    39917731 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 426.115 ms (5%) |            |   2.37 MiB (1%) |       20824 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   2.289 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  42.424 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   27.990 s (5%) | 358.924 ms |   3.07 GiB (1%) |    38439432 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   2.900 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 256.642 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   6.264 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   3.775 μs (5%) |            |   1.78 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 559.037 ms (5%) |            |   1.73 MiB (1%) |       13069 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  19.843 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   7.163 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
  uname: Linux 5.15.0-1040-azure #47-Ubuntu SMP Thu Jun 1 19:38:24 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz      12706 s          0 s        386 s       8537 s          0 s
       #2  2593 MHz      12012 s          0 s        394 s       9225 s          0 s
  Memory: 6.7694854736328125 GB (4448.69921875 MB free)
  Uptime: 2171.09 sec
  Load Avg:  1.72  1.38  1.19
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, skylake-avx512)
  Threads: 2 on 2 virtual cores
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 28 Jun 2023 - 17:9
* Package commit: a0e7ea
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
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "init_filter"]`                                   |   6.500 μs (5%) |            |  33.88 MiB (1%) |          52 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                           |   14.510 s (5%) |  98.013 ms | 588.11 MiB (1%) |    16557024 |
| `["Filtering (BootstrapFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`      | 421.627 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "init_filter"]`                                         |   4.500 μs (5%) |            |  32.05 MiB (1%) |          41 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "run_particle_filter"]`                                 |    9.420 s (5%) |            | 201.52 MiB (1%) |     1431921 |
| `["Filtering (BootstrapFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`            | 451.143 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                              |   9.400 μs (5%) |            |  33.88 MiB (1%) |          64 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                      |    9.791 s (5%) | 126.009 ms | 472.76 MiB (1%) |    11517155 |
| `["Filtering (BootstrapFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]` | 410.349 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "init_filter"]`                                    |   8.000 μs (5%) |            |  32.05 MiB (1%) |          49 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                            |    9.623 s (5%) |   7.995 ms | 201.62 MiB (1%) |     1433251 |
| `["Filtering (BootstrapFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`       | 463.360 ms (5%) |            |   2.01 MiB (1%) |       20653 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "init_filter"]`                                     |   28.395 s (5%) | 437.407 ms |   3.13 GiB (1%) |    38626040 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "run_particle_filter"]`                             |   47.354 s (5%) | 794.887 ms |   3.78 GiB (1%) |    57045546 |
| `["Filtering (OptimalFilter, MeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`        |    2.249 s (5%) |  27.953 ms | 213.30 MiB (1%) |     4416183 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "init_filter"]`                                           |   28.282 s (5%) | 422.493 ms |   3.12 GiB (1%) |    38492955 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "run_particle_filter"]`                                   |   39.425 s (5%) | 569.667 ms |   3.32 GiB (1%) |    40603001 |
| `["Filtering (OptimalFilter, MeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`              | 728.076 ms (5%) |            |  12.89 MiB (1%) |      257609 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "init_filter"]`                                |   28.592 s (5%) | 462.235 ms |   3.17 GiB (1%) |    39547289 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "run_particle_filter"]`                        |   40.848 s (5%) | 647.399 ms |   3.61 GiB (1%) |    51180314 |
| `["Filtering (OptimalFilter, NaiveMeanAndVarSummaryStat)", "sample_proposal_and_compute_log_weights!"]`   | 753.736 ms (5%) |            |  12.88 MiB (1%) |      257580 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "init_filter"]`                                      |   28.983 s (5%) | 518.736 ms |   3.21 GiB (1%) |    40260253 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "run_particle_filter"]`                              |   40.025 s (5%) | 614.126 ms |   3.38 GiB (1%) |    41763426 |
| `["Filtering (OptimalFilter, NaiveMeanSummaryStat)", "sample_proposal_and_compute_log_weights!"]`         | 753.110 ms (5%) |            |  12.88 MiB (1%) |      257582 |
| `["Model interface", "get_covariance_observation_noise"]`                                                 |   2.278 μs (5%) |            |  576 bytes (1%) |           1 |
| `["Model interface", "get_covariance_observation_observation_given_previous_state"]`                      |  42.481 ms (5%) |            |   3.14 MiB (1%) |       41542 |
| `["Model interface", "get_covariance_state_observation_given_previous_state"]`                            |   28.025 s (5%) | 382.797 ms |   3.07 GiB (1%) |    38472971 |
| `["Model interface", "get_log_density_observation_given_state!"]`                                         |   2.844 μs (5%) |            |   1.22 KiB (1%) |           4 |
| `["Model interface", "get_observation_mean_given_state!"]`                                                | 257.726 ns (5%) |            |   96 bytes (1%) |           2 |
| `["Model interface", "sample_initial_state!"]`                                                            |   6.299 ms (5%) |            |   4.05 KiB (1%) |          46 |
| `["Model interface", "sample_observation_given_state!"]`                                                  |   3.750 μs (5%) |            |   1.78 KiB (1%) |           5 |
| `["Model interface", "simulate_observations_from_model"]`                                                 | 548.998 ms (5%) |            |   1.73 MiB (1%) |       13069 |
| `["Model interface", "update_state_deterministic!"]`                                                      |  19.468 ms (5%) |            |  35.25 KiB (1%) |         602 |
| `["Model interface", "update_state_stochastic!"]`                                                         |   6.776 ms (5%) |            |   3.95 KiB (1%) |          44 |

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
  uname: Linux 5.15.0-1040-azure #47-Ubuntu SMP Thu Jun 1 19:38:24 UTC 2023 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz      18513 s          0 s        511 s       9846 s          0 s
       #2  2593 MHz      15217 s          0 s        469 s      13180 s          0 s
  Memory: 6.7694854736328125 GB (4213.01171875 MB free)
  Uptime: 2895.73 sec
  Load Avg:  1.83  1.41  1.25
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

