# Benchmark result

* Pull request commit: [`76a10b0e4158f049e7c4900dbeaabb7c66b39b3d`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/76a10b0e4158f049e7c4900dbeaabb7c66b39b3d)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/210> (Use correct number of particles in Optimal Filter and add MPI test)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 18 Jan 2022 - 15:46
    - Baseline: 18 Jan 2022 - 15:49
* Package commits:
    - Target: 40289f
    - Baseline: 2be849
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
| `["BootstrapFilter", "init_filter"]`         |                1.23 (5%) :x: |                   1.00 (1%)  |
| `["OptimalFilter", "init_filter"]`           | 0.01 (5%) :white_check_mark: | 0.12 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.81 (5%) :white_check_mark: | 0.84 (1%) :white_check_mark: |
| `["base", "resample!"]`                      | 0.86 (5%) :white_check_mark: |                   1.00 (1%)  |

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
  uname: Linux 5.11.0-1025-azure #27~20.04.1-Ubuntu SMP Fri Jan 7 15:02:06 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       3384 s          1 s        229 s       1135 s          0 s
       #2  2095 MHz       3126 s          2 s        317 s       1305 s          0 s
       
  Memory: 6.788978576660156 GB (1401.921875 MB free)
  Uptime: 480.4 sec
  Load Avg:  1.74  1.42  0.76
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

### Baseline
```
Julia Version 1.6.5
Commit 9058264a69 (2021-12-19 12:30 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.3 LTS
  uname: Linux 5.11.0-1025-azure #27~20.04.1-Ubuntu SMP Fri Jan 7 15:02:06 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       4482 s          1 s        259 s       1810 s          0 s
       #2  2095 MHz       4425 s          2 s        366 s       1758 s          0 s
       
  Memory: 6.788978576660156 GB (1632.7109375 MB free)
  Uptime: 660.99 sec
  Load Avg:  1.56  1.44  0.89
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 18 Jan 2022 - 15:46
* Package commit: 40289f
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
| `["BootstrapFilter", "init_filter"]`         |   3.801 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   10.393 s (5%) |   4.115 ms | 223.73 MiB (1%) |     1022392 |
| `["OptimalFilter", "init_filter"]`           |  99.935 ms (5%) |            | 123.58 MiB (1%) |         312 |
| `["OptimalFilter", "run_particle_filter"]`   |   37.491 s (5%) | 403.976 ms |   6.06 GiB (1%) |     1042987 |
| `["base", "get_log_weights!"]`               |   1.280 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   5.589 ms (5%) |            |   1.02 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.600 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 325.026 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 121.777 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 325.917 ms (5%) |            |   1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 334.468 ms (5%) |            |   1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  19.689 ms (5%) |            |                 |             |

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
  uname: Linux 5.11.0-1025-azure #27~20.04.1-Ubuntu SMP Fri Jan 7 15:02:06 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       3384 s          1 s        229 s       1135 s          0 s
       #2  2095 MHz       3126 s          2 s        317 s       1305 s          0 s
       
  Memory: 6.788978576660156 GB (1401.921875 MB free)
  Uptime: 480.4 sec
  Load Avg:  1.74  1.42  0.76
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 18 Jan 2022 - 15:49
* Package commit: 2be849
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

| ID                                           | time            | GC time    | memory           | allocations |
|----------------------------------------------|----------------:|-----------:|-----------------:|------------:|
| `["BootstrapFilter", "init_filter"]`         |   3.100 μs (5%) |            |   33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   10.282 s (5%) |  14.706 ms |  223.61 MiB (1%) |     1021049 |
| `["OptimalFilter", "init_filter"]`           |    8.636 s (5%) | 302.137 ms | 1022.47 MiB (1%) |    12129583 |
| `["OptimalFilter", "run_particle_filter"]`   |   46.218 s (5%) | 657.446 ms |    7.21 GiB (1%) |    19042875 |
| `["base", "get_log_weights!"]`               |   1.310 μs (5%) |            |                  |             |
| `["base", "get_mean_and_var!"]`              |   5.766 ms (5%) |            |    1.02 KiB (1%) |          12 |
| `["base", "get_particles"]`                  |   1.600 ns (5%) |            |                  |             |
| `["base", "normalized_exp!"]`                | 320.197 ns (5%) |            |                  |             |
| `["base", "resample!"]`                      | 141.116 ns (5%) |            |   336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 332.772 ms (5%) |            |    1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 333.769 ms (5%) |            |    1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  19.511 ms (5%) |            |                  |             |

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
  uname: Linux 5.11.0-1025-azure #27~20.04.1-Ubuntu SMP Fri Jan 7 15:02:06 UTC 2022 x86_64 x86_64
  CPU: Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz: 
              speed         user         nice          sys         idle          irq
       #1  2095 MHz       4482 s          1 s        259 s       1810 s          0 s
       #2  2095 MHz       4425 s          2 s        366 s       1758 s          0 s
       
  Memory: 6.788978576660156 GB (1632.7109375 MB free)
  Uptime: 660.99 sec
  Load Avg:  1.56  1.44  0.89
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
    CPU MHz:                         2095.225
    BogoMIPS:                        4190.45
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

