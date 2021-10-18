# Benchmark result

* Pull request commit: [`3d91c6ab16ec7e16eeccbfeb781bb5acfc9c3a09`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/3d91c6ab16ec7e16eeccbfeb781bb5acfc9c3a09)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/201> (Generalise some dimensions in bootstrap filter)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 18 Oct 2021 - 11:47
    - Baseline: 18 Oct 2021 - 11:51
* Package commits:
    - Target: cb0641
    - Baseline: 47e9f9
* Julia commits:
    - Target: ae8452
    - Baseline: ae8452
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
| `["OptimalFilter", "init_filter"]`           | 0.01 (5%) :white_check_mark: | 0.12 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.83 (5%) :white_check_mark: | 0.84 (1%) :white_check_mark: |
| `["base", "get_mean_and_var!"]`              | 0.00 (5%) :white_check_mark: | 0.00 (1%) :white_check_mark: |
| `["base", "normalized_exp!"]`                |                1.05 (5%) :x: |                   1.00 (1%)  |
| `["base", "update_particle_dynamics!"]`      |                   1.00 (5%)  | 0.98 (1%) :white_check_mark: |
| `["base", "update_truth!"]`                  |                1.33 (5%) :x: |                   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo

### Target
```
Julia Version 1.6.3
Commit ae8452a9e0 (2021-09-23 17:34 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.8.0-1042-azure #45~20.04.1-Ubuntu SMP Wed Sep 15 14:24:15 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2397 MHz       4065 s          2 s        218 s       1742 s          0 s
       #2  2397 MHz       4250 s          0 s        298 s       1503 s          0 s
       
  Memory: 6.790924072265625 GB (1330.80859375 MB free)
  Uptime: 609.0 sec
  Load Avg:  1.67  1.42  0.81
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

### Baseline
```
Julia Version 1.6.3
Commit ae8452a9e0 (2021-09-23 17:34 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.8.0-1042-azure #45~20.04.1-Ubuntu SMP Wed Sep 15 14:24:15 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2397 MHz       5377 s          2 s        286 s       3077 s          0 s
       #2  2397 MHz       6550 s          0 s        379 s       1841 s          0 s
       
  Memory: 6.790924072265625 GB (1803.42578125 MB free)
  Uptime: 882.0 sec
  Load Avg:  1.62  1.49  1.01
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 18 Oct 2021 - 11:47
* Package commit: cb0641
* Julia commit: ae8452
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
| `["BootstrapFilter", "init_filter"]`         |   4.300 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   18.343 s (5%) |  10.015 ms | 223.73 MiB (1%) |     1022431 |
| `["OptimalFilter", "init_filter"]`           | 105.818 ms (5%) |            | 123.58 MiB (1%) |         312 |
| `["OptimalFilter", "run_particle_filter"]`   |   49.239 s (5%) | 433.103 ms |   6.06 GiB (1%) |     1043004 |
| `["base", "get_log_weights!"]`               |   1.870 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |  10.161 ms (5%) |            |   1.02 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.600 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 426.653 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 155.911 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 694.751 ms (5%) |            |   1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 350.122 ms (5%) |            |   1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  41.113 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.3
Commit ae8452a9e0 (2021-09-23 17:34 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.8.0-1042-azure #45~20.04.1-Ubuntu SMP Wed Sep 15 14:24:15 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2397 MHz       4065 s          2 s        218 s       1742 s          0 s
       #2  2397 MHz       4250 s          0 s        298 s       1503 s          0 s
       
  Memory: 6.790924072265625 GB (1330.80859375 MB free)
  Uptime: 609.0 sec
  Load Avg:  1.67  1.42  0.81
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 18 Oct 2021 - 11:51
* Package commit: 47e9f9
* Julia commit: ae8452
* Julia command flags: None
* Environment variables: `JULIA_NUM_THREADS => 2`

## Results
Below is a table of this job's results, obtained by running the benchmarks.
The values listed in the `ID` column have the structure `[parent_group, child_group, ..., key]`, and can be used to
index into the BaseBenchmarks suite to retrieve the corresponding benchmarks.
The percentages accompanying time and memory values in the below table are noise tolerances. The "true"
time/memory value for a given benchmark is expected to fall within this percentage of the reported value.
An empty cell means that the value was zero.

| ID                                           | time            | GC time    | memory           | allocations |
|----------------------------------------------|----------------:|-----------:|-----------------:|------------:|
| `["BootstrapFilter", "init_filter"]`         |   3.400 μs (5%) |            |   33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   18.537 s (5%) |  13.911 ms |  223.61 MiB (1%) |     1021056 |
| `["OptimalFilter", "init_filter"]`           |    9.145 s (5%) | 220.727 ms | 1013.05 MiB (1%) |    12045829 |
| `["OptimalFilter", "run_particle_filter"]`   |   58.975 s (5%) | 725.607 ms |    7.22 GiB (1%) |    19073793 |
| `["base", "get_log_weights!"]`               |   1.880 μs (5%) |            |                  |             |
| `["base", "get_mean_and_var!"]`              |   28.626 s (5%) |            |   44.58 MiB (1%) |      758297 |
| `["base", "get_particles"]`                  |   1.600 ns (5%) |            |                  |             |
| `["base", "normalized_exp!"]`                | 405.040 ns (5%) |            |                  |             |
| `["base", "resample!"]`                      | 154.906 ns (5%) |            |   336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 695.177 ms (5%) |            |    1.45 KiB (1%) |          12 |
| `["base", "update_particle_noise!"]`         | 345.897 ms (5%) |            |    1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  30.939 ms (5%) |            |                  |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.3
Commit ae8452a9e0 (2021-09-23 17:34 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.8.0-1042-azure #45~20.04.1-Ubuntu SMP Wed Sep 15 14:24:15 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2397 MHz       5377 s          2 s        286 s       3077 s          0 s
       #2  2397 MHz       6550 s          0 s        379 s       1841 s          0 s
       
  Memory: 6.790924072265625 GB (1803.42578125 MB free)
  Uptime: 882.0 sec
  Load Avg:  1.62  1.49  1.01
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
    Address sizes:                   46 bits physical, 48 bits virtual
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
    CPU MHz:                         2397.223
    BogoMIPS:                        4794.44
    Hypervisor vendor:               Microsoft
    Virtualization type:             full
    L1d cache:                       64 KiB
    L1i cache:                       64 KiB
    L2 cache:                        512 KiB
    L3 cache:                        30 MiB
    NUMA node0 CPU(s):               0,1
    Vulnerability Itlb multihit:     KVM: Mitigation: VMX unsupported
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
| Address Size       | 48 bits virtual, 46 bits physical                       |
| SIMD               | 256 bit = 32 byte max. SIMD vector size                 |
| Time Stamp Counter | TSC is accessible via `rdtsc`                           |
|                    | TSC increased at every clock cycle (non-invariant TSC)  |
| Perf. Monitoring   | Performance Monitoring Counters (PMC) are not supported |
| Hypervisor         | Yes, Microsoft                                          |

