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

Note that with the default parameters, no output is written. The function `TDAC()` returns the true
state vector and the average state vector of the particles at the end of the simulation. To suppress
printing the return values on screen, use

```julia
TDAC.tdac();
```

The default parameters can be found in the file [parameters.jl](https://github.com/Team-RADDISH/TDAC.jl/blob/master/src/params.jl).
The parameter `verbose` is set to `false` to suppress the output. If `verbose` is set to `true`, 
`TDAC()` will produce a hdf5 file in the run directory. The file name is `tdac.h5` by default.
The file contains the true and assimilated ocean height at fixed time intervals. By default the output
time interval is set to 50 time steps. To read the output file, use the [HDF5 library](https://www.hdfgroup.org/solutions/hdf5/).
A basic plotting tool is provided with the package, see below.

To change parameters from the defaults, create a text file, and pass the path to it as an argument

```julia
TDAC.tdac("path/to/my/input/file")
```

The input file is in the yaml format. Each row contains `<parameter name> : <parameter value>`. 
For an example input file, see the [input file for the first integration test](https://github.com/Team-RADDISH/TDAC.jl/blob/master/test/integration_test_1.yaml). 
Any parameters not specified in the input file will retain their default values.

The particle state update is parallelised using both MPI and threading. According to our preliminary tests both methods work well at small scale. To use the threading, set the environment variable `JULIA_NUM_THREADS` to the number of threads you want to use before starting julia and then call the `tdac()` function normally. You can check the number of threads julia has available by calling in the julia REPL

```julia
Threads.nthreads()
```

To use the MPI parallelisation, write a julia script that calls the `tdac() ` function and run it in an unix shell with 

```bash
mpirun -np <your_number_of_processes> julia <your_julia_script>
```

## Plotting (Experimental)

To plot data produced by `TDAC.tdac()`, there is a [jupyter notebook](https://github.com/Team-RADDISH/TDAC.jl/blob/master/extra/Plot_tdac_output.ipynb) that plots contours of the tsunami height. Change the variable `timestamp` in the third cell to plot different time slices from the output file. More functionality may be added as the package develops.

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
