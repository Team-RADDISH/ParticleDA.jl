# Benchmark result

* Pull request commit: [`88d91c76207aa2c7f86a1eacbad524d2f12defd1`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/88d91c76207aa2c7f86a1eacbad524d2f12defd1)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/189> (Add Pluto notebook to explore the output data)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 21 May 2021 - 17:14
    - Baseline: 21 May 2021 - 17:17
* Package commits:
    - Target: 0bf33d
    - Baseline: a95cd1
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
| `["BootstrapFilter", "init_filter"]`         |                1.34 (5%) :x: |                   1.00 (1%)  |
| `["OptimalFilter", "init_filter"]`           | 0.01 (5%) :white_check_mark: | 0.12 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.81 (5%) :white_check_mark: | 0.84 (1%) :white_check_mark: |
| `["base", "update_particle_noise!"]`         |                   1.02 (5%)  | 0.97 (1%) :white_check_mark: |

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
       #1  2593 MHz       2910 s          0 s        190 s       1353 s          0 s
       #2  2593 MHz       2997 s          1 s        218 s       1269 s          0 s
       
  Memory: 6.791339874267578 GB (1588.03125 MB free)
  Uptime: 451.0 sec
  Load Avg:  1.73  1.26  0.63
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
       #1  2593 MHz       3718 s          0 s        209 s       2116 s          0 s
       #2  2593 MHz       4286 s          1 s        278 s       1512 s          0 s
       
  Memory: 6.791339874267578 GB (2254.109375 MB free)
  Uptime: 611.0 sec
  Load Avg:  1.46  1.31  0.75
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 21 May 2021 - 17:14
* Package commit: 0bf33d
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
| `["BootstrapFilter", "init_filter"]`         |   4.300 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |    9.153 s (5%) |   6.029 ms | 223.80 MiB (1%) |     1022711 |
| `["OptimalFilter", "init_filter"]`           |  87.649 ms (5%) |            | 123.58 MiB (1%) |         313 |
| `["OptimalFilter", "run_particle_filter"]`   |   33.736 s (5%) | 343.175 ms |   6.06 GiB (1%) |     1043312 |
| `["base", "get_log_weights!"]`               |   1.530 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   6.511 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.700 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 381.286 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 147.047 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 293.696 ms (5%) |            |   1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 293.882 ms (5%) |            |   1.00 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  19.652 ms (5%) |            |                 |             |

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
       #1  2593 MHz       2910 s          0 s        190 s       1353 s          0 s
       #2  2593 MHz       2997 s          1 s        218 s       1269 s          0 s
       
  Memory: 6.791339874267578 GB (1588.03125 MB free)
  Uptime: 451.0 sec
  Load Avg:  1.73  1.26  0.63
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, skylake-avx512)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 21 May 2021 - 17:17
* Package commit: a95cd1
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

| ID                                           | time            | GC time    | memory           | allocations |
|----------------------------------------------|----------------:|-----------:|-----------------:|------------:|
| `["BootstrapFilter", "init_filter"]`         |   3.200 μs (5%) |            |   33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |    9.169 s (5%) |  16.473 ms |  223.62 MiB (1%) |     1020889 |
| `["OptimalFilter", "init_filter"]`           |    7.686 s (5%) | 165.205 ms | 1005.80 MiB (1%) |    11894798 |
| `["OptimalFilter", "run_particle_filter"]`   |   41.419 s (5%) | 505.705 ms |    7.22 GiB (1%) |    19488313 |
| `["base", "get_log_weights!"]`               |   1.530 μs (5%) |            |                  |             |
| `["base", "get_mean_and_var!"]`              |   6.469 ms (5%) |            |    1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.700 ns (5%) |            |                  |             |
| `["base", "normalized_exp!"]`                | 380.793 ns (5%) |            |                  |             |
| `["base", "resample!"]`                      | 142.792 ns (5%) |            |   336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 295.801 ms (5%) |            |    1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 288.186 ms (5%) |            |    1.03 KiB (1%) |          12 |
| `["base", "update_truth!"]`                  |  19.463 ms (5%) |            |                  |             |

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
       #1  2593 MHz       3718 s          0 s        209 s       2116 s          0 s
       #2  2593 MHz       4286 s          1 s        278 s       1512 s          0 s
       
  Memory: 6.791339874267578 GB (2254.109375 MB free)
  Uptime: 611.0 sec
  Load Avg:  1.46  1.31  0.75
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

