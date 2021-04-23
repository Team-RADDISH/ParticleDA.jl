# Benchmark result

* Pull request commit: [`ef9951c749389448b096edc655053e1707a407d9`](https://github.com/Team-RADDISH/ParticleDA.jl/commit/ef9951c749389448b096edc655053e1707a407d9)
* Pull request: <https://github.com/Team-RADDISH/ParticleDA.jl/pull/176> (Support different noise parameters for each state variable)

# Judge result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmarks:
    - Target: 23 Apr 2021 - 15:36
    - Baseline: 23 Apr 2021 - 15:40
* Package commits:
    - Target: 8e1ac9
    - Baseline: afd102
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
| `["BootstrapFilter", "init_filter"]`         |                1.37 (5%) :x: |                   1.00 (1%)  |
| `["BootstrapFilter", "run_particle_filter"]` |                   1.02 (5%)  |                1.34 (1%) :x: |
| `["OptimalFilter", "init_filter"]`           | 0.01 (5%) :white_check_mark: | 0.10 (1%) :white_check_mark: |
| `["OptimalFilter", "run_particle_filter"]`   | 0.86 (5%) :white_check_mark: | 0.81 (1%) :white_check_mark: |
| `["base", "get_mean_and_var!"]`              | 0.94 (5%) :white_check_mark: |                   1.00 (1%)  |
| `["base", "update_particle_dynamics!"]`      |                   0.99 (5%)  | 0.89 (1%) :white_check_mark: |
| `["base", "update_particle_noise!"]`         |                1.17 (5%) :x: |               11.09 (1%) :x: |

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
  uname: Linux 5.4.0-1046-azure #48-Ubuntu SMP Tue Apr 13 07:18:42 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       3092 s          1 s        240 s       1821 s          0 s
       #2  2294 MHz       4008 s          1 s        223 s        932 s          0 s
       
  Memory: 6.791343688964844 GB (1175.140625 MB free)
  Uptime: 520.0 sec
  Load Avg:  1.73  1.35  0.72
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, broadwell)
```

### Baseline
```
Julia Version 1.6.0
Commit f9720dc2eb (2021-03-24 12:55 UTC)
Platform Info:
  OS: Linux (x86_64-pc-linux-gnu)
      Ubuntu 20.04.2 LTS
  uname: Linux 5.4.0-1046-azure #48-Ubuntu SMP Tue Apr 13 07:18:42 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       3974 s          1 s        271 s       2741 s          0 s
       #2  2294 MHz       5528 s          1 s        273 s       1195 s          0 s
       
  Memory: 6.791343688964844 GB (2417.578125 MB free)
  Uptime: 704.0 sec
  Load Avg:  1.44  1.36  0.85
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, broadwell)
```

---
# Target result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 23 Apr 2021 - 15:36
* Package commit: 8e1ac9
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
| `["BootstrapFilter", "init_filter"]`         |   3.700 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   13.520 s (5%) |   4.376 ms | 224.05 MiB (1%) |     1027048 |
| `["OptimalFilter", "init_filter"]`           |  99.281 ms (5%) |            | 123.58 MiB (1%) |         313 |
| `["OptimalFilter", "run_particle_filter"]`   |   46.246 s (5%) | 424.503 ms |   6.06 GiB (1%) |     1047636 |
| `["base", "get_log_weights!"]`               |   1.750 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   5.801 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.399 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 419.090 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 158.670 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 453.594 ms (5%) |            |   1.42 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 370.657 ms (5%) |            |  13.00 KiB (1%) |         203 |
| `["base", "update_truth!"]`                  |  26.293 ms (5%) |            |                 |             |

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
  uname: Linux 5.4.0-1046-azure #48-Ubuntu SMP Tue Apr 13 07:18:42 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       3092 s          1 s        240 s       1821 s          0 s
       #2  2294 MHz       4008 s          1 s        223 s        932 s          0 s
       
  Memory: 6.791343688964844 GB (1175.140625 MB free)
  Uptime: 520.0 sec
  Load Avg:  1.73  1.35  0.72
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, broadwell)
```

---
# Baseline result
# Benchmark Report for */home/runner/work/ParticleDA.jl/ParticleDA.jl*

## Job Properties
* Time of benchmark: 23 Apr 2021 - 15:40
* Package commit: afd102
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
| `["BootstrapFilter", "init_filter"]`         |   2.700 μs (5%) |            |  33.88 MiB (1%) |          13 |
| `["BootstrapFilter", "run_particle_filter"]` |   13.300 s (5%) |  50.903 ms | 167.41 MiB (1%) |      858891 |
| `["OptimalFilter", "init_filter"]`           |    8.597 s (5%) | 236.304 ms |   1.18 GiB (1%) |    14173997 |
| `["OptimalFilter", "run_particle_filter"]`   |   53.691 s (5%) | 656.496 ms |   7.44 GiB (1%) |    22178612 |
| `["base", "get_log_weights!"]`               |   1.760 μs (5%) |            |                 |             |
| `["base", "get_mean_and_var!"]`              |   6.171 ms (5%) |            |   1.48 KiB (1%) |          20 |
| `["base", "get_particles"]`                  |   1.399 ns (5%) |            |                 |             |
| `["base", "normalized_exp!"]`                | 424.623 ns (5%) |            |                 |             |
| `["base", "resample!"]`                      | 155.282 ns (5%) |            |  336 bytes (1%) |           1 |
| `["base", "update_particle_dynamics!"]`      | 457.086 ms (5%) |            |   1.59 KiB (1%) |          11 |
| `["base", "update_particle_noise!"]`         | 315.565 ms (5%) |            |   1.17 KiB (1%) |          11 |
| `["base", "update_truth!"]`                  |  25.892 ms (5%) |            |                 |             |

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
  uname: Linux 5.4.0-1046-azure #48-Ubuntu SMP Tue Apr 13 07:18:42 UTC 2021 x86_64 x86_64
  CPU: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz: 
              speed         user         nice          sys         idle          irq
       #1  2294 MHz       3974 s          1 s        271 s       2741 s          0 s
       #2  2294 MHz       5528 s          1 s        273 s       1195 s          0 s
       
  Memory: 6.791343688964844 GB (2417.578125 MB free)
  Uptime: 704.0 sec
  Load Avg:  1.44  1.36  0.85
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, broadwell)
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
    Vulnerability Itlb multihit:     KVM: Vulnerable
    Vulnerability L1tf:              Mitigation; PTE Inversion
    Vulnerability Mds:               Mitigation; Clear CPU buffers; SMT Host state unknown
    Vulnerability Meltdown:          Mitigation; PTI
    Vulnerability Spec store bypass: Vulnerable
    Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:        Mitigation; Full generic retpoline, STIBP disabled, RSB filling
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

