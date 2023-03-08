### A Pluto.jl notebook ###
# v0.19.22

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
    import Pkg
    Pkg.activate("../test/Project.toml")
	using ParticleDA
	using Distributions
	using Random
	using HDF5
	using Plots
	using PlutoUI
end

# ╔═╡ 700179af-671c-4578-ab8b-4c7f6d7bf857
include("../test/models/anaet.jl")


# ╔═╡ 4715bcaa-b726-4439-aa38-22708a918df4
md"""
Number of particles $(@bind n_particle NumberField(1:500, default=100))\
Number of timesteps $(@bind n_time_step NumberField(1:1000, default=250))\
Filter type $(@bind filter_type Select([OptimalFilter, BootstrapFilter]))\
Initial state std. $(@bind initial_state_std NumberField(0:0.01:0.2, default=0.1))\
State noise std. $(@bind state_noise_std NumberField(0:0.01:0.1, default=0.02))\
Observation noise std. $(@bind observation_noise_std NumberField(0:0.1:1., default=0.5))\
Observed state indices $(@bind observed_indices MultiCheckBox([1, 2, 3], default=[1]))
"""

# ╔═╡ 4d57d231-78fb-4383-a559-da84444ff7c1
let
	observation_filename = tempname()
	output_filename = tempname()
	rng = Random.TaskLocalRNG()
	Random.seed!(rng, 1234)
	model_dict = Dict(
		"observation_noise_std" => observation_noise_std, 
		"initial_state_std" => initial_state_std,
		"state_noise_std" => state_noise_std,
		"observed_indices" => observed_indices,
	)
	model = ANAET.init(model_dict)
	observation_seq = h5open(observation_filename, "w") do file
		ParticleDA.simulate_observations_from_model(
			model, n_time_step; output_file=file, rng=rng
		)
	end
	filter_parameters = ParticleDA.FilterParameters(
		nprt=n_particle, verbose=true, output_filename=output_filename
	)
	isfile(output_filename) && rm(output_filename)
	states, statistics = ParticleDA.run_particle_filter(
		ANAET.init,
		filter_parameters, 
		model_dict, 
		observation_seq, 
		filter_type, 
		ParticleDA.MeanAndVarSummaryStat; 
		rng=rng
	)
	state_obs_seq = Matrix{Float64}(undef, 3, n_time_step)
	state_mean_seq = Matrix{Float64}(undef, 3, n_time_step)
	state_var_seq = Matrix{Float64}(undef, 3, n_time_step)
	weights_seq = Matrix{Float64}(undef, n_particle, n_time_step)
	h5open(observation_filename, "r") do file
		for t in 1:n_time_step
			key = ParticleDA.time_index_to_hdf5_key(t)
			state_obs_seq[:, t] = read(file["state"][key])
		end
	end
	h5open(output_filename, "r") do file
		for t in 1:n_time_step
			key = ParticleDA.time_index_to_hdf5_key(t)
			state_mean_seq[:, t] = read(file["state_avg"][key])
			state_var_seq[:, t] = read(file["state_var"][key])
			weights_seq[:, t] = read(file["weights"][key])
		end
	end
	plots = Array{Plots.Plot}(undef, 4)
	plots[1] = plot(
		1:n_time_step, 
		1 ./ sum(x -> x.^2, weights_seq; dims=1)[1, :],
		xlabel="Time index",
		label="Estimated ESS",
		legend=:outerright,
	)
	for (i, (m, v, s, l)) in enumerate(zip(
		eachrow(state_mean_seq), 
		eachrow(state_var_seq), 
		eachrow(state_obs_seq),
		("a", "ȧ", "b")
	))
		plots[i + 1] = plot(
			1:n_time_step,
			m,
			xlabel="Time index",
			ylabel=l,
			label="Filtering estimate",
			ribbon=3 * v.^0.5, 
			fillalpha=0.5,
			legend=:outerright,
		)
		plot!(plots[i + 1], 1:n_time_step, s, label="Truth")
		if i in observed_indices
			j = findfirst(isequal(i), observed_indices)
			plot!(
				plots[i + 1], 
				1:n_time_step,
				observation_seq[j, :],
				seriestype=[:scatter],
				label="Observations",
				markersize=2,
				markerstrokewidth=0,
			)
		end
	end
	plot(
		plots...,
		layout=(4, 1),
		size=(800, 800),
		left_margin=20Plots.px,
	)
end

# ╔═╡ Cell order:
# ╠═86be08c2-5337-4b00-bdcc-26a2f04ff162
# ╠═700179af-671c-4578-ab8b-4c7f6d7bf857
# ╠═4715bcaa-b726-4439-aa38-22708a918df4
# ╠═4d57d231-78fb-4383-a559-da84444ff7c1
