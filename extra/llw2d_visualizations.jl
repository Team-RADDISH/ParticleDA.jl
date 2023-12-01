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

# ╔═╡ 3508a798-905c-11ee-21fa-f5fff35793da
begin
    using Pkg
    Pkg.activate(".")
    using ParticleDA
    using Plots
    using PlutoUI
    using PlutoLinks: @ingredients
    using HDF5
    using YAML
end

# ╔═╡ bdf320a8-2581-4529-b279-b536d9720c89
LLW2d = @ingredients("../test/models/llw2d.jl").LLW2d

# ╔═╡ 03e16c11-7c81-4a1c-ac21-9f2640811882
function plot_state_fields(
    state,
    model,
    title;
    show_station_locations=true,
    size=(900, 320),
)
    fields = LLW2d.flat_state_to_fields(state, model.parameters)
    boundary_size = (
        floor(Int, model.parameters.absorber_thickness_fraction * model.parameters.nx),
        floor(Int, model.parameters.absorber_thickness_fraction * model.parameters.ny)
    )
    index_1_range = boundary_size[1]:model.parameters.nx-boundary_size[1]
    index_2_range = boundary_size[2]:model.parameters.ny-boundary_size[2]
    plots = [
        heatmap(
            field[index_1_range, index_2_range],
            aspect_ratio=:equal,
            clims=(-scale, scale),
            xticks=nothing,
            yticks=nothing,
            cmap=:deep,
            legend=:none,
            title=label,
            xlims=(1, length(index_1_range)),
            ylims=(1, length(index_2_range)),
        )
        for (field, label, scale) in zip(
            eachslice(fields, dims=3), 
            ("Surface height", "Velocity component 1", "Velocity component 2"),
            (3, 300, 300),
        )
    ]
    if show_station_locations
        station_grid_indices = LLW2d.get_station_grid_indices(model.parameters)
        for observed_index in model.parameters.observed_state_var_indices
            scatter!(
                plots[observed_index],
                eachcol(station_grid_indices)...,
                xlims=(1, length(index_1_range)),
                ylims=(1, length(index_1_range)),
                marker=2
            )
        end
    end
    plot(
        plots...,
        plot_title=title,
        plot_titlevspan=-0.1,
        layout=grid(1, 3),
        size=size
    )
end

# ╔═╡ 6c6b7457-d77a-44fe-b37b-a4f5e34f25b7
function fields_to_state_vector(group)
    vcat((vec(read(group, key)) for key in ("height", "vx", "vy"))...)
end

# ╔═╡ e7d10ba9-1e28-4d2d-9b9b-bb7a9dfd345c
parameters = YAML.load_file("llw2d_parameters.yaml");

# ╔═╡ 746ef1cf-f99f-4cf4-9636-360fffe1dcdf
model = LLW2d.init(parameters["model"]);

# ╔═╡ 861dd61a-6ec1-4bf3-8ccd-dbe1381b88c5
num_time_step = parameters["simulate_observations"]["n_time_step"];

# ╔═╡ 847ec134-0807-49a3-8842-d81767a4dedb
state_true_sequence, state_mean_sequence, state_std_sequence = let
    state_eltype = ParticleDA.get_state_eltype(model)
    state_dimension = ParticleDA.get_state_dimension(model)
    
    state_true_seq = Matrix{state_eltype}(undef, num_time_step + 1, state_dimension)
    state_mean_seq = Matrix{state_eltype}(undef, num_time_step + 1, state_dimension)
    state_std_seq = Matrix{state_eltype}(undef, num_time_step + 1, state_dimension)
    h5open("llw2d_simulated.h5", "r") do file
        for t in 0:num_time_step
            key = ParticleDA.time_index_to_hdf5_key(t)
            state_true_seq[t + 1, :] = fields_to_state_vector(file["state"][key])
        end
    end
    h5open("llw2d_filtered.h5", "r") do file
        for t in 0:num_time_step
            key = ParticleDA.time_index_to_hdf5_key(t)
            state_mean_seq[t + 1, :] = fields_to_state_vector(file["state_avg"][key])
            state_std_seq[t + 1, :] = sqrt.(
                fields_to_state_vector(file["state_var"][key])
            )
        end
    end
    state_true_seq, state_mean_seq, state_std_seq
end;

# ╔═╡ 33e6291a-7035-42df-aa6e-2870f5d1a830
md"""
Timestep $(@bind timestep Slider(1:num_time_step; default=0, show_value=true))
"""

# ╔═╡ d25d3792-0a23-4e02-836b-6e3aa9060280
let
    plots = [
        plot_state_fields(
            view(state_true_sequence, timestep, :), model, "True state"
        ),
        plot_state_fields(
            view(state_mean_sequence, timestep, :), model, "Filtering estimate (mean)"
        )
    ]
    plot(plots..., layout=(2, 1), size=(900, 700))
end

# ╔═╡ Cell order:
# ╠═3508a798-905c-11ee-21fa-f5fff35793da
# ╠═bdf320a8-2581-4529-b279-b536d9720c89
# ╠═03e16c11-7c81-4a1c-ac21-9f2640811882
# ╠═6c6b7457-d77a-44fe-b37b-a4f5e34f25b7
# ╠═e7d10ba9-1e28-4d2d-9b9b-bb7a9dfd345c
# ╠═746ef1cf-f99f-4cf4-9636-360fffe1dcdf
# ╠═861dd61a-6ec1-4bf3-8ccd-dbe1381b88c5
# ╠═847ec134-0807-49a3-8842-d81767a4dedb
# ╟─33e6291a-7035-42df-aa6e-2870f5d1a830
# ╠═d25d3792-0a23-4e02-836b-6e3aa9060280
