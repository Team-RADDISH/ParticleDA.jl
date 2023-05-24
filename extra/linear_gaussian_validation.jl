### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 7eeee6d4-b299-11ed-22e4-0dcb77cafa96
begin
    import Pkg
    Pkg.activate("../Project.toml")
    using ParticleDA
    using LinearAlgebra
    using PDMats
    using FillArrays
    using Random
    using HDF5
    using Plots
    using Statistics
end

# ╔═╡ 116a8654-c619-4683-8d9a-073aa548fe37
include("../test/models/lineargaussian.jl")

# ╔═╡ 4d2656ca-eacb-4d2b-91cb-bc82fdb49520
include("../test/kalman.jl")

# ╔═╡ a64762bb-3a9f-4b1c-83db-f1a366f282eb
function plot_filtering_distribution_comparison(
    n_time_step,
    n_particle,
    filter_type,
    init_model,
    model_parameters_dict,
    seed,
)
    output_filename = tempname()
    rng = Random.TaskLocalRNG()
    Random.seed!(rng, seed)
    model = init_model(model_parameters_dict)
    observation_seq = ParticleDA.simulate_observations_from_model(
        model, n_time_step; rng=rng
    )
    true_state_mean_seq, true_state_var_seq = Kalman.run_kalman_filter(
        model, observation_seq
    )
    filter_parameters = ParticleDA.FilterParameters(
        nprt=n_particle, verbose=true, output_filename=output_filename
    )
    isfile(output_filename) && rm(output_filename)
    states, statistics = ParticleDA.run_particle_filter(
        init_model,
        filter_parameters, 
        model_parameters_dict, 
        observation_seq, 
        filter_type, 
        ParticleDA.MeanAndVarSummaryStat; 
        rng=rng
    )
    state_mean_seq = Matrix{ParticleDA.get_state_eltype(model)}(
        undef, ParticleDA.get_state_dimension(model), n_time_step
    )
    state_var_seq = Matrix{ParticleDA.get_state_eltype(model)}(
        undef, ParticleDA.get_state_dimension(model), n_time_step
    )
    weights_seq = Matrix{Float64}(undef, n_particle, n_time_step)
    h5open(output_filename, "r") do file
        for t in 1:n_time_step
            key = ParticleDA.time_index_to_hdf5_key(t)
            state_mean_seq[:, t] = read(file["state_avg"][key])
            state_var_seq[:, t] = read(file["state_var"][key])
            weights_seq[:, t] = read(file["weights"][key])
        end
    end
    plots = Array{Plots.Plot}(undef, 1 + ParticleDA.get_state_dimension(model))
    plots[1] = plot(
        1:n_time_step, 
        1 ./ sum(x -> x.^2, weights_seq; dims=1)[1, :],
        xlabel="Time index",
        label="Estimated ESS",
        legend=:outerright,
    )
    for (i, (m, v, tm, tv)) in enumerate(zip(
        eachrow(state_mean_seq), 
        eachrow(state_var_seq), 
        eachrow(true_state_mean_seq),
        eachrow(true_state_var_seq),
    ))
        plots[i + 1] = plot(
            1:n_time_step,
            m,
            xlabel="Time index",
            ylabel="\$x_$i\$",
            label="Filtering estimate",
            ribbon=3 * v.^0.5, 
            fillalpha=0.25,
            legend=:outerright,
        )
        plots[i + 1] = plot(
            plots[i + 1],
            1:n_time_step,
            tm,
            label="Truth",
            ribbon=3 * tv.^0.5, 
            fillalpha=0.25,
        )
    end
    plot(
        plots...,
        layout=(size(plots, 1), 1),
        size=(800, 800),
        left_margin=20Plots.px,
    )
end

# ╔═╡ 2ad564f3-48a2-4c2a-8d7d-384a84f7d6d2
function plot_filter_estimate_rmse_vs_n_particles(
    n_time_step,
    n_particles,
    init_model,
    model_parameters_dict,
    seed
)
    rng = Random.TaskLocalRNG()
    Random.seed!(rng, seed)
    model = init_model(model_parameters_dict)
    observation_seq = ParticleDA.simulate_observations_from_model(
        model, n_time_step; rng=rng
    )
    true_state_mean_seq, true_state_var_seq = Kalman.run_kalman_filter(
        model, observation_seq
    )
    plots = Array{Plots.Plot}(undef, 2)
    for (j, (filter_type, label)) in enumerate(
        zip(
            (BootstrapFilter, OptimalFilter), 
            ("Bootstrap proposal", "Locally optimal proposal")
        )
    )
        mean_rmses = Vector{Float64}(undef, length(n_particles))
        log_var_rmses = Vector{Float64}(undef, length(n_particles))
        for (i, n_particle) in enumerate(n_particles)
            output_filename = tempname()
            filter_parameters = ParticleDA.FilterParameters(
                nprt=n_particle, verbose=true, output_filename=output_filename
            )
            states, statistics = ParticleDA.run_particle_filter(
                LinearGaussian.init,
                filter_parameters, 
                model_parameters_dict, 
                observation_seq, 
                filter_type, 
                ParticleDA.MeanAndVarSummaryStat; 
                rng=rng
            )
            state_mean_seq = Matrix{ParticleDA.get_state_eltype(model)}(
                undef, ParticleDA.get_state_dimension(model), n_time_step
            )
            state_var_seq = Matrix{ParticleDA.get_state_eltype(model)}(
                undef, ParticleDA.get_state_dimension(model), n_time_step
            )
            weights_seq = Matrix{Float64}(undef, n_particle, n_time_step)
            h5open(output_filename, "r") do file
                for t in 1:n_time_step
                    key = ParticleDA.time_index_to_hdf5_key(t)
                    state_mean_seq[:, t] = read(file["state_avg"][key])
                    state_var_seq[:, t] = read(file["state_var"][key])
                    weights_seq[:, t] = read(file["weights"][key])
                end
            end
            mean_rmses[i] = sqrt(
                mean(x -> x.^2, state_mean_seq .- true_state_mean_seq)
            )
            log_var_rmses[i] = sqrt(
                mean(x -> x.^2, log.(state_var_seq) .- log.(true_state_var_seq))
            )
        end
        plots[j] = plot(
            n_particles,
            [mean_rmses, log_var_rmses],
            labels=["mean" "log(variance)"],
            xlabel="Number of particles",
            ylabel="RMSE(truth, estimate)",
            xaxis=:log,
            yaxis=:log,
            xticks=n_particles,
            title=label,
        )
    end
    plot(
        plots...,
        layout=(1, 2),
        size=(1000, 400),
        left_margin=20Plots.px,
        bottom_margin=20Plots.px,
    )
end

# ╔═╡ 89dae12b-0010-4ea1-ae69-490137196662
let
    n_time_step = 200
    n_particle = 100
    filter_type = BootstrapFilter
    seed = 20230222
    plot_filtering_distribution_comparison(
        n_time_step,
        n_particle,
        filter_type,
        LinearGaussian.init,
        LinearGaussian.diagonal_linear_gaussian_model_parameters(),
        seed
    )
end

# ╔═╡ 3e0abdfc-8668-431c-8ad3-61802e21d34e
let 
    n_particles = [10, 100, 1000, 10_000, 100_000]
    n_time_step = 200
    seed = 20230222
    figure = plot_filter_estimate_rmse_vs_n_particles(
        n_time_step,
        n_particles,
        LinearGaussian.init,
        LinearGaussian.diagonal_linear_gaussian_model_parameters(),
        seed
    )
    figure
end

# ╔═╡ 64a289be-75ce-42e2-9e43-8e0286f70a35
let
    n_time_step = 200
    n_particle = 100
    filter_type = BootstrapFilter
    seed = 20230222
    plot_filtering_distribution_comparison(
        n_time_step,
        n_particle,
        filter_type,
        LinearGaussian.init,
        LinearGaussian.stochastically_driven_dsho_model_parameters(),
        seed
    )
end

# ╔═╡ b396f776-885b-437a-94c3-693f318d7ed2
let
    n_time_step = 200
    n_particles = [10, 100, 1000, 10_000, 100_000]
    n_time_step = 200
    seed = 20230222
    figure = plot_filter_estimate_rmse_vs_n_particles(
        n_time_step,
        n_particles,
        LinearGaussian.init,
        LinearGaussian.stochastically_driven_dsho_model_parameters(),
        seed
    )
    figure
end

# ╔═╡ Cell order:
# ╠═7eeee6d4-b299-11ed-22e4-0dcb77cafa96
# ╠═116a8654-c619-4683-8d9a-073aa548fe37
# ╠═4d2656ca-eacb-4d2b-91cb-bc82fdb49520
# ╠═a64762bb-3a9f-4b1c-83db-f1a366f282eb
# ╠═2ad564f3-48a2-4c2a-8d7d-384a84f7d6d2
# ╠═89dae12b-0010-4ea1-ae69-490137196662
# ╠═3e0abdfc-8668-431c-8ad3-61802e21d34e
# ╠═64a289be-75ce-42e2-9e43-8e0286f70a35
# ╠═b396f776-885b-437a-94c3-693f318d7ed2
