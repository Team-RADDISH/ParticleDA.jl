### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 91e9009c-903f-11ee-2d75-653c9e327f0e
begin
    using Pkg
    Pkg.activate(".")
    using ParticleDA
    using PlutoLinks: @ingredients
    using HDF5
    using Random
    using YAML
end

# ╔═╡ 104a7d46-ff7e-4a72-b741-a4ddb24eb183
md"Load linear long-wave 2D (LLW2d) test model"

# ╔═╡ 669e5aec-64d9-46c6-bee6-c567be942651
LLW2d = @ingredients("../test/models/llw2d.jl").LLW2d

# ╔═╡ e53ad67c-945a-4259-b246-dbf389a91f2a
md"Define simulation, filtering and model parameters"

# ╔═╡ ecc9841a-1f37-4380-81a8-0e62a0f71969
begin
    const num_time_step = 100  # Number of time steps to simulate / filter
    const num_particle = 200  # Number of particles to use when filtering
    const filter_type = OptimalFilter  # Particle filter proposal type
    const statistics_type = ParticleDA.MeanAndVarSummaryStat
    const simulation_seed = 122023  # Random number generator seed for simulation
    const filtering_seed = 202312  # Random number generator seed for filtering
    const parameters_output_file_path = "llw2d_parameters.yaml"  # Parameters file
    const simulated_output_file_path = "llw2d_simulated.h5"  # Simulation output file
    const filtering_output_file_path = "llw2d_filtered.h5"  # Filtering output file
    const model_parameters = Dict(  # Parameters for LLW2d model
        "llw2d" => Dict(
            "x_length" => 200.0e3,
            "y_length" => 200.0e3,
            "nx" => 81,
            "ny" => 81,
            "n_stations_x" => 5,
            "n_stations_y" => 5,
            "station_boundary_x" => 20e3,
            "station_boundary_y" => 20e3,
            "station_distance_x" => 30e3,
            "station_distance_y" => 30e3,
            "obs_noise_std" => [0.05],
            "nu" => 2.5,
            "lambda" => 5.0e3,
            "sigma" => [0.05, 0.5, 0.5],
            "nu_initial_state" => 2.5,
            "lambda_initial_state" => 5.0e3,
            "sigma_initial_state" => [0.5, 5., 5.],
            "n_integration_step" => 10,
            "time_step" => 10.,
            "peak_height" => 30.0,
            "peak_position" => [1e4, 1e4],
            "observed_state_var_indices" => [1],
            "use_peak_initial_state_mean" => true,
            "padding" => 0,
        )
    )
end;

# ╔═╡ 8bd3da51-e8a4-407f-89d4-579cb36e16fb
md"Write parameters to a YAML file"

# ╔═╡ 4b430b41-ecde-4318-9ff3-9830c1d6b86a
YAML.write_file(
    parameters_output_file_path,
    Dict(
        "simulate_observations" => Dict(
            "seed" => simulation_seed,
            "n_time_step" => num_time_step,
        ),
        "model" => model_parameters,
        "filter" => Dict(
            "seed" => filtering_seed,
            "nprt" => num_particle
        ),
    )    
)

# ╔═╡ 7f75e9af-455e-4c22-90bf-65de7f2eed26
md"Simulate observations from LLW2d model to use in filtering and write to a HDF5 file"

# ╔═╡ aef60dc3-2770-4736-a7aa-48be09ee5a4f
const model, observation_sequence = let
    rng = Random.TaskLocalRNG()
    Random.seed!(rng, simulation_seed)
    model = LLW2d.init(model_parameters)
    isfile(simulated_output_file_path) && rm(simulated_output_file_path)
    observation_sequence = h5open(simulated_output_file_path, "cw") do output_file
        simulate_observations_from_model(
            model, num_time_step; output_file=output_file, rng=rng
        )
    end
    model, observation_sequence
end;

# ╔═╡ f4821041-671e-499f-962d-e02f54849a9f
md"Perform filtering with simulated observations and write outputs to a HDF5 file"

# ╔═╡ acbded08-c507-42c9-99ef-70f12685d02c
const final_particles, statistics = let
    rng = Random.TaskLocalRNG()
    Random.seed!(rng, filtering_seed)
    filter_parameters = ParticleDA.FilterParameters(
        nprt=num_particle,
        verbose=true,
        output_filename=filtering_output_file_path,
    )
    isfile(filtering_output_file_path) && rm(filtering_output_file_path)
    ParticleDA.run_particle_filter(
        LLW2d.init,
        filter_parameters,
        model_parameters,
        observation_sequence,
        filter_type,
        statistics_type;
        rng=rng
    )
end;

# ╔═╡ Cell order:
# ╠═91e9009c-903f-11ee-2d75-653c9e327f0e
# ╟─104a7d46-ff7e-4a72-b741-a4ddb24eb183
# ╠═669e5aec-64d9-46c6-bee6-c567be942651
# ╟─e53ad67c-945a-4259-b246-dbf389a91f2a
# ╠═ecc9841a-1f37-4380-81a8-0e62a0f71969
# ╟─8bd3da51-e8a4-407f-89d4-579cb36e16fb
# ╠═4b430b41-ecde-4318-9ff3-9830c1d6b86a
# ╟─7f75e9af-455e-4c22-90bf-65de7f2eed26
# ╠═aef60dc3-2770-4736-a7aa-48be09ee5a4f
# ╟─f4821041-671e-499f-962d-e02f54849a9f
# ╠═acbded08-c507-42c9-99ef-70f12685d02c
