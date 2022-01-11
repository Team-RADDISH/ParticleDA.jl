# Benchmark result

* Pull request commit: [`02bb2dd9bc0a2ae32c2501578ce00adac9142507`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/02bb2dd9bc0a2ae32c2501578ce00adac9142507)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/206> (Add input files to repository)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 11 Jan 2022 - 14:05
    - Baseline: 11 Jan 2022 - 14:08
* Package commits:
    - Target: ce0d96
    - Baseline: c130ec
* Julia commits:
    - Target: 905826
    - Baseline: 905826
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

| ID                                           | time ratio                   | memory ratio                 |
|----------------------------------------------|------------------------------|------------------------------|
| `["BootstrapFilter", "init_filter"]`         |                1.41 (5%) :x: |                   1.00 (1%)  |
| `["OptimalFilter", "init_filter"]`           | 0.01 (5%) :white_check_mark: | 0.12 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.83 (5%) :white_check_mark: | 0.84 (1%) :white_check_mark: |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo

### Target
```
Julia Version 1.6.5
Commit 9058264a69 (2021-12-19 12:30 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.11.0-1022-azure #23~20.04.1-Ubuntu SMP Fri Nov 19 10:20:52 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       3744 s          1 s        269 s       1948 s          0 s
       #2  2294 MHz       3797 s          1 s        266 s       1917 s          0 s
       
  Memory: 6.788982391357422 GB (1135.33984375 MB free)
  Uptime: 603.54 sec
  Load Avg:  1.84  1.43  0.78
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, broadwell)
```

### Baseline
```
Julia Version 1.6.5
Commit 9058264a69 (2021-12-19 12:30 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.11.0-1022-azure #23~20.04.1-Ubuntu SMP Fri Nov 19 10:20:52 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       4853 s          1 s        312 s       2709 s          0 s
       #2  2294 MHz       5206 s          1 s        306 s       2382 s          0 s
       
  Memory: 6.788982391357422 GB (1796.0703125 MB free)
  Uptime: 795.23 sec
  Load Avg:  1.44  1.39  0.89
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, broadwell)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 11 Jan 2022 - 14:5
* Package commit: ce0d96
* Julia commit: 905826
* Julia command flags: None
* Environment variables: `JULIA_NUM_THREADS => 2`

## Results
Below is a table of this job's results, obtained by running the benchmarks.
The values listed in the `ID` column have the structure `[parent_group, child_group, ..., key]`, and can be used to
index into the BaseBenchmarks suite to retrieve the corresponding benchmarks.
The percentages accompanying time and memory values in the below table are noise tolerances. The "true"
time/memory value for a given benchmark is expected to fall within this percentage of the reported value.
An empty cell means that the value was zero.

| ID                                           | time            | GC time    | memory          | allocations |
|----------------------------------------------|----------------:|-----------:|----------------:|------------:|
| `["BootstrapFilter", "init_filter"]`         |   4.100 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   14.166 s (5%) |   4.791 ms | 223.73 MiB (1%) |     1022417 |
| `["OptimalFilter", "init_filter"]`           | 106.437 ms (5%) |            | 123.58 MiB (1%) |         312 |
| `["OptimalFilter", "run_particle_filter"]`   |   47.290 s (5%) | 396.393 ms |   6.06 GiB (1%) |     1043009 |
| `["base", "get_log_weights!"]`               |   1.760 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   6.345 ms (5%) |            |   1.02 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.400 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 431.472 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 159.061 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 479.011 ms (5%) |            |   1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 375.188 ms (5%) |            |   1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  26.796 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.5
Commit 9058264a69 (2021-12-19 12:30 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.11.0-1022-azure #23~20.04.1-Ubuntu SMP Fri Nov 19 10:20:52 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       3744 s          1 s        269 s       1948 s          0 s
       #2  2294 MHz       3797 s          1 s        266 s       1917 s          0 s
       
  Memory: 6.788982391357422 GB (1135.33984375 MB free)
  Uptime: 603.54 sec
  Load Avg:  1.84  1.43  0.78
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, broadwell)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 11 Jan 2022 - 14:8
* Package commit: c130ec
* Julia commit: 905826
* Julia command flags: None
* Environment variables: `JULIA_NUM_THREADS => 2`

## Results
Below is a table of this job's results, obtained by running the benchmarks.
The values listed in the `ID` column have the structure `[parent_group, child_group, ..., key]`, and can be used to
index into the BaseBenchmarks suite to retrieve the corresponding benchmarks.
The percentages accompanying time and memory values in the below table are noise tolerances. The "true"
time/memory value for a given benchmark is expected to fall within this percentage of the reported value.
An empty cell means that the value was zero.

| ID                                           | time            | GC time    | memory          | allocations |
|----------------------------------------------|----------------:|-----------:|----------------:|------------:|
| `["BootstrapFilter", "init_filter"]`         |   2.900 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   14.121 s (5%) |  24.128 ms | 223.65 MiB (1%) |     1021780 |
| `["OptimalFilter", "init_filter"]`           |    8.931 s (5%) | 218.422 ms |   1.01 GiB (1%) |    12252186 |
| `["OptimalFilter", "run_particle_filter"]`   |   57.008 s (5%) | 548.689 ms |   7.22 GiB (1%) |    19177636 |
| `["base", "get_log_weights!"]`               |   1.770 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   6.282 ms (5%) |            |   1.02 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.400 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 418.279 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 160.498 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 479.748 ms (5%) |            |   1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 368.160 ms (5%) |            |   1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  26.032 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.5
Commit 9058264a69 (2021-12-19 12:30 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.11.0-1022-azure #23~20.04.1-Ubuntu SMP Fri Nov 19 10:20:52 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       4853 s          1 s        312 s       2709 s          0 s
       #2  2294 MHz       5206 s          1 s        306 s       2382 s          0 s
       
  Memory: 6.788982391357422 GB (1796.0703125 MB free)
  Uptime: 795.23 sec
  Load Avg:  1.44  1.39  0.89
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, broadwell)
```

---
# Runtime information
| Runtime Info | |
|:--|:--|
| BLAS #threads | 2 |
| `BLAS.vendor()` | `openblas64` |
| `Sys.CPU_THREADS` | 2 |

`lscpu` output:

    Architecture:                    x86_64
    CPU op-mode(s):                  32-bit, 64-bit
    Byte Order:                      Little Endian
    Address sizes:                   46 bits physical, 48 bits virtual
    CPU(s):                          2
    On-line CPU(s) list:             0,1
    Thread(s) per core:              1
    Core(s) per socket:              2
    Socket(s):                       1
    NUMA node(s):                    1
    Vendor ID:                       GenuineIntel
    CPU family:                      6
    Model:                           79
    Model name:                      Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz
    Stepping:                        1
    CPU MHz:                         2294.685
    BogoMIPS:                        4589.37
    Hypervisor vendor:               Microsoft
    Virtualization type:             full
    L1d cache:                       64 KiB
    L1i cache:                       64 KiB
    L2 cache:                        512 KiB
    L3 cache:                        50 MiB
    NUMA node0 CPU(s):               0,1
    Vulnerability Itlb multihit:     KVM: Mitigation: VMX unsupported
    Vulnerability L1tf:              Mitigation; PTE Inversion
    Vulnerability Mds:               Mitigation; Clear CPU buffers; SMT Host state unknown
    Vulnerability Meltdown:          Mitigation; PTI
    Vulnerability Spec store bypass: Vulnerable
    Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:        Mitigation; Full generic retpoline, STIBP disabled, RSB filling
    Vulnerability Srbds:             Not affected
    Vulnerability Tsx async abort:   Mitigation; Clear CPU buffers; SMT Host state unknown
    Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm rdseed adx smap xsaveopt md_clear
    

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

