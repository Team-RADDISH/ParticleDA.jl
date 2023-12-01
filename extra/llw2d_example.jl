### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 91e9009c-903f-11ee-2d75-653c9e327f0e
begin
	using Pkg
	Pkg.activate(".")
	using ParticleDA
	using Plots
	using PlutoLinks: @ingredients
	using HDF5
	using Random
end

# ╔═╡ 669e5aec-64d9-46c6-bee6-c567be942651
LLW2d = @ingredients("../test/models/llw2d.jl").LLW2d

# ╔═╡ d7c64491-765a-46ba-8f45-912112b5b357
const max_time_step = 100

# ╔═╡ b5e2b874-99d0-4303-8160-53323f710a83
const simulation_seed = 122023

# ╔═╡ 5295dc5c-b47e-4a1d-bd82-58a0f782e204
const filtering_seed = 202312

# ╔═╡ e0538f0d-d9d5-4e70-81e7-3e1a69dea33e
const llw2d_model_dict = Dict(
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
);

# ╔═╡ aef60dc3-2770-4736-a7aa-48be09ee5a4f
const model, observation_sequence = let
	rng = Random.TaskLocalRNG()
	Random.seed!(rng, simulation_seed)
	model = LLW2d.init(Dict("llw2d" => llw2d_model_dict))
	output_file_path = "llw2d_simulated.h5"
	isfile(output_file_path) && rm(output_file_path)
	observation_sequence = h5open(output_file_path, "cw") do output_file
		simulate_observations_from_model(
			model, max_time_step; output_file=output_file, rng=rng
		)
	end
	model, observation_sequence
end

# ╔═╡ acbded08-c507-42c9-99ef-70f12685d02c
const final_particles, statistics = let
	rng = Random.TaskLocalRNG()
	Random.seed!(rng, filtering_seed)
	output_file_path = "llw2d_filtering_outputs.h5"
	model_parameters_dict = Dict("llw2d" => llw2d_model_dict)
	filter_parameters = ParticleDA.FilterParameters(
		nprt=200,
		verbose=true,
		output_filename=output_file_path,
	)
	isfile(output_file_path) && rm(output_file_path)
	final_particles, statistics = ParticleDA.run_particle_filter(
		LLW2d.init,
		filter_parameters,
		model_parameters_dict,
		observation_sequence,
		ParticleDA.OptimalFilter,
		ParticleDA.MeanAndVarSummaryStat;
		rng=rng
	)
	final_particles, statistics
end

# ╔═╡ Cell order:
# ╠═91e9009c-903f-11ee-2d75-653c9e327f0e
# ╠═669e5aec-64d9-46c6-bee6-c567be942651
# ╠═d7c64491-765a-46ba-8f45-912112b5b357
# ╠═b5e2b874-99d0-4303-8160-53323f710a83
# ╠═5295dc5c-b47e-4a1d-bd82-58a0f782e204
# ╠═e0538f0d-d9d5-4e70-81e7-3e1a69dea33e
# ╠═aef60dc3-2770-4736-a7aa-48be09ee5a4f
# ╠═acbded08-c507-42c9-99ef-70f12685d02c
