### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 86be08c2-5337-4b00-bdcc-26a2f04ff162
begin
    using Pkg
    Pkg.activate(".")
    using ParticleDA
    using PlutoLinks: @ingredients
	using PlutoUI
	using Plots
    using HDF5
    using Random
	using Statistics
    using YAML
end

# ╔═╡ 7709ac00-728f-11ed-1f00-1f458e5ad3e2
Lorenz63 = @ingredients("../test/models/lorenz63.jl").Lorenz63

# ╔═╡ 16a443e1-7b7f-4ba5-8999-2dd59eed50d3
function load_simulation_outputs(output_filename) 
	h5open(output_filename, "r") do file
		n_time_step = length(file["observations"])
		observation_dim = length(first(file["observations"]))
		observation_eltype = eltype(first(file["observations"]))
		state_dim = length(first(file["state"]))
		state_eltype = eltype(first(file["state"]))
		observation_sequence = Matrix{observation_eltype}(
			undef, observation_dim, n_time_step
		)
		state_true_sequence = Matrix{state_eltype}(
			undef, state_dim, n_time_step
		)
		for t in 1:n_time_step
			key = ParticleDA.time_index_to_hdf5_key(t)
			observation_sequence[:, t] = read(file["observations"][key])
			state_true_sequence[:, t] = read(file["state"][key])
		end
		return observation_sequence, state_true_sequence
	end
end

# ╔═╡ cfb7be2d-772f-454f-b822-80899ed6ff55
function load_filtering_outputs(output_filename)
	h5open(output_filename, "r") do file
		n_time_step = length(file["weights"]) - 1
		state_dim = length(first(file["state_avg"]))
		state_eltype = eltype(first(file["state_avg"]))
		n_particle = length(first(file["weights"]))
		state_mean_sequence = Matrix{Float64}(undef, state_dim, n_time_step)
		state_std_sequence = Matrix{Float64}(undef, state_dim, n_time_step)
		weights_sequence = Matrix{Float64}(undef, n_particle, n_time_step)
		for t in 1:n_time_step
			key = ParticleDA.time_index_to_hdf5_key(t)
			state_mean_sequence[:, t] = read(file["state_avg"][key])
			state_std_sequence[:, t] = read(file["state_var"][key])
			weights_sequence[:, t] = read(file["weights"][key])
		end
		return state_mean_sequence, state_std_sequence, weights_sequence
	end
end

# ╔═╡ b10b319f-964a-43d0-a5fb-9847af748ae9
function plot_effective_sample_sizes(weights_sequence)
	n_time_step = size(weights_sequence, 2)
	ess_sequence = 1 ./ sum(x -> x.^2, weights_sequence; dims=1)[1, :]
	plot(
		1:n_time_step, 
		ess_sequence,
		xlabel="Time index",
		ylabel="Estimated ESS",
		size=(800, 200),
		legend=:none,
		margin=20Plots.px,
	)
end

# ╔═╡ 9243268a-daf7-450b-b275-ebebb3150c86
function plot_rmses(state_true_sequence, state_mean_sequence)
	n_time_step = size(state_mean_sequence, 2)
	rmse_sequence = sqrt.(
		mean(x -> x.^2, state_mean_sequence .- state_true_sequence; dims=1)
	)[1, :]
	plot(
		1:n_time_step,
		rmse_sequence,
		xlabel="Time index",
		ylabel="RMSE(mean, truth)",
		size=(800, 200),
		legend=:none,
		margin=20Plots.px,
	)
end

# ╔═╡ 01da3a88-aa3c-4f32-b5c8-cd447665a3be
function plot_3d_comparison(
	observed_indices,
	observation_sequence,
	state_true_sequence,
	state_mean_sequence,
)
	n_time_step = size(state_mean_sequence, 2)
	p = plot(size=(800, 800), xlabel="x₁", ylabel="x₂", zlabel="x₃")
	plot!(p, eachrow(state_true_sequence)..., label="True", )
	plot!(p, eachrow(state_mean_sequence)..., label="Filtering estimate (mean)")
end

# ╔═╡ f9c5199a-3cd3-44c8-9bfc-8b90a8d8c9b9
function plot_per_dimension_comparison(
	observed_indices,
	observation_sequence,
	state_true_sequence,
	state_mean_sequence,
	state_std_sequence,
)
	n_time_step = size(state_mean_sequence, 2)
	plots = Array{Plots.Plot}(undef, 3)
	for (i, (mean, std, state, label)) in enumerate(zip(
		eachrow(state_mean_sequence), 
		eachrow(state_std_sequence), 
		eachrow(state_true_sequence),
		["x₁", "x₂", "x₃"]
	))
		plots[i] = plot(
			1:n_time_step,
			mean,
			xlabel="Time index",
			ylabel=label,
			label="Filtering estimate",
			ribbon=3 * std, 
			fillalpha=0.5,
			legend=:outerright,
		)
		if i in observed_indices
			j = findfirst(isequal(i), observed_indices)
			plot!(
				plots[i], 
				1:n_time_step,
				observation_sequence[j, :],
				seriestype=[:scatter],
				label="Observations",
				markersize=2,
				markerstrokewidth=0,
			)
		end
		plot!(plots[i], 1:n_time_step, state, label="Truth")
	end
	plot(
		plots...,
		layout=(3, 1),
		size=(800, 800),
		margin=20Plots.px,
	)
end

# ╔═╡ 4715bcaa-b726-4439-aa38-22708a918df4
md"""
Number of particles $(@bind n_particle NumberField(1:1000, default=100))\
Number of timesteps $(@bind n_time_step NumberField(1:1000, default=500))\
Filter type $(@bind filter_type Select([OptimalFilter => "locally optimal", BootstrapFilter => "bootstrap"]))\
Initial state std. $(@bind initial_state_std NumberField(0:0.1:10, default=0.5))\
State noise std. $(@bind state_noise_std NumberField(0:0.1:10, default=0.5))\
Observation noise std. $(@bind observation_noise_std NumberField(0:0.1:10, default=1.))\
Observed state indices $(@bind observed_indices MultiCheckBox([1, 2, 3], default=[1,2,3]))
Show 3D plot $(@bind show_3d_plot CheckBox(default=true))
"""

# ╔═╡ 4d57d231-78fb-4383-a559-da84444ff7c1
let
	simulation_filename = tempname()
	filtering_filename = tempname()
	rng = Random.TaskLocalRNG()
	Random.seed!(rng, 1234)
	model_dict = Dict(
		"observation_noise_std" => observation_noise_std, 
		"initial_state_std" => initial_state_std,
		"state_noise_std" => state_noise_std,
		"observed_indices" => observed_indices,
	)
	model = Lorenz63.init(model_dict)
	h5open(simulation_filename, "w") do file
		ParticleDA.simulate_observations_from_model(
			model, n_time_step; output_file=file, rng=rng
		)
	end
	observation_sequence, state_true_sequence = load_simulation_outputs(
		simulation_filename
	)
	filter_parameters = ParticleDA.FilterParameters(
		nprt=n_particle, verbose=true, output_filename=filtering_filename
	)
	ParticleDA.run_particle_filter(
		Lorenz63.init,
		filter_parameters, 
		model_dict, 
		observation_sequence, 
		filter_type, 
		ParticleDA.MeanAndVarSummaryStat; 
		rng=rng
	)
	state_mean_sequence, state_std_sequence, weights_sequence = load_filtering_outputs(
		filtering_filename
	)
	ess_plot = plot_effective_sample_sizes(weights_sequence)
	rmse_plot = plot_rmses(state_true_sequence, state_mean_sequence)
	if show_3d_plot
		state_plot = plot_3d_comparison(
			observed_indices,
			observation_sequence,
			state_true_sequence,
			state_mean_sequence,
		)
	else
		state_plot = plot_per_dimension_comparison(
			observed_indices,
			observation_sequence,
			state_true_sequence,
			state_mean_sequence,
			state_std_sequence
		)
	end
	plot(
		ess_plot, rmse_plot, state_plot, 
		layout=grid(3, 1, heights=[0.15 ,0.15, 0.7]), 
		size=(800, 1200)
	)

end

# ╔═╡ Cell order:
# ╠═86be08c2-5337-4b00-bdcc-26a2f04ff162
# ╠═7709ac00-728f-11ed-1f00-1f458e5ad3e2
# ╠═16a443e1-7b7f-4ba5-8999-2dd59eed50d3
# ╠═cfb7be2d-772f-454f-b822-80899ed6ff55
# ╠═b10b319f-964a-43d0-a5fb-9847af748ae9
# ╠═9243268a-daf7-450b-b275-ebebb3150c86
# ╠═01da3a88-aa3c-4f32-b5c8-cd447665a3be
# ╠═f9c5199a-3cd3-44c8-9bfc-8b90a8d8c9b9
# ╟─4715bcaa-b726-4439-aa38-22708a918df4
# ╠═4d57d231-78fb-4383-a559-da84444ff7c1
