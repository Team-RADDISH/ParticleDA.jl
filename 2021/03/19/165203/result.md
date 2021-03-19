# Benchmark result

* Pull request commit: [`d8fc06c9c65d3b00a67b4e676fda90a0702512db`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/d8fc06c9c65d3b00a67b4e676fda90a0702512db)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/163> (WIP: Dump particle states to disk upon request)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 19 Mar 2021 - 16:48
    - Baseline: 19 Mar 2021 - 16:51
* Package commits:
    - Target: 9f3730
    - Baseline: acf19d
* Julia commits:
    - Target: 23267f
    - Baseline: 23267f
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
| `["BootstrapFilter", "init_filter"]`         |                1.26 (5%) :x: |                   1.00 (1%)  |
| `["BootstrapFilter", "run_particle_filter"]` | 0.63 (5%) :white_check_mark: | 0.14 (1%) :white_check_mark: |
| `["OptimalFilter", "init_filter"]`           | 0.01 (5%) :white_check_mark: | 0.10 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.83 (5%) :white_check_mark: | 0.80 (1%) :white_check_mark: |
| `["base", "get_mean_and_var!"]`              | 0.91 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["base", "normalized_exp!"]`                | 0.92 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["base", "update_truth!"]`                  |                1.29 (5%) :x: |                   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo

### Target
```
Julia Version 1.6.0-rc3
Commit 23267f0d46 (2021-03-16 17:04 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1040-azure #42-Ubuntu SMP Fri Feb 5 15:39:06 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2397 MHz       4436 s          1 s        259 s       1144 s          0 s
       #2  2397 MHz       3800 s          1 s        247 s       1861 s          0 s
       
  Memory: 6.7648773193359375 GB (765.0625 MB free)
  Uptime: 602.0 sec
  Load Avg:  1.68  1.47  0.84
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

### Baseline
```
Julia Version 1.6.0-rc3
Commit 23267f0d46 (2021-03-16 17:04 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1040-azure #42-Ubuntu SMP Fri Feb 5 15:39:06 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2397 MHz       5798 s          1 s        290 s       1761 s          0 s
       #2  2397 MHz       4994 s          1 s        297 s       2621 s          0 s
       
  Memory: 6.7648773193359375 GB (2207.13671875 MB free)
  Uptime: 804.0 sec
  Load Avg:  1.35  1.36  0.93
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 19 Mar 2021 - 16:48
* Package commit: 9f3730
* Julia commit: 23267f
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
| `["BootstrapFilter", "init_filter"]`         |   4.800 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   19.163 s (5%) |   5.269 ms | 167.59 MiB (1%) |      860878 |
| `["OptimalFilter", "init_filter"]`           | 112.263 ms (5%) |            | 123.58 MiB (1%) |         313 |
| `["OptimalFilter", "run_particle_filter"]`   |   52.244 s (5%) | 423.794 ms |   6.01 GiB (1%) |      881461 |
| `["base", "get_log_weights!"]`               |   2.000 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   8.165 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.800 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 435.374 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 165.681 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 725.928 ms (5%) |            |   1.59 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 321.375 ms (5%) |            |   1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  43.024 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.0-rc3
Commit 23267f0d46 (2021-03-16 17:04 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1040-azure #42-Ubuntu SMP Fri Feb 5 15:39:06 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2397 MHz       4436 s          1 s        259 s       1144 s          0 s
       #2  2397 MHz       3800 s          1 s        247 s       1861 s          0 s
       
  Memory: 6.7648773193359375 GB (765.0625 MB free)
  Uptime: 602.0 sec
  Load Avg:  1.68  1.47  0.84
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 19 Mar 2021 - 16:51
* Package commit: acf19d
* Julia commit: 23267f
* Julia command flags: None
* Environment variables: `JULIA_NUM_THREADS => 2`

## Results
Below is a table of this job's results, obtained by running the benchmarks.
The values listed in the `ID` column have the structure `[parent_group, child_group, ..., key]`, and can be used to
index into the BaseBenchmarks suite to retrieve the corresponding benchmarks.
The percentages accompanying time and memory values in the below table are noise tolerances. The "true"
time/memory value for a given benchmark is expected to fall within this percentage of the reported value.
An empty cell means that the value was zero.

| ID                                           | time            | GC time    | memory         | allocations |
|----------------------------------------------|----------------:|-----------:|---------------:|------------:|
| `["BootstrapFilter", "init_filter"]`         |   3.800 μs (5%) |            | 33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   30.208 s (5%) | 244.095 ms |  1.17 GiB (1%) |    14824279 |
| `["OptimalFilter", "init_filter"]`           |   10.697 s (5%) | 268.836 ms |  1.21 GiB (1%) |    14545048 |
| `["OptimalFilter", "run_particle_filter"]`   |   63.254 s (5%) | 774.164 ms |  7.51 GiB (1%) |    23119071 |
| `["base", "get_log_weights!"]`               |   2.000 μs (5%) |            |                |             |
| `["base", "get_mean_and_var!"]`              |   8.960 ms (5%) |            |  1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.800 ns (5%) |            |                |             |
| `["base", "normalized_exp!"]`                | 471.232 ns (5%) |            |                |             |
| `["base", "resample!"]`                      | 165.811 ns (5%) |            | 336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 724.343 ms (5%) |            |  1.59 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 315.737 ms (5%) |            |  1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  33.407 ms (5%) |            |                |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.0-rc3
Commit 23267f0d46 (2021-03-16 17:04 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1040-azure #42-Ubuntu SMP Fri Feb 5 15:39:06 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2397 MHz       5798 s          1 s        290 s       1761 s          0 s
       #2  2397 MHz       4994 s          1 s        297 s       2621 s          0 s
       
  Memory: 6.7648773193359375 GB (2207.13671875 MB free)
  Uptime: 804.0 sec
  Load Avg:  1.35  1.36  0.93
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
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
    Address sizes:                   44 bits physical, 48 bits virtual
    CPU(s):                          2
    On-line CPU(s) list:             0,1
    Thread(s) per core:              1
    Core(s) per socket:              2
    Socket(s):                       1
    NUMA node(s):                    1
    Vendor ID:                       GenuineIntel
    CPU family:                      6
    Model:                           63
    Model name:                      Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz
    Stepping:                        2
    CPU MHz:                         2397.222
    BogoMIPS:                        4794.44
    Hypervisor vendor:               Microsoft
    Virtualization type:             full
    L1d cache:                       64 KiB
    L1i cache:                       64 KiB
    L2 cache:                        512 KiB
    L3 cache:                        30 MiB
    NUMA node0 CPU(s):               0,1
    Vulnerability Itlb multihit:     KVM: Vulnerable
    Vulnerability L1tf:              Mitigation; PTE Inversion
    Vulnerability Mds:               Mitigation; Clear CPU buffers; SMT Host state unknown
    Vulnerability Meltdown:          Mitigation; PTI
    Vulnerability Spec store bypass: Vulnerable
    Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:        Mitigation; Full generic retpoline, STIBP disabled, RSB filling
    Vulnerability Srbds:             Not affected
    Vulnerability Tsx async abort:   Not affected
    Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm invpcid_single pti fsgsbase bmi1 avx2 smep bmi2 erms invpcid xsaveopt md_clear
    

| Cpu Property       | Value                                                   |
|:------------------ |:------------------------------------------------------- |
| Brand              | Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz               |
| Vendor             | :Intel                                                  |
| Architecture       | :Haswell                                                |
| Model              | Family: 0x06, Model: 0x3f, Stepping: 0x02, Type: 0x00   |
| Cores              | 2 physical cores, 2 logical cores (on executing CPU)    |
|                    | No Hyperthreading hardware capability detected          |
| Clock Frequencies  | Not supported by CPU                                    |
| Data Cache         | Level 1:3 : (32, 256, 30720) kbytes                     |
|                    | 64 byte cache line size                                 |
| Address Size       | 48 bits virtual, 44 bits physical                       |
| SIMD               | 256 bit = 32 byte max. SIMD vector size                 |
| Time Stamp Counter | TSC is accessible via `rdtsc`                           |
|                    | TSC increased at every clock cycle (non-invariant TSC)  |
| Perf. Monitoring   | Performance Monitoring Counters (PMC) are not supported |
| Hypervisor         | Yes, Microsoft                                          |

