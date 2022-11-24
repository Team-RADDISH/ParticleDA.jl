function create_or_open_group(
    file::HDF5.File, group_name::String, subgroup_name::Union{Nothing, String}=nothing
)
    if !haskey(file, group_name)
        group = create_group(file, group_name)
    else
        group = open_group(file, group_name)
    end
    if !isnothing(subgroup_name)
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

function write_array(
    group::HDF5.Group,
    dataset_name::String,
    array::AbstractArray,
    dataset_attributes::Union{Dict{String, Any}, Nothing}=nothing
)
    if !haskey(group, dataset_name)
        group[dataset_name] = array
        if !isnothing(dataset_attributes)
            for (key, value) in pairs(dataset_attributes)
                attributes(group[dataset_name])[key] = value
            end
        end
    else
        @warn "Write failed, dataset $dataset_name already exists in $group"
    end
end

function write_timers(
    lengths::Vector{Int},
    size::Int, 
    chars::AbstractVector{UInt8}, 
    params::FilterParameters
)
    write_timers(lengths, size, chars, params.output_filename)
end

function write_timers(
    lengths::Vector{Int}, size::Int, chars::AbstractVector{UInt8}, filename::String
)
    group_name = "timer"
    h5open(filename, "cw") do file
        group, _ = create_or_open_group(file, group_name)
        sum_lengths = cumsum(lengths)
        for i in 1:size
            timer_string = String(
                chars[1 + (i > 1 ? sum_lengths[i - 1] : 0):sum_lengths[i]]
            )
            dataset_name = "rank" * string(i-1)
            if !haskey(group, dataset_name)
                group[dataset_name] = timer_string
            else
                @warn "Write failed, dataset $dataset_name already exists in $group"
            end
        end
    end
end

function read_input_file(path_to_input_file::String)
    # Read input provided in a yaml file. Overwrite default input parameters with the values provided.
    if isfile(path_to_input_file)
        user_input_dict = YAML.load_file(path_to_input_file)
    else
        @warn "Input file " * path_to_input_file * " not found, using default parameters"
        user_input_dict = Dict()
    end
    return user_input_dict
end

function read_observation_sequence(observation_file::HDF5.File)
    observation_group = observation_file["observations"]
    time_keys = sort(keys(observation_group), by=hdf5_key_to_time_index)
    @assert Set(map(hdf5_key_to_time_index, time_keys)) == Set(
        hdf5_key_to_time_index(time_keys[1]):hdf5_key_to_time_index(time_keys[end])
    ) "Observations in $observation_file_path are at non-contiguous time indices"
    observation = observation_group[time_keys[1]]
    observation_dimension = length(observation)
    observation_sequence = Matrix{eltype(observation)}(
        undef, observation_dimension, length(time_keys)
    )
    for (time_index, key) in enumerate(time_keys)
        observation_sequence[:, time_index] .= read(observation_group[key])
    end
    return observation_sequence
end 
