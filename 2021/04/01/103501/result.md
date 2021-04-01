# Benchmark result

* Pull request commit: [`cb14f330ae3f232175eebe6158d72b8f1de8d0ea`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/cb14f330ae3f232175eebe6158d72b8f1de8d0ea)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/172> (CompatHelper: bump compat for "BenchmarkTools" to "0.7" for package benchmark)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 1 Apr 2021 - 10:31
    - Baseline: 1 Apr 2021 - 10:34
* Package commits:
    - Target: f16043
    - Baseline: 110171
* Julia commits:
    - Target: f9720d
    - Baseline: f9720d
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
| `["BootstrapFilter", "init_filter"]`         |                1.64 (5%) :x: |                   1.00 (1%)  |
| `["OptimalFilter", "init_filter"]`           | 0.01 (5%) :white_check_mark: | 0.10 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.78 (5%) :white_check_mark: | 0.82 (1%) :white_check_mark: |
| `["base", "get_log_weights!"]`               |                1.10 (5%) :x: |                   1.00 (1%)  |
| `["base", "get_mean_and_var!"]`              | 0.92 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["base", "get_particles"]`                  | 0.90 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["base", "normalized_exp!"]`                | 0.85 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["base", "update_particle_dynamics!"]`      |                   1.01 (5%)  | 0.98 (1%) :white_check_mark: |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo

### Target
```
Julia Version 1.6.0
Commit f9720dc2eb (2021-03-24 12:55 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1043-azure #45-Ubuntu SMP Fri Mar 19 17:33:38 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       2859 s          2 s        252 s       1809 s          0 s
       #2  2095 MHz       3836 s          1 s        231 s        872 s          0 s
       
  Memory: 6.791343688964844 GB (1184.16015625 MB free)
  Uptime: 509.0 sec
  Load Avg:  1.78  1.48  0.82
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

### Baseline
```
Julia Version 1.6.0
Commit f9720dc2eb (2021-03-24 12:55 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1043-azure #45-Ubuntu SMP Fri Mar 19 17:33:38 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       4030 s          2 s        297 s       2564 s          0 s
       #2  2095 MHz       5160 s          1 s        285 s       1461 s          0 s
       
  Memory: 6.791343688964844 GB (2170.53125 MB free)
  Uptime: 706.0 sec
  Load Avg:  1.33  1.4  0.93
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 1 Apr 2021 - 10:31
* Package commit: f16043
* Julia commit: f9720d
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
| `["BootstrapFilter", "run_particle_filter"]` |   10.846 s (5%) |   4.369 ms | 167.59 MiB (1%) |      860939 |
| `["OptimalFilter", "init_filter"]`           | 105.086 ms (5%) |            | 123.58 MiB (1%) |         313 |
| `["OptimalFilter", "run_particle_filter"]`   |   39.139 s (5%) | 391.966 ms |   6.01 GiB (1%) |      881536 |
| `["base", "get_log_weights!"]`               |   2.160 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   7.935 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.800 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 363.952 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 160.307 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 352.903 ms (5%) |            |   1.59 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 315.142 ms (5%) |            |   1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  21.678 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.0
Commit f9720dc2eb (2021-03-24 12:55 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1043-azure #45-Ubuntu SMP Fri Mar 19 17:33:38 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       2859 s          2 s        252 s       1809 s          0 s
       #2  2095 MHz       3836 s          1 s        231 s        872 s          0 s
       
  Memory: 6.791343688964844 GB (1184.16015625 MB free)
  Uptime: 509.0 sec
  Load Avg:  1.78  1.48  0.82
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 1 Apr 2021 - 10:34
* Package commit: 110171
* Julia commit: f9720d
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
| `["BootstrapFilter", "init_filter"]`         |   2.800 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   10.797 s (5%) |  52.539 ms | 167.41 MiB (1%) |      858874 |
| `["OptimalFilter", "init_filter"]`           |   10.617 s (5%) | 274.308 ms |   1.20 GiB (1%) |    15051968 |
| `["OptimalFilter", "run_particle_filter"]`   |   50.118 s (5%) | 674.707 ms |   7.35 GiB (1%) |    22039386 |
| `["base", "get_log_weights!"]`               |   1.970 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   8.591 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   2.000 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 425.976 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 165.205 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 350.785 ms (5%) |            |   1.62 KiB (1%) |          12 |
| `["base", "update_particle_noise!"]`         | 302.709 ms (5%) |            |   1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  22.529 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.6.0
Commit f9720dc2eb (2021-03-24 12:55 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1043-azure #45-Ubuntu SMP Fri Mar 19 17:33:38 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       4030 s          2 s        297 s       2564 s          0 s
       #2  2095 MHz       5160 s          1 s        285 s       1461 s          0 s
       
  Memory: 6.791343688964844 GB (2170.53125 MB free)
  Uptime: 706.0 sec
  Load Avg:  1.33  1.4  0.93
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
    CPU MHz:                         2095.115
    BogoMIPS:                        4190.23
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

