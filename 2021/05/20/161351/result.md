# Benchmark result

* Pull request commit: [`9fd6fb4b47a7cdc14948e526d3f299e92dfd3d4b`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/9fd6fb4b47a7cdc14948e526d3f299e92dfd3d4b)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/186> (Remove redundant call to `get_particles`)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 20 May 2021 - 16:10
    - Baseline: 20 May 2021 - 16:13
* Package commits:
    - Target: bf55ae
    - Baseline: a54959
* Julia commits:
    - Target: 6aaede
    - Baseline: 6aaede
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
| `["BootstrapFilter", "init_filter"]`         |                1.45 (5%) :x: |                   1.00 (1%)  |
| `["OptimalFilter", "init_filter"]`           | 0.01 (5%) :white_check_mark: | 0.10 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.79 (5%) :white_check_mark: | 0.82 (1%) :white_check_mark: |
| `["base", "get_mean_and_var!"]`              | 0.94 (5%) :white_check_mark: |                   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo

### Target
```
Julia Version 1.6.1
Commit 6aaedecc44 (2021-04-23 05:59 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1047-azure #49-Ubuntu SMP Thu Apr 22 14:30:37 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz       2747 s          2 s        187 s       3791 s          0 s
       #2  2593 MHz       3402 s          0 s        252 s       3102 s          0 s
       
  Memory: 6.791339874267578 GB (1060.43359375 MB free)
  Uptime: 679.0 sec
  Load Avg:  1.92  1.36  0.71
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

### Baseline
```
Julia Version 1.6.1
Commit 6aaedecc44 (2021-04-23 05:59 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1047-azure #49-Ubuntu SMP Thu Apr 22 14:30:37 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz       3463 s          2 s        215 s       4766 s          0 s
       #2  2593 MHz       4942 s          0 s        294 s       3243 s          0 s
       
  Memory: 6.791339874267578 GB (2106.47265625 MB free)
  Uptime: 852.0 sec
  Load Avg:  1.59  1.38  0.83
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 20 May 2021 - 16:10
* Package commit: bf55ae
* Julia commit: 6aaede
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
| `["BootstrapFilter", "init_filter"]`         |   4.799 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |    9.418 s (5%) |   4.637 ms | 223.80 MiB (1%) |     1022737 |
| `["OptimalFilter", "init_filter"]`           |  91.262 ms (5%) |            | 123.58 MiB (1%) |         313 |
| `["OptimalFilter", "run_particle_filter"]`   |   34.971 s (5%) | 379.257 ms |   6.06 GiB (1%) |     1043336 |
| `["base", "get_log_weights!"]`               |   1.540 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   6.607 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.700 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 381.281 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 152.068 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 292.574 ms (5%) |            |   1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 320.223 ms (5%) |            |   1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  20.038 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.1
Commit 6aaedecc44 (2021-04-23 05:59 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1047-azure #49-Ubuntu SMP Thu Apr 22 14:30:37 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz       2747 s          2 s        187 s       3791 s          0 s
       #2  2593 MHz       3402 s          0 s        252 s       3102 s          0 s
       
  Memory: 6.791339874267578 GB (1060.43359375 MB free)
  Uptime: 679.0 sec
  Load Avg:  1.92  1.36  0.71
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 20 May 2021 - 16:13
* Package commit: a54959
* Julia commit: 6aaede
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
| `["BootstrapFilter", "init_filter"]`         |   3.300 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |    9.432 s (5%) |  24.641 ms | 223.62 MiB (1%) |     1020944 |
| `["OptimalFilter", "init_filter"]`           |    9.421 s (5%) | 266.870 ms |   1.21 GiB (1%) |    15393788 |
| `["OptimalFilter", "run_particle_filter"]`   |   44.114 s (5%) | 643.666 ms |   7.35 GiB (1%) |    21409883 |
| `["base", "get_log_weights!"]`               |   1.540 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   7.058 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.700 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 394.094 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 150.976 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 293.577 ms (5%) |            |   1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 316.155 ms (5%) |            |   1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  20.071 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.1
Commit 6aaedecc44 (2021-04-23 05:59 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1047-azure #49-Ubuntu SMP Thu Apr 22 14:30:37 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2593 MHz       3463 s          2 s        215 s       4766 s          0 s
       #2  2593 MHz       4942 s          0 s        294 s       3243 s          0 s
       
  Memory: 6.791339874267578 GB (2106.47265625 MB free)
  Uptime: 852.0 sec
  Load Avg:  1.59  1.38  0.83
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
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
    CPU MHz:                         2593.908
    BogoMIPS:                        5187.81
    Hypervisor vendor:               Microsoft
    Virtualization type:             full
    L1d cache:                       64 KiB
    L1i cache:                       64 KiB
    L2 cache:                        2 MiB
    L3 cache:                        35.8 MiB
    NUMA node0 CPU(s):               0,1
    Vulnerability Itlb multihit:     KVM: Vulnerable
    Vulnerability L1tf:              Mitigation; PTE Inversion
    Vulnerability Mds:               Mitigation; Clear CPU buffers; SMT Host state unknown
    Vulnerability Meltdown:          Mitigation; PTI
    Vulnerability Spec store bypass: Vulnerable
    Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:        Mitigation; Full generic retpoline, STIBP disabled, RSB filling
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

