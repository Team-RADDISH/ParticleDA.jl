# Benchmark result

* Pull request commit: [`c989218d694ba2569cf152e96e9fafe75a9f538f`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/c989218d694ba2569cf152e96e9fafe75a9f538f)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/222> (Collect code coverage and add badges to README file)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 20 Apr 2022 - 16:47
    - Baseline: 20 Apr 2022 - 16:50
* Package commits:
    - Target: d0cc1c
    - Baseline: aa782b
* Julia commits:
    - Target: bf5349
    - Baseline: bf5349
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
| `["BootstrapFilter", "init_filter"]`         |                1.28 (5%) :x: |                   1.00 (1%)  |
| `["OptimalFilter", "init_filter"]`           | 0.07 (5%) :white_check_mark: | 0.21 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.89 (5%) :white_check_mark: | 0.92 (1%) :white_check_mark: |
| `["base", "update_particle_dynamics!"]`      |                   0.98 (5%)  |                1.02 (1%) :x: |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo

### Target
```
Julia Version 1.7.2
Commit bf53498635 (2022-02-06 15:21 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.4 LTS
  uname: Linux 5.13.0-1021-azure #24~20.04.1-Ubuntu SMP Tue Mar 29 15:34:22 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz       3329 s          2 s        228 s       1210 s          0 s
       #2  2593 MHz       3196 s          1 s        218 s       1360 s          0 s
       
  Memory: 6.783611297607422 GB (1650.49609375 MB free)
  Uptime: 481.36 sec
  Load Avg:  1.54  1.33  0.71
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, skylake-avx512)
```

### Baseline
```
Julia Version 1.7.2
Commit bf53498635 (2022-02-06 15:21 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.4 LTS
  uname: Linux 5.13.0-1021-azure #24~20.04.1-Ubuntu SMP Tue Mar 29 15:34:22 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz       4052 s          2 s        251 s       2112 s          0 s
       #2  2593 MHz       4654 s          1 s        269 s       1504 s          0 s
       
  Memory: 6.783611297607422 GB (2060.78125 MB free)
  Uptime: 646.7 sec
  Load Avg:  1.35  1.33  0.82
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, skylake-avx512)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 20 Apr 2022 - 16:47
* Package commit: d0cc1c
* Julia commit: bf5349
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
| `["BootstrapFilter", "init_filter"]`         |   4.600 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |    9.585 s (5%) |   5.211 ms | 223.82 MiB (1%) |     1027107 |
| `["OptimalFilter", "init_filter"]`           | 533.670 ms (5%) |  14.059 ms | 210.74 MiB (1%) |     1904350 |
| `["OptimalFilter", "run_particle_filter"]`   |   41.790 s (5%) | 704.057 ms |   7.21 GiB (1%) |    26768233 |
| `["base", "get_log_weights!"]`               |   1.410 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   6.490 ms (5%) |            |   1.05 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.700 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 395.025 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 168.500 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 292.503 ms (5%) |            |   1.48 KiB (1%) |          12 |
| `["base", "update_particle_noise!"]`         | 345.751 ms (5%) |            |   1.03 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  19.277 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.7.2
Commit bf53498635 (2022-02-06 15:21 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.4 LTS
  uname: Linux 5.13.0-1021-azure #24~20.04.1-Ubuntu SMP Tue Mar 29 15:34:22 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz       3329 s          2 s        228 s       1210 s          0 s
       #2  2593 MHz       3196 s          1 s        218 s       1360 s          0 s
       
  Memory: 6.783611297607422 GB (1650.49609375 MB free)
  Uptime: 481.36 sec
  Load Avg:  1.54  1.33  0.71
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, skylake-avx512)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 20 Apr 2022 - 16:50
* Package commit: aa782b
* Julia commit: bf5349
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
| `["BootstrapFilter", "init_filter"]`         |   3.600 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |    9.590 s (5%) |  15.701 ms | 223.70 MiB (1%) |     1025609 |
| `["OptimalFilter", "init_filter"]`           |    7.575 s (5%) | 344.670 ms | 982.76 MiB (1%) |    12961327 |
| `["OptimalFilter", "run_particle_filter"]`   |   46.927 s (5%) | 769.749 ms |   7.87 GiB (1%) |    38996318 |
| `["base", "get_log_weights!"]`               |   1.430 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   6.414 ms (5%) |            |   1.05 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.700 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 389.552 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 171.717 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 298.101 ms (5%) |            |   1.45 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 342.805 ms (5%) |            |   1.03 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  19.631 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.7.2
Commit bf53498635 (2022-02-06 15:21 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.4 LTS
  uname: Linux 5.13.0-1021-azure #24~20.04.1-Ubuntu SMP Tue Mar 29 15:34:22 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz       4052 s          2 s        251 s       2112 s          0 s
       #2  2593 MHz       4654 s          1 s        269 s       1504 s          0 s
       
  Memory: 6.783611297607422 GB (2060.78125 MB free)
  Uptime: 646.7 sec
  Load Avg:  1.35  1.33  0.82
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, skylake-avx512)
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
    Model:                           85
    Model name:                      Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz
    Stepping:                        7
    CPU MHz:                         2593.906
    BogoMIPS:                        5187.81
    Hypervisor vendor:               Microsoft
    Virtualization type:             full
    L1d cache:                       64 KiB
    L1i cache:                       64 KiB
    L2 cache:                        2 MiB
    L3 cache:                        35.8 MiB
    NUMA node0 CPU(s):               0,1
    Vulnerability Itlb multihit:     KVM: Mitigation: VMX unsupported
    Vulnerability L1tf:              Mitigation; PTE Inversion
    Vulnerability Mds:               Mitigation; Clear CPU buffers; SMT Host state unknown
    Vulnerability Meltdown:          Mitigation; PTI
    Vulnerability Spec store bypass: Vulnerable
    Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:        Mitigation; Retpolines, STIBP disabled, RSB filling
    Vulnerability Srbds:             Not affected
    Vulnerability Tsx async abort:   Mitigation; Clear CPU buffers; SMT Host state unknown
    Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap clflushopt avx512cd avx512bw avx512vl xsaveopt xsavec xsaves md_clear
    

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

