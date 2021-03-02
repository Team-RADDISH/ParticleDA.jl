# Benchmark result

* Pull request commit: [`a16fa17882644ddbf3d723d958435e80dcb085cb`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/a16fa17882644ddbf3d723d958435e80dcb085cb)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/157> (Split get_grid_size into three functions )

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 2 Mar 2021 - 10:53
    - Baseline: 2 Mar 2021 - 10:55
* Package commits:
    - Target: 4ec700
    - Baseline: 6ecb85
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

| ID                                           | time ratio    | memory ratio                 |
|----------------------------------------------|---------------|------------------------------|
| `["BootstrapFilter", "init_filter"]`         | 1.44 (5%) :x: |                   1.00 (1%)  |
| `["base", "update_particle_dynamics!"]`      |    1.01 (5%)  | 0.98 (1%) :white_check_mark: |

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
  uname: Linux 5.4.0-1039-azure #41-Ubuntu SMP Mon Jan 18 13:22:11 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       3359 s          1 s        212 s        918 s          0 s
       #2  2095 MHz       2770 s          1 s        219 s       1483 s          0 s
       
  Memory: 6.791378021240234 GB (1070.609375 MB free)
  Uptime: 459.0 sec
  Load Avg:  1.65  1.43  0.77
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

### Baseline
```
Julia Version 1.6.0-rc1
Commit a58bdd9010 (2021-02-06 15:49 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1039-azure #41-Ubuntu SMP Mon Jan 18 13:22:11 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       4023 s          1 s        230 s       1283 s          0 s
       #2  2095 MHz       3547 s          1 s        232 s       1740 s          0 s
       
  Memory: 6.791378021240234 GB (3010.11328125 MB free)
  Uptime: 565.0 sec
  Load Avg:  1.56  1.43  0.84
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 2 Mar 2021 - 10:53
* Package commit: 4ec700
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
| `["BootstrapFilter", "init_filter"]`         |   3.600 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |    8.807 s (5%) |   3.560 ms | 167.58 MiB (1%) |      860524 |
| `["OptimalFilter", "init_filter"]`           |  83.782 ms (5%) |            | 142.92 MiB (1%) |         369 |
| `["OptimalFilter", "run_particle_filter"]`   |   32.930 s (5%) | 376.430 ms |  12.50 GiB (1%) |      947948 |
| `["base", "get_log_weights!"]`               |   1.270 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   5.425 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.400 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 306.494 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 117.015 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 285.101 ms (5%) |            |   1.59 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 235.197 ms (5%) |            |   1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  18.335 ms (5%) |            |                 |             |

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
  uname: Linux 5.4.0-1039-azure #41-Ubuntu SMP Mon Jan 18 13:22:11 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       3359 s          1 s        212 s        918 s          0 s
       #2  2095 MHz       2770 s          1 s        219 s       1483 s          0 s
       
  Memory: 6.791378021240234 GB (1070.609375 MB free)
  Uptime: 459.0 sec
  Load Avg:  1.65  1.43  0.77
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 2 Mar 2021 - 10:55
* Package commit: 6ecb85
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
| `["BootstrapFilter", "init_filter"]`         |   2.500 μs (5%) |           |  33.88 MiB (1%) |          12 |
| `["BootstrapFilter", "run_particle_filter"]` |    9.059 s (5%) | 45.870 ms | 167.40 MiB (1%) |      858705 |
| `["base", "get_log_weights!"]`               |   1.270 μs (5%) |           |                 |             |
| `["base", "get_mean_and_var!"]`              |   5.694 ms (5%) |           |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.400 ns (5%) |           |                 |             |
| `["base", "normalized_exp!"]`                | 311.255 ns (5%) |           |                 |             |
| `["base", "resample!"]`                      | 114.271 ns (5%) |           |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 281.856 ms (5%) |           |   1.62 KiB (1%) |          12 |
| `["base", "update_particle_noise!"]`         | 235.846 ms (5%) |           |   1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  18.432 ms (5%) |           |                 |             |

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
  uname: Linux 5.4.0-1039-azure #41-Ubuntu SMP Mon Jan 18 13:22:11 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       4023 s          1 s        230 s       1283 s          0 s
       #2  2095 MHz       3547 s          1 s        232 s       1740 s          0 s
       
  Memory: 6.791378021240234 GB (3010.11328125 MB free)
  Uptime: 565.0 sec
  Load Avg:  1.56  1.43  0.84
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
    Model name:                      Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz
    Stepping:                        4
    CPU MHz:                         2095.073
    BogoMIPS:                        4190.14
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
| Brand              | Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz           |
| Vendor             | :Intel                                                  |
| Architecture       | :Skylake                                                |
| Model              | Family: 0x06, Model: 0x55, Stepping: 0x04, Type: 0x00   |
| Cores              | 2 physical cores, 2 logical cores (on executing CPU)    |
|                    | No Hyperthreading detected                              |
| Clock Frequencies  | Not supported by CPU                                    |
| Data Cache         | Level 1:3 : (32, 1024, 36608) kbytes                    |
|                    | 64 byte cache line size                                 |
| Address Size       | 48 bits virtual, 46 bits physical                       |
| SIMD               | 512 bit = 64 byte max. SIMD vector size                 |
| Time Stamp Counter | TSC is accessible via `rdtsc`                           |
|                    | TSC increased at every clock cycle (non-invariant TSC)  |
| Perf. Monitoring   | Performance Monitoring Counters (PMC) are not supported |
| Hypervisor         | Yes, Microsoft                                          |

