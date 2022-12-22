# ParticleDA.jl

[`ParticleDA.jl`](https://github.com/Team-RADDISH/ParticleDA.jl) is a Julia
package to perform data assimilation with particle filters, distributed using MPI.

## Installation

To install the package, open [Julia's REPL](https://docs.julialang.org/en/v1/stdlib/REPL/), 
enter the package manager with `]`, then run the command

```
add https://github.com/Team-RADDISH/ParticleDA.jl.git
```

If you plan to develop the package (make changes, submit pull requests, etc), in
the package manager mode run this command

```
dev https://github.com/Team-RADDISH/ParticleDA.jl.git
```

This will automatically clone the repository to your local directory
`~/.julia/dev/ParticleDA`.

You can exit from the package manager mode by pressing `CTRL + C` or,
alternatively, the backspace key when there is no input in the prompt.

## Usage

After installing the package, you can start using it in Julia's REPL with

```julia
using ParticleDA
```

The run the particle filter you can use the function `run_particle_filter`:

```@docs
run_particle_filter
```

To simulate observations from the model (which can be used to for example test the
filtering algorithms) you can use the function `simulate_observations_from_model`

```@docs
simulate_observations_from_model
```

The `filter_type` argument to [`run_particle_filter`](@ref) should be a concrete subtype
of the `ParticleFilter` abstract type.

```@docs
ParticleDA.ParticleFilter
BootstrapFilter
OptimalFilter
```

The next section details how to write the interface between the model and the
particle filter.

### Interfacing the model

The model needs to define a custom data structure and a few functions, that will
be used by [`run_particle_filter`](@ref):

* a custom structure which holds the data about the model.  This will be used to
  dispatch the methods to be defined, listed below;
* an initialisation function with the following signature:
  ```julia
  init(params_dict::Dict) -> model
  ```
  with `params_dict` a dictionary with the parameters of the model. This initialisation 
  function should create an instance of the model data structure and return it.
* The model needs to extend the following methods, using the model type for dispatch:
```@docs
ParticleDA.get_state_dimension
ParticleDA.get_observation_dimension
ParticleDA.get_state_eltype
ParticleDA.get_observation_eltype
ParticleDA.sample_initial_state!
ParticleDA.update_state_deterministic!
ParticleDA.update_state_stochastic!
ParticleDA.sample_observation_given_state!
ParticleDA.get_log_density_observation_given_state
ParticleDA.write_model_metadata
```
* Optionally, if the model has additive Gaussian observation and state noise, it may
  also extend the following methods, again using the model type for dispatch, to allow
  using the more statistically efficient `OptimalFilter` for filtering
```@docs
ParticleDA.get_observation_mean_given_state!
ParticleDA.get_covariance_state_noise
ParticleDA.get_covariance_observation_noise
ParticleDA.get_covariance_state_observation_given_previous_state
ParticleDA.get_covariance_observation_observation_given_previous_state
```

### Input parameters

You can store the input parameters in an YAML file with the following structure
```yaml
filter:
  key1: value1

model:
  model_name1:
    key2: value2
    key3: value3
  model_name2:
    key4: value4
    key5: value5
```
The parameters under `filter` are related to the particle filter, under `model`
you can specify the parameters for different models.

The particle filter parameters are saved in the following data structure:
```@docs
ParticleDA.FilterParameters
```

## Example: estimating the state in a tsunami model

A full example of a model interfacing `ParticleDA` is available in `test/models/llw2d.jl`. 
This model represents a simple two dimensional simulation of tsunami dynamics and is 
partly based on the [tsunami data assimilation code](https://github.com/tktmyd/tdac) by 
Takuto Maeda. The particle filter can be run with observations simulated from the model
as follows

```julia
# Load ParticleDA
using ParticleDA

# Save some variables for later use
test_dir = joinpath(dirname(pathof(ParticleDA)), "..", "test")
llw2d_src = joinpath(test_dir, "models", "llw2d.jl")
input_file = joinpath(test_dir, "integration_test_1.yaml")
observation_file = tempname()

# Instantiate the test environment
using Pkg
Pkg.activate(test_dir)
Pkg.instantiate()

# Include the sample model source code and load it
include(llw2d_src)
using .LLW2d

# Simulate observations from the model to use 
simulate_observations_from_model(LLW2d.init, input_file, observation_file)

# Run the (optimal proposal) particle filter with simulated observations
final_states, final_statistics = run_particle_filter(
  LLW2d.init, input_file, observation_file, OptimalFilter
)
```

### Parameters of the test model

The [Input parameters](@ref) section shows how to pass the input parameters for
the filter and the model.  For the model included in the test suite, called
`llw2d`, you can set the following parameters:

```@docs
LLW2d.LLW2dModelParameters
```

### Observation station coordinates

The coordinates of the observation stations can be set in two different ways.

1. Provide the coordinates in an input file. Set the parameter `station_filename` to the name of your input file.
   The input file is in plain text, the format is one row per station containing x, y - coordinates in metres. Here is
   a simple example with two stations

   ```julia
   # Comment lines starting with '#' will be ignored by the code
   # This file contains two stations: at [1km, 1km] and [2km, 2km]
   1.0e3, 1.0e3
   2.0e3, 2.0e3
   ```
2. Provide parameters for an equispaced rectilinear grid of observation stations. The values of these parameters should then be set:

   * `n_stations_x` : Number of observation stations in the x direction
   * `n_stations_y` : Number of observation stations in the y direction
   * `station_distance_x` : Distance between stations in the x direction (m)
   * `station_distance_y` : Distance between stations in the y direction (m)
   * `station_boundary_x` : Distance between bottom left edge of box and first station in the x direction (m)
   * `station_boundary_y` : Distance between bottom left edge of box and first station in the y direction (m)
   
   As an example, one could set

   ```julia
   n_stations_x=2,
   n_stations_y=2,
   station_distance_x=1.0e3,
   station_distance_y=1.0e3,
   station_boundary_x=10.0e3,
   station_boundary_y=10.0e3,
   ```

   to generate 4 stations at `[10km, 10km]`, `[10km, 11km]`, `[11km, 10km]` and `[11km, 11km]`.

## Output

If the filter parameter `verbose` is set to `true`, [`run_particle_filter`](@ref) will produce an HDF5 file in the run directory. The file name is `particle_da.h5` by default (this is configurable using the `output_filename` filter parameter). The file contains the summary statistics of the estimate state distribution (by default the mean and variance), particle weights, parameters used, and other metadata at each time step observation were assimilated. To read the output file, use the [HDF5 library](https://www.hdfgroup.org/solutions/hdf5/).

A basic plotting tool is provided in a [Jupyter notebook](https://github.com/Team-RADDISH/ParticleDA.jl/blob/master/extra/Plot_tdac_output.ipynb). This is intended as a template to build more sophisticated postprocessing tools, but can be used for some simple analysis. Set the variable `timestamp` in the third cell to plot different time slices from the output file. More functionality may be added as the package develops.

## Running in parallel

The particle state update is parallelised using both MPI and threading. According to our preliminary tests both methods work well at small scale. To use the threading, set the environment variable `JULIA_NUM_THREADS` to the number of threads you want to use before starting Julia and then call the [`run_particle_filter`](@ref) function normally. You can check the number of threads julia has available by calling in Julia's REPL

```julia
Threads.nthreads()
```

To use the MPI parallelisation, write a Julia script that calls the [`run_particle_filter`](@ref) function for the relevant model and observations and run it in an Unix shell with

```bash
mpirun -np <your_number_of_processes> julia <your_julia_script>
```

Note that the parallel performance may vary depending on the performance of the algorithm. In general, a degeneracy of the particle weights will lead to poor load balance and parallel performance. See [this issue](https://github.com/Team-RADDISH/ParticleDA.jl/issues/115#issuecomment-675468511) for more details.

## Testing

We have a basic test suite for `ParticleDA.jl`.  You can run the tests by entering the
package manager mode in Julia's REPL with `]` and running the command

```
test ParticleDA
```

## License

The `ParticleDA.jl` package is licensed under the MIT "Expat" License.
