# Benchmark result

* Pull request commit: [`f267b76cf5e46c92418ef8f02897fa3ec916795f`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/f267b76cf5e46c92418ef8f02897fa3ec916795f)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/228> (Add updated scripts for weak scaling runs.)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 14 Jul 2022 - 15:47
    - Baseline: 14 Jul 2022 - 15:50
* Package commits:
    - Target: 122104
    - Baseline: 410605
* Julia commits:
    - Target: 742b9a
    - Baseline: 742b9a
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
| `["BootstrapFilter", "init_filter"]`         |                1.21 (5%) :x: |   1.00 (1%)  |
| `["base", "get_mean_and_var!"]`              |                1.08 (5%) :x: |   1.00 (1%)  |
| `["base", "get_particles"]`                  |                1.07 (5%) :x: |   1.00 (1%)  |
| `["base", "resample!"]`                      | 0.92 (5%) :white_check_mark: |   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo

### Target
```
Julia Version 1.7.3
Commit 742b9abb4d (2022-05-06 12:58 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.4 LTS
  uname: Linux 5.13.0-1031-azure #37~20.04.1-Ubuntu SMP Mon Jun 13 22:51:01 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       4124 s          2 s        228 s        906 s          0 s
       #2  2294 MHz       3582 s          2 s        241 s       1438 s          0 s
       
  Memory: 6.783607482910156 GB (1914.109375 MB free)
  Uptime: 531.56 sec
  Load Avg:  1.85  1.55  0.84
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, broadwell)
```

### Baseline
```
Julia Version 1.7.3
Commit 742b9abb4d (2022-05-06 12:58 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.4 LTS
  uname: Linux 5.13.0-1031-azure #37~20.04.1-Ubuntu SMP Mon Jun 13 22:51:01 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       4981 s          2 s        252 s       1646 s          0 s
       #2  2294 MHz       5038 s          2 s        266 s       1581 s          0 s
       
  Memory: 6.783607482910156 GB (2623.28125 MB free)
  Uptime: 694.09 sec
  Load Avg:  1.66  1.53  0.95
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, broadwell)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 14 Jul 2022 - 15:47
* Package commit: 122104
* Julia commit: 742b9a
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
| `["BootstrapFilter", "init_filter"]`         |   4.000 μs (5%) |           |  33.88 MiB (1%) |          14 |
| `["BootstrapFilter", "run_particle_filter"]` |   15.125 s (5%) |  5.569 ms | 224.52 MiB (1%) |     1028403 |
| `["OptimalFilter", "init_filter"]`           |  74.211 ms (5%) |           |  60.12 MiB (1%) |      320061 |
| `["OptimalFilter", "run_particle_filter"]`   |   17.541 s (5%) | 58.810 ms | 684.91 MiB (1%) |     6157691 |
| `["base", "get_log_weights!"]`               |   4.525 μs (5%) |           |   6.00 KiB (1%) |          64 |
| `["base", "get_mean_and_var!"]`              |   8.749 ms (5%) |           |   1.05 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.499 ns (5%) |           |                 |             |
| `["base", "normalized_exp!"]`                | 464.948 ns (5%) |           |                 |             |
| `["base", "resample!"]`                      | 204.323 ns (5%) |           |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 508.348 ms (5%) |           |   1.45 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 454.856 ms (5%) |           |   1.03 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  29.345 ms (5%) |           |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.7.3
Commit 742b9abb4d (2022-05-06 12:58 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.4 LTS
  uname: Linux 5.13.0-1031-azure #37~20.04.1-Ubuntu SMP Mon Jun 13 22:51:01 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       4124 s          2 s        228 s        906 s          0 s
       #2  2294 MHz       3582 s          2 s        241 s       1438 s          0 s
       
  Memory: 6.783607482910156 GB (1914.109375 MB free)
  Uptime: 531.56 sec
  Load Avg:  1.85  1.55  0.84
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, broadwell)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 14 Jul 2022 - 15:50
* Package commit: 410605
* Julia commit: 742b9a
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
| `["BootstrapFilter", "init_filter"]`         |   3.300 μs (5%) |            |  33.88 MiB (1%) |          14 |
| `["BootstrapFilter", "run_particle_filter"]` |   15.367 s (5%) |  55.498 ms | 224.40 MiB (1%) |     1026948 |
| `["OptimalFilter", "init_filter"]`           |  76.906 ms (5%) |            |  60.12 MiB (1%) |      320061 |
| `["OptimalFilter", "run_particle_filter"]`   |   17.360 s (5%) | 284.920 ms | 684.91 MiB (1%) |     6157705 |
| `["base", "get_log_weights!"]`               |   4.537 μs (5%) |            |   6.00 KiB (1%) |          64 |
| `["base", "get_mean_and_var!"]`              |   8.103 ms (5%) |            |   1.05 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.399 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 468.041 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 221.802 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 509.025 ms (5%) |            |   1.45 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 441.748 ms (5%) |            |   1.03 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  28.896 ms (5%) |            |                 |             |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["BootstrapFilter"]`
- `["OptimalFilter"]`
- `["base"]`

## Julia versioninfo
```
Julia Version 1.7.3
Commit 742b9abb4d (2022-05-06 12:58 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.4 LTS
  uname: Linux 5.13.0-1031-azure #37~20.04.1-Ubuntu SMP Mon Jun 13 22:51:01 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       4981 s          2 s        252 s       1646 s          0 s
       #2  2294 MHz       5038 s          2 s        266 s       1581 s          0 s
       
  Memory: 6.783607482910156 GB (2623.28125 MB free)
  Uptime: 694.09 sec
  Load Avg:  1.66  1.53  0.95
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-12.0.1 (ORCJIT, broadwell)
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
    CPU MHz:                         2294.686
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
    Vulnerability Mmio stale data:   Vulnerable: Clear CPU buffers attempted, no microcode; SMT Host state unknown
    Vulnerability Spec store bypass: Vulnerable
    Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:        Mitigation; Retpolines, STIBP disabled, RSB filling
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

