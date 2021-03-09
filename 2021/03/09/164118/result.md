# Benchmark result

* Pull request commit: [`9d7b658abd59f5c29a6f413fcf5e913235f7cc36`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/9d7b658abd59f5c29a6f413fcf5e913235f7cc36)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/133> (Implement optimal particle filter from Alex)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 9 Mar 2021 - 16:38
    - Baseline: 9 Mar 2021 - 16:40
* Package commits:
    - Target: 8d0b17
    - Baseline: 2ee15f
* Julia commits:
    - Target: a58bdd
    - Baseline: a58bdd
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

| ID                                           | time ratio                   | memory ratio |
|----------------------------------------------|------------------------------|--------------|
| `["BootstrapFilter", "init_filter"]`         |                1.43 (5%) :x: |   1.00 (1%)  |
| `["base", "get_mean_and_var!"]`              | 0.89 (5%) :white_check_mark: |   1.00 (1%)  |
| `["base", "update_particle_noise!"]`         |                1.09 (5%) :x: |   1.00 (1%)  |
| `["base", "update_truth!"]`                  |                1.29 (5%) :x: |   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["base"]`

## Julia versioninfo

### Target
```
Julia Version 1.6.0-rc1
Commit a58bdd9010 (2021-02-06 15:49 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1040-azure #42-Ubuntu SMP Fri Feb 5 15:39:06 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2394 MHz       4145 s          1 s        241 s       1340 s          0 s
       #2  2394 MHz       3997 s          1 s        261 s       1440 s          0 s
       
  Memory: 6.7913818359375 GB (1295.40234375 MB free)
  Uptime: 591.0 sec
  Load Avg:  1.64  1.49  0.89
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

### Baseline
```
Julia Version 1.6.0-rc1
Commit a58bdd9010 (2021-02-06 15:49 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1040-azure #42-Ubuntu SMP Fri Feb 5 15:39:06 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2394 MHz       4914 s          1 s        256 s       1937 s          0 s
       #2  2394 MHz       5110 s          1 s        280 s       1689 s          0 s
       
  Memory: 6.7913818359375 GB (2832.6171875 MB free)
  Uptime: 729.0 sec
  Load Avg:  1.63  1.48  0.98
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 9 Mar 2021 - 16:38
* Package commit: 8d0b17
* Julia commit: a58bdd
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
| `["BootstrapFilter", "init_filter"]`         |   5.000 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   18.437 s (5%) |   5.042 ms | 167.58 MiB (1%) |      860530 |
| `["OptimalFilter", "init_filter"]`           | 110.909 ms (5%) |            | 123.58 MiB (1%) |         311 |
| `["OptimalFilter", "run_particle_filter"]`   |   50.010 s (5%) | 442.901 ms |   7.47 GiB (1%) |      884584 |
| `["base", "get_log_weights!"]`               |   2.090 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   8.515 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.800 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 459.904 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 163.386 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 705.700 ms (5%) |            |   1.59 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 351.982 ms (5%) |            |   1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  43.055 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.0-rc1
Commit a58bdd9010 (2021-02-06 15:49 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1040-azure #42-Ubuntu SMP Fri Feb 5 15:39:06 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2394 MHz       4145 s          1 s        241 s       1340 s          0 s
       #2  2394 MHz       3997 s          1 s        261 s       1440 s          0 s
       
  Memory: 6.7913818359375 GB (1295.40234375 MB free)
  Uptime: 591.0 sec
  Load Avg:  1.64  1.49  0.89
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, haswell)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 9 Mar 2021 - 16:40
* Package commit: 2ee15f
* Julia commit: a58bdd
* Julia command flags: None
* Environment variables: `JULIA_NUM_THREADS => 2`

## Results
Below is a table of this job's results, obtained by running the benchmarks.
The values listed in the `ID` column have the structure `[parent_group, child_group, ..., key]`, and can be used to
index into the BaseBenchmarks suite to retrieve the corresponding benchmarks.
The percentages accompanying time and memory values in the below table are noise tolerances. The "true"
time/memory value for a given benchmark is expected to fall within this percentage of the reported value.
An empty cell means that the value was zero.

| ID                                           | time            | GC time   | memory          | allocations |
|----------------------------------------------|----------------:|----------:|----------------:|------------:|
| `["BootstrapFilter", "init_filter"]`         |   3.500 μs (5%) |           |  33.88 MiB (1%) |          12 |
| `["BootstrapFilter", "run_particle_filter"]` |   18.270 s (5%) | 11.740 ms | 167.40 MiB (1%) |      858713 |
| `["base", "get_log_weights!"]`               |   2.020 μs (5%) |           |                 |             |
| `["base", "get_mean_and_var!"]`              |   9.590 ms (5%) |           |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.800 ns (5%) |           |                 |             |
| `["base", "normalized_exp!"]`                | 471.066 ns (5%) |           |                 |             |
| `["base", "resample!"]`                      | 160.229 ns (5%) |           |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 708.812 ms (5%) |           |   1.59 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 324.044 ms (5%) |           |   1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  33.354 ms (5%) |           |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.0-rc1
Commit a58bdd9010 (2021-02-06 15:49 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1040-azure #42-Ubuntu SMP Fri Feb 5 15:39:06 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v3 @ 2.40GHz: 
              speed         user         nice          sys         idle          irq
       #1  2394 MHz       4914 s          1 s        256 s       1937 s          0 s
       #2  2394 MHz       5110 s          1 s        280 s       1689 s          0 s
       
  Memory: 6.7913818359375 GB (2832.6171875 MB free)
  Uptime: 729.0 sec
  Load Avg:  1.63  1.48  0.98
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
    CPU MHz:                         2394.454
    BogoMIPS:                        4788.90
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
|                    | No Hyperthreading detected                              |
| Clock Frequencies  | Not supported by CPU                                    |
| Data Cache         | Level 1:3 : (32, 256, 30720) kbytes                     |
|                    | 64 byte cache line size                                 |
| Address Size       | 48 bits virtual, 46 bits physical                       |
| SIMD               | 256 bit = 32 byte max. SIMD vector size                 |
| Time Stamp Counter | TSC is accessible via `rdtsc`                           |
|                    | TSC increased at every clock cycle (non-invariant TSC)  |
| Perf. Monitoring   | Performance Monitoring Counters (PMC) are not supported |
| Hypervisor         | Yes, Microsoft                                          |

