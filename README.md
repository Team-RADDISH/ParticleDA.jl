# TDAC

## Installation

To install the package, open the [Julia
REPL](https://docs.julialang.org/en/v1/stdlib/REPL/), enter the package manager
with `]`, then run the command

```
add https://github.com/Team-RADDISH/TDAC.jl.git
```

If you plan to develop the package (make changes, submit pull requests, etc), in
the package manager mode run this command

```
dev https://github.com/Team-RADDISH/TDAC.jl.git
```

This will automatically clone the repository to your local directory
`~/.julia/dev/TDAC`.

You can exit from the package manager mode by pressing `CTRL + C` or,
alternatively, the backspace key when there is no input in the prompt.

## Usage

After installing the package, you can start using the package in the Julia REPL
with

```julia
using TDAC
```

To run the simulation using default parameters, call the main function with no arguments

```julia
TDAC.tdac()
```

Note that with the default parameters, no output is produced. The default parameters can be 
found in the file [parameters.jl](https://github.com/Team-RADDISH/TDAC.jl/blob/master/src/params.jl).
The parameter `verbose` is set to `false` to suppress the output. If `verbose` is set to `true`, 
the code will produce two ascii files in the `out/` directory. The file `jl-syn__XXXXXX__.dat` 
contains the true state vector at time step XXXXXX. The file `jl-da__XXXXXX__.dat` contains the 
average state vector of all particles in the simualtion.

To change parameters from the defaults, create a text file, and pass the path to it as an argument

```julia
TDAC.tdac("path/to/my/input/file")
```

The input file is in the yaml format. Each row contains `<parameter name> : <parameter value>`. 
For an example input file, see the [input file for the first integration test](https://github.com/Team-RADDISH/TDAC.jl/blob/master/test/integration_test_1.yaml). 
Any parameters not specified in the input file will retain their default values.

## Testing

We have a basic test suite for `TDAC.jl`.  You can run the tests by entering the
package manager mode in the Julia REPL with `]` and running the command

```
test TDAC
```

## License

The `TDAC.jl` package is licensed under the MIT "Expat" License.  This is partly
based on the [tsunami data assimilation code](https://github.com/tktmyd/tdac) by
Takuto Maeda.
