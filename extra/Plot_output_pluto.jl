### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ c7383ff4-ba4c-11eb-1977-b31b330b20d0
begin
	import Pkg
	Pkg.activate(@__DIR__)
	Pkg.instantiate()
	using Plots
	using HDF5
	using Unitful
	using UnitfulRecipes
	using PlutoUI
end

# ╔═╡ 3e85f1c4-32ca-4e8e-ab9f-2fefaaabffb7
md"## Load HDF5 output file"

# ╔═╡ 72c703c9-3c32-45ab-b910-25a3c6652bdc
filename = "particle_da.h5"

# ╔═╡ 7cbbad5a-3767-422c-9d6b-f32524d4bf04
fh = h5open(filename, "r")

# ╔═╡ 7c316637-defe-4f60-a7e5-2e10511f7044
md"## Set these parameters to choose what to plot"

# ╔═╡ e1acfe11-0ead-4ada-946e-eff674e6d44e
begin
	timestamps = keys(fh["data_syn"])
	md"""
	Select the timestamp
	$(@bind timestamp_idx Slider(1:length(timestamps)))
	"""
end

# ╔═╡ 775fbb1e-a760-4862-829d-455051942255
timestamp = timestamps[timestamp_idx]

# ╔═╡ d442ef52-1566-484d-af31-ba3565307502
md"""
Select the field
$(@bind field Select([f => f for f in keys(fh["data_syn"]["t0000"])]))
"""

# ╔═╡ 384116c1-ed19-4a8c-85a7-6c0dfd9c164f
md"## Contour plots of surface height"

# ╔═╡ 8f67e2b3-9a01-42a3-a56a-11b84776a5e1
md"## Scatter plot of particle weights"

# ╔═╡ a35f5895-5066-4e1d-b252-6172888aa92d
begin
	weights = read(fh["weights"][timestamp])

	p1 = scatter(weights, marker=:star)
	p2 = scatter(weights, marker=:star, yscale=:log10)

	for plt in (p1, p2)
	    plot!(plt; xlabel="Particle ID", ylabel="Weight")
	end

	plot(p1, p2, label="")
end

# ╔═╡ e5335e14-bdb6-432c-94ab-c666c304efc6
md"## Time series of Estimated Sample Size"

# ╔═╡ 343a1d50-38f8-4457-81dc-5d962a2acb4a
plot([1 / sum(read(w) .^ 2) for w in fh["weights"]];
     label="", marker=:o, xlabel="Time step", ylabel="Estimated Sample Size (1 / sum(weight^2))")

# ╔═╡ a52a3f7e-1d8e-4153-b0c2-2cb47584c447
md"## Animation"

# ╔═╡ 8520dcbb-0bd8-4020-aea3-009e24df2099
md"## Collect data from the output file"

# ╔═╡ cff1a64f-03ba-4150-9501-fa4803901808
# All time-independent quantities
begin
	field_unit = read(fh["data_syn"]["t0000"][field]["Unit"])
	var_unit = read(fh["data_var"]["t0000"][field]["Unit"])

	field_desc = read(fh["data_syn"]["t0000"][field]["Description"])

	x_unit = read(fh["grid"]["x"]["Unit"])
	y_unit = read(fh["grid"]["y"]["Unit"])
	x_st_unit = read(fh["stations"]["x"]["Unit"])
	y_st_unit = read(fh["stations"]["y"]["Unit"])

	x = read(fh["grid"]["x"]) .* uparse(x_unit) .|> u"km"
	y = read(fh["grid"]["y"]) .* uparse(y_unit) .|> u"km"

	x_st = read(fh["stations"]["x"]) .* uparse(x_st_unit) .|> u"km"
	y_st = read(fh["stations"]["y"]) .* uparse(y_st_unit) .|> u"km"
end

# ╔═╡ e17da3a7-39e4-4326-aa2e-08f70b574878
function plot_data(x, y, z_t, z_avg, z_std, field_desc)
    n_contours = 100
    zmax = max(maximum(z_t), maximum(z_avg))
    zmin = min(minimum(z_t), minimum(z_avg))
    levels = range(zmin, zmax; length=n_contours)

    # Note that for heatmaps we need to permute the dimensions of the z matrix
    p1 = heatmap(x, y, z_t'; title="True $(lowercase(field_desc))")
    p2 = heatmap(x, y, z_avg'; title="Assimilated $(lowercase(field_desc))")
    p3 = heatmap(x, y, z_std'; title="Std of assimilated $(lowercase(field_desc))")

    for (i, plt) in enumerate((p1, p2, p3))
        # Set labels
        plot!(plt; xlabel="x", ylabel="y")
        # Set range of color bar for first two plots
        i ∈ (1, 2) && plot!(plt; clims=(ustrip(zmin), ustrip(zmax)))
        # Add the positions of the stations
        scatter!(plt, x_st, y_st, color=:red, marker=:star, label="")
    end

    plot(p1, p2, p3; titlefontsize=8, guidefontsize=8)
end

# ╔═╡ ba33b9a1-7d73-4247-b298-ccf30acc8859
function animate_data(fh, field, field_unit, var_unit, x, y)
	animation = @animate for timestamp ∈ keys(fh["data_syn"])
	    z_t = read(fh["data_syn"][timestamp][field]) .* uparse(field_unit)
	    z_avg = read(fh["data_avg"][timestamp][field]) .* uparse(field_unit)
	    z_std = sqrt.(read(fh["data_var"][timestamp][field]) .* uparse(var_unit))

	    plot_data(x, y, z_t, z_avg, z_std, field_desc)
	end

	return mp4(animation, "animation_jl.mp4"; fps=5)
end

# ╔═╡ a9343779-de40-4d33-8487-27d53ec095c0
animate_data(fh, field, field_unit, var_unit, x, y)

# ╔═╡ da1315e0-71de-4df6-9d74-259979571e1e
# Quantities specific to the current timestamp
begin
	z_t = read(fh["data_syn"][timestamp][field]) .* uparse(field_unit)
	z_avg = read(fh["data_avg"][timestamp][field]) .* uparse(field_unit)
	z_std = sqrt.(read(fh["data_var"][timestamp][field]) .* uparse(var_unit))
end

# ╔═╡ 1d230245-5f29-4895-b0cb-4e49f6c125ff
plot_data(x, y, z_t, z_avg, z_std, field_desc)

# ╔═╡ Cell order:
# ╠═c7383ff4-ba4c-11eb-1977-b31b330b20d0
# ╟─3e85f1c4-32ca-4e8e-ab9f-2fefaaabffb7
# ╠═72c703c9-3c32-45ab-b910-25a3c6652bdc
# ╟─7cbbad5a-3767-422c-9d6b-f32524d4bf04
# ╟─7c316637-defe-4f60-a7e5-2e10511f7044
# ╟─e1acfe11-0ead-4ada-946e-eff674e6d44e
# ╟─775fbb1e-a760-4862-829d-455051942255
# ╟─d442ef52-1566-484d-af31-ba3565307502
# ╟─384116c1-ed19-4a8c-85a7-6c0dfd9c164f
# ╟─e17da3a7-39e4-4326-aa2e-08f70b574878
# ╟─1d230245-5f29-4895-b0cb-4e49f6c125ff
# ╟─8f67e2b3-9a01-42a3-a56a-11b84776a5e1
# ╟─a35f5895-5066-4e1d-b252-6172888aa92d
# ╟─e5335e14-bdb6-432c-94ab-c666c304efc6
# ╟─343a1d50-38f8-4457-81dc-5d962a2acb4a
# ╟─a52a3f7e-1d8e-4153-b0c2-2cb47584c447
# ╟─ba33b9a1-7d73-4247-b298-ccf30acc8859
# ╟─a9343779-de40-4d33-8487-27d53ec095c0
# ╟─8520dcbb-0bd8-4020-aea3-009e24df2099
# ╟─cff1a64f-03ba-4150-9501-fa4803901808
# ╟─da1315e0-71de-4df6-9d74-259979571e1e
