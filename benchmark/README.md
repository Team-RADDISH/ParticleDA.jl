# Running benchmarks

We use [`PkgBenchmark.jl`](https://github.com/JuliaCI/PkgBenchmark.jl) and
[`BenchmarkCI.jl`](https://github.com/tkf/BenchmarkCI.jl) to run benchmarks for
this package.  Benchmarks can be run in two different modes:

* only on the current branch;
* on the current branch and the default one, comparing the results between the
  two to highlight performance improvements and regressions.  This is
  automatically run in all pull requests opened in the GitHub repository.

## Run benchmarks on the current branch

Before running the benchmarks, activate the environment of the `benchmark/`
directory with:

```julia
using Pkg, ParticleDA
Pkg.activate(joinpath(pkgdir(ParticleDA), "benchmark"))
Pkg.instantiate()
```

To run the benchmarks, execute the commands

```julia
using PkgBenchmark, ParticleDA
benchmarkpkg(ParticleDA)
```

See the docstring of
[`PkgBenchmark.benchmarkpkg`](https://juliaci.github.io/PkgBenchmark.jl/stable/run_benchmarks/#PkgBenchmark.benchmarkpkg)
for more details about its usage, but note you can pass a configuration like

```
benchmarkpkg(ParticleDA, BenchmarkConfig(; env = Dict("JULIA_NUM_THREADS" => 2)))
```

to specify the number of threads.

Remember you can go back to the top-level environment in Julia with

```julia
Pkg.activate()
```

or in the Pkg REPL mode with:

```julia
]activate
```

## Compare benchmarks on the current branch and the default one

In addition to activating the `benchmark/` environment as shown above:

```julia
using Pkg, ParticleDA
Pkg.activate(joinpath(pkgdir(ParticleDA), "benchmark"))
Pkg.instantiate()
```

you need to change the working directory to the root folder of `ParticleDA`:

```julia
cd(pkgdir(ParticleDA))
```

You can run the benchmarks with

```julia
using PkgBenchmark, BenchmarkCI
BenchmarkCI.judge() # run the benchmarks 
BenchmarkCI.displayjudgement() # show the results in the terminal
```

Note that you can pass a
[`PkgBenchmark.BenchmarkConfig`](https://juliaci.github.io/PkgBenchmark.jl/stable/run_benchmarks/#PkgBenchmark.BenchmarkConfig)
also to
[`BenchmarkCI.judge`](https://tkf.github.io/BenchmarkCI.jl/dev/#BenchmarkCI.judge)

```julia
BenchmarkCI.judge(BenchmarkConfig(; env = Dict("JULIA_NUM_THREADS" => 2)))
```

Note: remember that you should not have uncommitted changes in the local
repository in order to run benchmarks with `BenchmarkCI`, because it needs to
automatically switch to the default branch.
