# ParticleDA

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://team-raddish.github.io/ParticleDA.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://team-raddish.github.io/ParticleDA.jl/dev/)
[![Build Status](https://github.com/Team-RADDISH/ParticleDA.jl/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Team-RADDISH/ParticleDA.jl/actions/workflows/ci.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Team-RADDISH/ParticleDA.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Team-RADDISH/ParticleDA.jl)
[![DOI](https://zenodo.org/badge/232626497.svg)](https://zenodo.org/badge/latestdoi/232626497)
[![DOI:10.5194/gmd-2023-38](https://img.shields.io/badge/Journal_article-10.5194/gmd--2023--38-d4a519.svg)](https://doi.org/10.5194/gmd-2023-38)


`ParticleDA.jl` is a Julia package to perform data assimilation with particle filters, 
supporting both thread-based parallelism and distributed processing using MPI.

This project is developed in collaboration with the
[Centre for Advanced Research Computing](https://ucl.ac.uk/arc), University College London.

## Installation

To install the latest stable version of the package, open the [Julia
REPL](https://docs.julialang.org/en/v1/stdlib/REPL/), enter the package manager
with `]`, then run the command

```
add ParticleDA
```

If you plan to develop the package (make changes, submit pull requests, etc), in
the package manager mode run this command

```
dev ParticleDA
```

This will automatically clone the repository to your local directory
`~/.julia/dev/ParticleDA`.

You can exit from the package manager mode by pressing `CTRL + C` or,
alternatively, the backspace key when there is no input in the prompt.

## Documentation

[Documentation Website](https://team-raddish.github.io/ParticleDA.jl/dev/)

## License

The `ParticleDA.jl` package is licensed under the MIT "Expat" License.
