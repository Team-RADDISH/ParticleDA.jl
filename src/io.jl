using .Default_params

function write_params(params)

    file = h5open(params.output_filename, "cw")

    if !exists(file, params.title_params)

        group = g_create(file, params.title_params)

        fields = fieldnames(typeof(params));

        for field in fields

            attrs(group)[string(field)] = getfield(params, field)

        end

    else

        @warn "Write failed, group " * params.title_params * " already exists in " * file.filename * "!"

    end

    close(file)

end

function write_grid(params)

    h5open(params.output_filename, "cw") do file

        if !exists(file, params.title_grid)

            # Write grid axes
            x,y = get_axes(params)
            group = g_create(file, params.title_grid)
            #TODO: use d_write instead of d_create when they fix it in the HDF5 package
            ds_x,dtype_x = d_create(group, "x", collect(x))
            ds_y,dtype_x = d_create(group, "y", collect(x))
            ds_x[1:params.nx] = collect(x)
            ds_y[1:params.ny] = collect(y)
            attrs(ds_x)["Unit"] = "m"
            attrs(ds_y)["Unit"] = "m"

        else

            @warn "Write failed, group " * params.title_grid * " already exists in " * file.filename * "!"

        end

    end

end

function write_stations(ist::AbstractVector, jst::AbstractVector, params::tdac_params) where T

    h5open(params.output_filename, "cw") do file

        if !exists(file, params.title_stations)
            group = g_create(file, params.title_stations)

            for (dataset_name, index, d) in zip(("x", "y"), (ist, jst), (params.dx, params.dy))
                ds, dtype = d_create(group, dataset_name, index)
                ds[:] = index .* d
                attrs(ds)["Description"] = "Station coordinates"
                attrs(ds)["Unit"] = "m"
            end
        else
            @warn "Write failed, group " * params.title_stations * " already exists in " * file.filename * "!"
        end
    end
end

function write_snapshot(truth::AbstractArray{T,3},
                        avg::AbstractArray{T,3},
                        var::AbstractArray{T,3},
                        weights::AbstractVector{T},
                        it::Int,
                        params::tdac_params) where T

    if params.verbose
        println("Writing output at timestep = ", it)
    end

    h5open(params.output_filename, "cw") do file

        dset_height = "height"
        dset_vx = "vx"
        dset_vy = "vy"

        desc_height = "Ocean surface height"
        desc_vx = "Ocean surface velocity x-component"
        desc_vy = "Ocean surface velocity y-component"

        write_field(file, @view(truth[:,:,1]), it, "m", params.title_syn, dset_height, desc_height, params)
        write_field(file, @view(avg[:,:,1]), it, "m"  , params.title_avg, dset_height, desc_height, params)
        write_field(file, @view(var[:,:,1]), it, "m^2", params.title_var, dset_height, desc_height, params)

        write_field(file, @view(truth[:,:,2]), it, "m/s",   params.title_syn, dset_vx, desc_vx, params)
        write_field(file, @view(avg[:,:,2]), it, "m/s"  ,   params.title_avg, dset_vx, desc_vx, params)
        write_field(file, @view(var[:,:,2]), it, "m^2/s^2", params.title_var, dset_vx, desc_vx, params)

        write_field(file, @view(truth[:,:,3]), it, "m/s",   params.title_syn, dset_vy, desc_vy, params)
        write_field(file, @view(avg[:,:,3]), it, "m/s"  ,   params.title_avg, dset_vy, desc_vy, params)
        write_field(file, @view(var[:,:,3]), it, "m^2/s^2", params.title_var, dset_vy, desc_vy, params)

        write_weights(file, weights, "", it, params)
    end

end

function create_or_open_group(file::HDF5File, group_name::String, subgroup_name::String = "None")

    if !exists(file, group_name)
        group = g_create(file, group_name)
    else
        group = g_open(file, group_name)
    end

    if subgroup_name != "None"
        if !exists(group, subgroup_name)
            subgroup = g_create(group, subgroup_name)
        else
            subgroup = g_open(group, subgroup_name)
        end
    else
        subgroup = nothing
    end

    return group, subgroup

end

function write_weights(file::HDF5File, weights::AbstractVector, unit::String, it::Int, params::tdac_params)

    group_name = "weights"
    dataset_name = "t" * string(it)

    group, subgroup = create_or_open_group(file, group_name)

    if !exists(group, dataset_name)
        #TODO: use d_write instead of d_create when they fix it in the HDF5 package
        ds,dtype = d_create(group, dataset_name, weights)
        ds[:] = weights
        attrs(ds)["Description"] = "Particle Weights"
        attrs(ds)["Unit"] = unit
        attrs(ds)["Time_step"] = it
        attrs(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end

end

function write_field(file::HDF5File,
                     field::AbstractMatrix{T},
                     it::Int,
                     unit::String,
                     group::String,
                     dataset::String,
                     description::String,
                     params::tdac_params) where T

    group_name = params.state_prefix * "_" * group
    subgroup_name = "t" * string(it)
    dataset_name = dataset

    group, subgroup = create_or_open_group(file, group_name, subgroup_name)

    if !exists(subgroup, dataset_name)
        #TODO: use d_write instead of d_create when they fix it in the HDF5 package
        ds,dtype = d_create(subgroup, dataset_name, field)
        ds[:,:] = field
        attrs(ds)["Description"] = description
        attrs(ds)["Unit"] = unit
        attrs(ds)["Time_step"] = it
        attrs(ds)["Time (s)"] = it * params.time_step
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end
end

function write_timers(length::Int, size::Int, chars::AbstractVector{Char}, params::tdac_params)

    write_timers(length, size, chars, params.output_filename)

end

function write_timers(length::Int, size::Int, chars::AbstractVector{Char}, filename::String)

    group_name = "timer"

    h5open(filename, "cw") do file

        if !exists(file, group_name)
            group = g_create(file, group_name)
        else
            group = g_open(file, group_name)
        end

        for i in 1:size
            timer_string = String(chars[(i - 1) * length + 1 : i * length])
            dataset_name = "rank" * string(i-1)

            if !exists(group, dataset_name)
                ds,dtype = d_create(group, dataset_name, timer_string)
                write(ds,timer_string)
            else
                @warn "Write failed, dataset " * group_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
            end
        end
    end
end
