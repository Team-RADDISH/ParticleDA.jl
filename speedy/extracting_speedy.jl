using FortranFiles
using Dates, HDF5


function read_grd!(filename::String,nlon::Int, nlat::Int, nlev::Int,truth::AbstractArray{T}) where T

    nij0 = nlon*nlat
    iolen = 4
    nv3d = 4
    nv2d = 2

    # v3d = Array{Float32, 4}(undef, nlon, nlat, nlev, nv3d)
    # v2d = Array{Float32, 3}(undef, nlon, nlat, nv2d)

    f = FortranFile(filename, access="direct", recl=nij0*iolen)

    irec = 1

    for n = 1:nv3d
        for k = 1:nlev
            truth[:,:,k,n] .= read(f, (Float32, nlon, nlat), rec=irec)
            irec += 1
        end
    end

    for n = 1:nv2d
        truth[:,:,1,(n+nv3d)] .= read(f, (Float32, nlon, nlat), rec = irec)
        irec += 1
    end

    close(f)

end

function write_snapshot(output_filename::AbstractString,
                        truth::AbstractArray{T},
                        it::Int) where T
    
    println("Writing output at timestep = ", it)
    name = ("u","v","T","q","ps","rain")
    description = ("velocity x-component","velocity y-component","Temperature", "Specific Humidity", "Pressure", "Rain")
    unit = ("m/s","m/s","K","kg/kg","Pa","mm/hr")

    h5open(output_filename, "cw") do file
        for i in 1:length(name)
            write_field(file, @view(truth[:,:,:,i]), it, unit[i], "nature", name[i], description[i])
        end
    end

end

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

function write_field(file::HDF5.File,
                     field::AbstractArray{T},
                     it::Int,
                     unit::String,
                     group::String,
                     dataset::String,
                     description::String) where T

    group_name = "data" * "_" * group
    subgroup_name = "t" * string(it)
    dataset_name = dataset

    group, subgroup = create_or_open_group(file, group_name, subgroup_name)

    if !haskey(subgroup, dataset_name)
        #TODO: use d_write instead of create_dataset when they fix it in the HDF5 package
        ds,dtype = create_dataset(subgroup, dataset_name, field)
        if ndims(field) < 3
            ds[:,:] = field
        else
            ds[:,:,:] = field
        end
        attributes(ds)["Description"] = description
        attributes(ds)["Unit"] = unit
        attributes(ds)["Time step"] = it
        # attributes(ds)["Date"] = d.dates[1]
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end
end

SPEEDY= "/Users/dangiles/Documents/UCL/Raddish/speedy"
nature_dir = string(SPEEDY,"/DATA/nature/")
T = Float64
nlon = 96
nlat= 48
nlev= 8
n_state_var= 6
truth = zeros(T, nlon, nlat, nlev, n_state_var);
output_filename = "DATA/nature_runs.h5"

iteration = 0
for file in readdir(nature_dir)
    if iteration < 242
        if occursin(".grd", file)
            @show joinpath(nature_dir,file)
            read_grd!(joinpath(nature_dir,file), nlon, nlat, nlev, @view(truth[:,:,:,:]))
            write_snapshot(output_filename, truth, iteration)
            # @show truth[:,:,1,5]
            iteration = iteration + 1
        end
    end 
end