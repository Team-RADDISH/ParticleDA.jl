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
state vector, the average state vector of the particles and the standard deviation of the particles
at the end of the simulation. To suppress printing the return values on screen, use

```julia
TDAC.tdac();
```

### Setting Parameters

The default parameters can be found in the file [parameters.jl](https://github.com/Team-RADDISH/TDAC.jl/blob/master/src/params.jl). Or viewed in REPL by

```julia
?TDAC.tdac_parameters
```

To change parameters from the defaults, create a text file, and pass the path to it as an argument

```julia
TDAC.tdac("path/to/my/input/file")
```

The input file is in the `.yaml` format. Each row contains `<parameter name> : <parameter value>`. 
For an example input file, see the [input file for the first integration test](https://github.com/Team-RADDISH/TDAC.jl/blob/master/test/integration_test_1.yaml). Any parameters not specified in the input file 
will retain their default values.

#### Observation Station Coordinates

The coordinates of the observation stations can be set in two different ways. Either way, the parameter `nobs` 
should be set to the total number of observation stations.

1. Provide the coordinates in an input file. Set the parameter `station_filename` to the name of your input file.
   The input file is in plain text, the format is one row per station containing x, y - coordinates in metres. Here is
   a simple example with two stations
   
   ```julia
   # Comment lines starting with '#' will be ignored by the code
   # This file contains two stations: at [1km, 1km] and [2km, 2km]
   1.0e3, 1.0e3
   2.0e3, 2.0e3
   ```   
2. Provide parameters for an array of observation stations. The values of these parameters should be set:

   ```julia
   station_distance_x : Distance between stations in the x direction [m]
   station_distance_y : Distance between stations in the y direction [m]
   station_boundary_x : Distance between bottom left edge of box and first station in the x direction [m]
   station_boundary_y : Distance between bottom left edge of box and first station in the y direction [m]
   ```
   
   As an example, one could set
   
   ```julia
   nobs : 4
   station_distance_x : 1.0e3
   station_distance_y : 1.0e3
   station_boundary_x : 10.0e3
   station_boundary_y : 10.0e3
   ```
   
   to generate 4 stations at `[10km, 10km]`, `[10km, 11km]`, `[11km, 10km]` and `[11km, 11km]`. Note that when using this method, the square root of `nobs` has to be an integer.

### Output

If `verbose` is set to `true`, `TDAC()` will produce a hdf5 file in the run directory. The file name is `tdac.h5` by default. The file contains the true and assimilated ocean height, particle weights, parameters used, and other metadata at each data assimilation time step. To read the output file, use the [HDF5 library](https://www.hdfgroup.org/solutions/hdf5/).

A basic plotting tool is provided in a [jupyter notebook](https://github.com/Team-RADDISH/TDAC.jl/blob/master/extra/Plot_tdac_output.ipynb). This is intended as a template to build more sophisticated postprocessing tools, but can be used for some simple analysis. Set the variable `timestamp` in the third cell to plot different time slices from the output file. More functionality may be added as the package develops.

### Running in Parallel

The particle state update is parallelised using both MPI and threading. According to our preliminary tests both methods work well at small scale. To use the threading, set the environment variable `JULIA_NUM_THREADS` to the number of threads you want to use before starting julia and then call the `tdac()` function normally. You can check the number of threads julia has available by calling in the julia REPL

```julia
Threads.nthreads()
```

To use the MPI parallelisation, write a julia script that calls the `tdac() ` function and run it in an unix shell with 

```bash
mpirun -np <your_number_of_processes> julia <your_julia_script>
```

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
