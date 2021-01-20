using .Default_params

function create_or_open_group(file::HDF5.File, group_name::String, subgroup_name::String = "None")

    if !haskey(file, group_name)
        group = create_group(file, group_name)
    else
        group = open_group(file, group_name)
    end

    if subgroup_name != "None"
        if !haskey(group, subgroup_name)
            subgroup = create_group(group, subgroup_name)
        else
            subgroup = open_group(group, subgroup_name)
        end
    else
        subgroup = nothing
    end

    return group, subgroup

end

function write_timers(length::Int, size::Int, chars::AbstractVector{Char}, params::FilterParameters)

    write_timers(length, size, chars, params.output_filename)

end

function write_timers(length::Int, size::Int, chars::AbstractVector{Char}, filename::String)

    group_name = "timer"

    h5open(filename, "cw") do file

        if !haskey(file, group_name)
            group = create_group(file, group_name)
        else
            group = open_group(file, group_name)
        end

        for i in 1:size
            timer_string = String(chars[(i - 1) * length + 1 : i * length])
            dataset_name = "rank" * string(i-1)

            if !haskey(group, dataset_name)
                group[dataset_name] = timer_string
            else
                @warn "Write failed, dataset " * group_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
            end
        end
    end
end
