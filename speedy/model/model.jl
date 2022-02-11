module Model

using ParticleDA

using Random, Distributions, Base.Threads, GaussianRandomFields, HDF5
# using Default_params
using DelimitedFiles
using FieldMetadata
using FortranFiles
using Setfield
using Dates
using PlotlyJS
using MPI

# using .Default_params
include("speedy.jl")
using .SPEEDY

include("grf.jl")
using .Periodic_Cov
"""
    ModelParameters()

Parameters for the model. Keyword arguments:

* `IDate::String` : Start date for the simulations in the format: YYYYmmddHH
* `dtDate::String` : Incremental date in the format: YYYYmmddHH
* `Hinc::Int` : Hourly increment
* `obs_network::String` : Location of observations (real or uniform)
* `nobs::Int` : Number of observation stations
* `lambda::AbstractFloat` : Length scale for Matérn covariance kernel in background noise
* `nu::AbstractFloat` : Smoothess parameter for Matérn covariance kernel in background noise
* `sigma::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel in background noise
* `lambda_initial_state::AbstractFloat` : Length scale for Matérn covariance kernel in initial state of particles
* `nu_initial_state::AbstractFloat` : Smoothess parameter for Matérn covariance kernel in initial state of particles
* `sigma_initial_state::AbstractFloat` : Marginal standard deviation for Matérn covariance kernel in initial state of particles
* `padding::Int` : Min padding for circulant embedding gaussian random field generator
* `primes::Int`: Whether the size of the minimum circulant embedding of the covariance matrix can be written as a product of small primes (2, 3, 5 and 7). Default is `true`.
* `obs_noise_std::Float`: Standard deviation of noise added to observations of the true state
* `particle_dump_file::String`: file name for dump of particle state vectors
* `particle_dump_time::Int`: list of (one more more) time steps to dump particle states
* `SPEEDY::String` : Path to the SPEEDY directory
* `output_folder::String` : Output folder
* `station_filename::String` : Path to the station file which defines the observation locations
* `nature_dir::String`: Path to the directory with the ouputs of the nature run
* `nlon::Int`: Number of points in the longitude direction
* `nlat::Int`: Number of points in the latitude direction
* `lon_length::AbstractFloat`: Domain size in the lon direction
* `lat_length::AbstractFloat`: Domain size in the lat direction
* `dx::AbstractFloat` : Distance between grid points in the lon direction
* `dy::AbstractFloat` : Distance between grid points in the lat direction
* `nlev::Int`: Number of points in the vertical direction
* `n_state_var::Int`: Number of variables in the state vector
"""

Base.@kwdef struct ModelParameters{T<:AbstractFloat}
    # Initial date
    IDate::String=""
    # Incremental date
    dtDate::String=""
    # Hour interval
    Hinc::Int = 6
    # Ensemble initialisation
    ensDate::String=""
    # Choose observation network (choose "real" or "uniform")
    obs_network::String = "uniform"
    # Number of obs stations
    nobs::Int = 50

    lambda::Vector{T} = [1.0e0, 1.0e0, 1.0e0, 1.0e0, 1.0e0]
    nu::Vector{T} = [2.5, 2.5, 2.5, 2.5, 2.5]
    sigma::Vector{T} = [0.1, 0.1, 0.1, 0.00001, 1000.0]

    lambda_initial_state::Vector{T} = [1.0e0, 1.0e0, 1.0e0, 1.0e0, 1.0e0]
    nu_initial_state::Vector{T} = [2.5, 2.5, 2.5, 2.5, 2.5]
    sigma_initial_state::Vector{T} = [0.1, 0.1, 0.1, 0.0001, 1000.0]
    
    padding::Int = 100
    primes::Bool = true

    state_prefix::String = "data"
    title_avg::String = "avg"
    title_var::String = "var"
    title_syn::String = "syn"
    title_grid::String = "grid"
    title_stations::String = "stations"
    title_params::String = "params"
    particle_dump_file = "particle_dump.h5"
    particle_dump_time = [-1]
    obs_noise_std::T = 1000.0
    #Path to the the local speedy directory
    SPEEDY::String = ""
    station_filename::String = joinpath(SPEEDY, "obs", "networks", obs_network * ".txt")
    nature_dir::String = joinpath(SPEEDY, "DATA", "nature")
    # Output folders
    output_folder::String = joinpath(pwd(), "speedy")
    guess_folder::String = joinpath(output_folder, "DATA", "ensemble", "gues")
    anal_folder::String = joinpath(output_folder, "DATA", "ensemble", "anal")
    # Assimilated indices
    assimilate_indices::Vector{Int} = [1,5]
    # Grid dimensions
    nlon::Int = 96
    nlat::Int = 48
    nlev::Int = 8
    lon_length::T = 360.0
    lat_length::T = 180.0
    z_length::T = 1.0
    dx::T = lon_length / (nlon - 1)
    dy::T = lat_length / (nlat - 1)
    dz::T = z_length / (nlev - 1)

    nij0::Int = nlon*nlat
    n_state_var::Int = 6
    n_2d::Int = 2
    n_3d::Int = 4

end
function step_datetime(idate::String,dtdate::String)
    new_idate = Dates.format(DateTime(idate, "YYYYmmddHH") + Dates.Hour(6),"YYYYmmddHH")
    new_dtdate = Dates.format(DateTime(dtdate, "YYYYmmddHH") + Dates.Hour(6),"YYYYmmddHH")
    return new_idate,new_dtdate
end

function step_ens(ensdate::String, Hinc::Int)
    ens_end = Dates.format(DateTime(ensdate, "YYYYmmddHH") + Dates.Month(1),"YYYYmmddHH")
    diff = length(DateTime(ensdate, "YYYYmmddHH"):Hour(Hinc):DateTime(ens_end, "YYYYmmddHH"))
    rand_int = rand(0:diff-1)*Hinc
    new_idate = Dates.format(DateTime(ensdate, "YYYYmmddHH") + Dates.Hour(rand_int),"YYYYmmddHH")
    return new_idate
end


function ParticleDA.get_params(T::Type{ModelParameters}, user_input_dict::Dict)

    for key in ("lambda", "nu", "sigma", "lambda_initial_state", "nu_initial_state", "sigma_initial_state")
        if haskey(user_input_dict, key) && !isa(user_input_dict[key], Vector)
            user_input_dict[key] = fill(user_input_dict[key], 3)
        end
    end

    user_input = (; (Symbol(k) => v for (k,v) in user_input_dict)...)
    params = T(;user_input...)

end

function get_obs!(obs::AbstractVector{T},
                  state::AbstractArray{T},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int},
                  params::ModelParameters) where T

    get_obs!(obs,state,ist,jst)

end

# Return observation data at stations from given model state
function get_obs!(obs::AbstractVector{T},
                  state::AbstractArray{T},
                  ist::AbstractVector{Int},
                  jst::AbstractVector{Int}) where T
    @assert length(obs) == length(ist) == length(jst)

    for i in eachindex(obs)
        ii = ist[i]
        jj = jst[i]
        obs[i] = state[ii,jj]
    end
end

struct RandomField{F<:GaussianRandomField,X<:AbstractArray,W<:AbstractArray,Z<:AbstractArray}
    grf::F
    xi::X
    w::W
    z::Z
end

struct ObsVectors{T<:AbstractArray,S<:AbstractArray}

    truth::T
    model::S

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T

end

@metadata name ("","","","","","") NTuple{6, String}
@metadata unit ("","","","","","") NTuple{6, String}
@metadata description ("","","","","","") NTuple{6, String}

@name @description @unit struct StateVectors{T<:AbstractArray, S<:AbstractArray}

    particles::T | ("u","v","T","q","ps","rain") | ("velocity x-component","velocity y-component","Temperature", "Specific Humidity", "Pressure", "Rain") | ("m/s","m/s","K","kg/kg","Pa","mm/hr")
    truth::S | ("ps") | ("Pressure") | ("kPa")

end

function get_axes(params::ModelParameters)

    return get_axes(params.nlon, params.nlat, params.nlev)

end
function get_axes(ix::Int, iy::Int, iz::Int)
    x = LinRange(0, 2*π, ix)
    y = LinRange(0, π, iy)
    z = LinRange(0, 1, iz)

    return x,y,z
end

function init_gaussian_random_field_generator(params::ModelParameters)

    x, y, z = get_axes(params)
    return init_gaussian_random_field_generator(params.lambda,params.nu, params.sigma, x, y, params.padding, params.primes)

end

# Initialize a gaussian random field generating function using the Matern covariance kernel
# and circulant embedding generation method
# TODO: Could generalise this
function init_gaussian_random_field_generator(lambda::Vector{T},
                                              nu::Vector{T},
                                              sigma::Vector{T},
                                              xpts::AbstractVector{T},
                                              ypts::AbstractVector{T},
                                              pad::Int,
                                              primes::Bool) where T

    # Let's limit ourselves to two-dimensional fields
    dim = 2
    function _generate(l, n, s)
        cov = Periodic_Cov.CovarianceFunction(dim, Periodic_Cov.CustomDistanceCovarianceStructure(Periodic_Cov.SphericalDistance(), Matern(l, n, σ = s)))
        grf = GaussianRandomField(cov, Spectral(), xpts, ypts)
        v = grf.data.eigenval
        xi = Array{eltype(grf.cov)}(undef, size(v)..., nthreads())
        w = Array{complex(float(eltype(grf.cov)))}(undef, size(v)..., nthreads())
        z = Array{eltype(grf.cov)}(undef, length.(grf.pts)..., nthreads())
        RandomField(grf, xi, w, z)
    end

    return [_generate(l, n, s) for (l, n, s) in zip(lambda, nu, sigma)]
end
# Get a random sample from random_field_generator using random number generator rng
function sample_gaussian_random_field!(field::AbstractArray{T,2},
                                       random_field_generator::RandomField,
                                       rng::Random.AbstractRNG) where T

    field .= GaussianRandomFields.sample(random_field_generator.grf)
    # @. @view(random_field_generator.xi[:,:,threadid()]) = randn((rng,), T)
    # sample_gaussian_random_field!(field, random_field_generator, @view(random_field_generator.xi[:,:,threadid()]))

end

# # Get a random sample from random_field_generator using random_numbers
# function sample_gaussian_random_field!(field::AbstractArray{T,2},
#                                        random_field_generator::RandomField,
#                                        random_numbers::AbstractArray{T}) where T

#     field .= GaussianRandomFields._sample!(@view(random_field_generator.w[:,:,threadid()]),
#                                            @view(random_field_generator.z[:,:,threadid()]),
#                                            random_field_generator.grf,
#                                            random_numbers)

# end

# Add a gaussian random field to the height in the state vector of all particles
function add_random_field!(state::AbstractArray{T},
                           field_buffer::AbstractArray{T},
                           generators::Vector{<:RandomField},
                           rng::AbstractVector{<:Random.AbstractRNG},
                           n_3d::Int,
                           nlev::Int,                       
                           nprt::Int) where T

    Threads.@threads for ip in 1:nprt
        for ivar in 1:n_3d
            # Adding model noise to the 3D fields (U,V,T,q)
            for lev in 1:nlev
                sample_gaussian_random_field!(@view(field_buffer[:, :, lev, ivar, threadid()]), generators[ivar], rng[threadid()])
            end
        end
        state[:, :, :, 1:n_3d, ip] .+= @view(field_buffer[:, :, :, 1:n_3d, threadid()])
        # Adding model noise to the surface pressure field
        # sample_gaussian_random_field!(@view(field_buffer[:, :, 1, 5, threadid()]), generators[5], rng[threadid()])
        # state[:, :, 1, 5, ip] .+= @view(field_buffer[:, :, 1, 5, threadid()])
    end

end


function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, params::ModelParameters) where T

    add_noise!(vec, rng, 0.0, params.obs_noise_std)

end

# Add a (mean, std) normal distributed random number to each element of vec
function add_noise!(vec::AbstractVector{T}, rng::Random.AbstractRNG, mean::T, std::T) where T

    d = truncated(Normal(mean, std), 0.0, Inf)
    @. vec += rand((rng,), d)

end

function init_arrays(params::ModelParameters, nprt_per_rank)

    return init_arrays(params.nlon, params.nlat, params.nlev, params.n_state_var, params.nobs, nprt_per_rank)

end

function init_arrays(ix::Int, iy::Int, iz::Int, n_state_var::Int, nobs::Int, nprt_per_rank::Int)

    # TODO: ideally this will be an argument of the function, to choose a
    # different datatype.
    T = Float64

    state_avg = zeros(T, ix, iy, iz, n_state_var) # average of particle state vectors
    state_var = zeros(T, ix, iy, iz, n_state_var) # variance of particle state vectors

    state_particles = zeros(T, ix, iy, iz, n_state_var, nprt_per_rank)
    state_truth = zeros(T, ix, iy, 1) # model vector: true surface pressure (observation)
    obs_truth = Vector{T}(undef, nobs)          # observed
    obs_model = Matrix{T}(undef, nobs, nprt_per_rank) # forecasted

    # station location in digital grids
    ist = zeros(Int64,0)
    jst = zeros(Int64,0)

    # Buffer array to be used in the update
    field_buffer = Array{T}(undef, ix, iy, iz, 5, nthreads())
    return StateVectors(state_particles, state_truth), ObsVectors(obs_truth, obs_model), StationVectors(ist, jst), field_buffer
end


function set_initial_state!(states::StateVectors, model_matrices::SPEEDY.Matrices,
                            field_buffer::AbstractArray{T},
                            rng::AbstractVector{<:Random.AbstractRNG},
                            nprt_per_rank::Int,
                            params::ModelParameters) where T

    # Set true initial state
    # Read in the initial nature run - just surface pressure
    read_ps!(@view(states.truth[:,:,1]), joinpath(params.nature_dir, params.IDate * ".grd"), params.nlon, params.nlat, params.nlev)
    ### Read in arbitrary nature run files for the initial conditions
    Threads.@threads for ip in 1:nprt_per_rank
        dummy_date = step_ens(params.ensDate, params.Hinc)
        read_grd!(@view(states.particles[:,:,:,:,ip]), joinpath(params.nature_dir, dummy_date * ".grd"), params.nlon, params.nlat, params.nlev)
    end

    # Create generator for the initial random field
    # x,y,z = get_axes(params)
    # initial_grf = init_gaussian_random_field_generator(params.lambda_initial_state,
    #                                                    params.nu_initial_state,
    #                                                    params.sigma_initial_state,
    #                                                    x,
    #                                                    y,
    #                                                    params.padding,
    #                                                    params.primes)
    # Add samples of the initial random field to all particles
    # add_random_field!(states.particles, field_buffer, initial_grf, rng, (params.n_2d + params.n_3d), nprt_per_rank)


end

# Set station locations.
function set_stations!(stations::StationVectors, params::ModelParameters) where T
    set_stations!(stations.ist,
                  stations.jst,
                  params.station_filename)
end

function set_stations!(ist::AbstractVector, jst::AbstractVector, filename::String)
    open(filename,"r") do f
        readline(f)
        readline(f)
        ind = 0
        for line in eachline(f)
            if ind%10 == 0
                append!(ist, parse(Int64,split(line)[1]))
                append!(jst, parse(Int64,split(line)[2]))
            end
            ind = ind + 1
        end
    end
end

struct ModelData{A,B,C,D,E,F,G,H,I}
    model_params::A
    states::B
    observations::C
    stations::D
    field_buffer::E
    background_grf::F
    model_matrices::G
    rng::H
    dates::I
end
ParticleDA.get_particles(d::ModelData) = d.states.particles
# TODO: we should probably get rid of `get_truth`: it is only used as return
# value of `particle_filter`, we may just return the whole `model_data`.
ParticleDA.get_truth(d::ModelData) = d.states.truth
ParticleDA.get_stations(d::ModelData) = (nst = d.model_params.nobs,
                                         ist = d.stations.ist,
                                         jst = d.stations.jst)
ParticleDA.get_obs_noise_std(d::ModelData) = d.model_params.obs_noise_std
# Needs to be corrected
ParticleDA.get_model_noise_params(d::ModelData) = Matern(d.model_params.lambda[1],
                                                         d.model_params.nu[1],
                                                         σ=d.model_params.sigma[1])
ParticleDA.get_indices(d::ModelData) = d.model_params.assimilate_indices                                    

function ParticleDA.set_particles!(d::ModelData, particles::AbstractArray{T}) where T

    d.states.particles .= particles

end
ParticleDA.get_grid_size(d::ModelData) = d.model_params.nlon,d.model_params.nlat,d.model_params.nlev
ParticleDA.get_grid_domain_size(d::ModelData) = d.model_params.lon_length,d.model_params.lat_length,d.model_params.z_length
ParticleDA.get_grid_cell_size(d::ModelData) = d.model_params.dx,d.model_params.dy,d.model_params.dz
ParticleDA.get_n_state_var(d::ModelData) = d.model_params.n_state_var


function create_folders(output_folder::String, anal_folder::String, gues_folder::String, nprt_per_rank::Int, my_rank::Integer)
    MPI.Init()
    comm = MPI.COMM_WORLD
    ens = joinpath(output_folder, "DATA", "ensemble")
    tmp = joinpath(output_folder, "DATA", "tmp", "ensfcst")
    if MPI.Comm_rank(comm) == 0
        rm(ens; recursive=true)
        rm(tmp; recursive=true)
        mkdir(ens)
        mkdir(tmp)
        mkdir(anal_folder)
        mkdir(gues_folder)
    end
    MPI.Barrier(comm)

    rank_anal = joinpath(anal_folder,string(my_rank))
    rank_gues = joinpath(gues_folder,string(my_rank))
    rank_tmp = joinpath(tmp,string(my_rank))
    mkdir(rank_tmp)
    mkdir(rank_anal)
    mkdir(rank_gues)
    Threads.@threads for ip in 1:nprt_per_rank
        part_anal = joinpath(rank_anal, string(ip))
        part_gues = joinpath(rank_gues, string(ip))
        mkdir(part_anal)
        mkdir(part_gues)
    end
end

function init(model_params_dict::Dict, nprt_per_rank::Int, my_rank::Integer, rng::Vector{<:Random.AbstractRNG})
    model_params = ParticleDA.get_params(ModelParameters, get(model_params_dict, "speedy", Dict()))
    states, observations, stations, field_buffer = init_arrays(model_params, nprt_per_rank)
    background_grf = init_gaussian_random_field_generator(model_params)
    # Set up model
    model_matrices = SPEEDY.setup(model_params.nlon,model_params.nlat, model_params.nlev)
    model_dates = [model_params.IDate,model_params.dtDate]
    set_stations!(stations, model_params)

    set_initial_state!(states, model_matrices, field_buffer, rng, nprt_per_rank, model_params)

    create_folders(model_params.output_folder, model_params.anal_folder, model_params.guess_folder, nprt_per_rank, my_rank)

    return ModelData(model_params, states, observations, stations, field_buffer, background_grf, model_matrices, rng, model_dates)
end
function read_grd!(truth::AbstractArray{T}, filename::String,nlon::Int, nlat::Int, nlev::Int) where T

    nij0 = nlon*nlat
    iolen = 4
    nv3d = 4
    nv2d = 2

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

function read_ps!(truth::AbstractMatrix{T}, filename::String, nlon::Int, nlat::Int, nlev::Int) where T

    nij0 = nlon*nlat
    iolen = 4
    nv3d = 4
    nv2d = 2

    v3d = Array{Float32, 4}(undef, nlon, nlat, nlev, nv3d)
    v2d = Array{Float32, 3}(undef, nlon, nlat, nv2d)

    f = FortranFile(filename, access="direct", recl=nij0*iolen)

    irec = 1

    for n = 1:nv3d
        for k = 1:nlev
            v3d[:,:,k,n] = read(f, (Float32, nlon, nlat), rec=irec)
            irec += 1
        end
    end

    for n = 1:nv2d
        v2d[:,:,n] = read(f, (Float32, nlon, nlat), rec = irec)
        irec += 1
    end
    truth .= v2d[:,:,1]
    close(f)

end

function write_fortran(filename::String,nlon::Int, nlat::Int, nlev::Int,dataset::AbstractArray{T}) where T

    nij0 = nlon*nlat
    iolen = 4
    nv3d = 4
    nv2d = 2
    iolen = 4
    v3d = Array{Float32, 4}(undef, nlon, nlat, nlev, nv3d)
    v2d = Array{Float32, 3}(undef, nlon, nlat, nv2d)
    v3d .= dataset[:,:,:,1:4]
    v2d .= dataset[:,:,1,5:6]

    f = FortranFile(filename, "w", access="direct", recl=(nij0*iolen))
    irec = 1
    for n = 1:nv3d
        for k = 1:nlev
            write(f,v3d[:,:,k,n],rec=irec)
            irec=irec+1
        end
    end
    for n = 1:nv2d
        write(f,v2d[:,:,n],rec=irec)
        irec=irec+1
    end
    close(f)
end

function ParticleDA.update_truth!(d::ModelData, _)
    # Read in Nature run
    read_ps!(@view(d.states.truth[:,:,1]), joinpath(d.model_params.nature_dir, d.dates[1] * ".grd"), d.model_params.nlon, d.model_params.nlat, d.model_params.nlev)
    # Get observation from nature run
    get_obs!(d.observations.truth, d.states.truth[:,:,1], d.stations.ist, d.stations.jst, d.model_params)
    add_noise!(d.observations.truth, d.rng[1], d.model_params)
    return d.observations.truth
end

function speedy_update!(SPEEDY::String,
                        output::String,
                        YMDH::String,
                        TYMDH::String,
                        rank::String,
                        particle::String)
    # Path to the bash script which carries out the forecast
    forecast = joinpath(pwd(), "speedy", "model", "dafcst.sh")
    # Bash script call to speedy
    run(`$forecast $SPEEDY $output $YMDH $TYMDH $rank $particle`)
end

function ParticleDA.update_particle_dynamics!(d::ModelData, nprt_per_rank)
    my_rank = MPI.Comm_rank(MPI.COMM_WORLD)

    Threads.@threads for ip in 1:nprt_per_rank
        #Write to file
        anal_file = joinpath(d.model_params.anal_folder, string(my_rank), string(ip), d.dates[1] * ".grd")
        write_fortran(anal_file,d.model_params.nlon, d.model_params.nlat, d.model_params.nlev,d.states.particles[:, :, :, :, ip])
        # Update the dynamics
        speedy_update!(d.model_params.SPEEDY,d.model_params.output_folder,d.dates[1],d.dates[2],string(my_rank),string(ip))
        # Read back in the data and update the states
        guess_file = joinpath(d.model_params.guess_folder, string(my_rank), string(ip), d.dates[2] * ".grd")
        read_grd!(@view(d.states.particles[:, :, :, :, ip]), guess_file, d.model_params.nlon, d.model_params.nlat, d.model_params.nlev)
        # Check by plotting output
    end
    @show maximum(abs.(d.states.particles[:, :, 1, 5, 1]-d.states.particles[:, :, 1, 5, 3]))
    ## Update the time strings
    d.dates[1],d.dates[2] = step_datetime(d.dates[1],d.dates[2])
    @show d.dates[1], d.dates[2]
end

function ParticleDA.update_particle_noise!(d::ModelData, nprt_per_rank)
    # Add process noise
    add_random_field!(d.states.particles,
                      d.field_buffer,
                      d.background_grf,
                      d.rng,
                      d.model_params.n_3d,
                      d.model_params.nlev,
                      nprt_per_rank)
end

function ParticleDA.get_particle_observations!(d::ModelData, nprt_per_rank)
    # get observations
    for ip in 1:nprt_per_rank
        get_obs!(@view(d.observations.model[:,ip]),
                 @view(d.states.particles[:, :, 1, 5, ip]),
                 d.stations.ist,
                 d.stations.jst,
                 d.model_params)
    end
    return d.observations.model
end


### Model IO

function write_params(output_filename, params)

    file = h5open(output_filename, "cw")

    if !haskey(file, params.title_params)

        group = create_group(file, params.title_params)

        fields = fieldnames(typeof(params));

        for field in fields

            attributes(group)[string(field)] = getfield(params, field)

        end

    else

        @warn "Write failed, group " * params.title_params * " already exists in " * file.filename * "!"

    end

    close(file)

end

function write_grid(output_filename, params)

    h5open(output_filename, "cw") do file

        if !haskey(file, params.title_grid)

            # Write grid axes
            group = create_group(file, params.title_grid)
            x,y,z = get_axes(params)
            #TODO: use d_write instead of create_dataset when they fix it in the HDF5 package
            ds_x,dtype_x = create_dataset(group, "x", collect(x))
            ds_y,dtype_x = create_dataset(group, "y", collect(y))
            ds_z,dtype_x = create_dataset(group, "z", collect(z))
            ds_x[1:params.nlon] = collect(x)
            ds_y[1:params.nlat] = collect(y)
            ds_z[1:params.nlev] = collect(z)
            attributes(ds_x)["Unit"] = "°"
            attributes(ds_y)["Unit"] = "°"
            attributes(ds_z)["Unit"] = "°"

        else

            @warn "Write failed, group " * params.title_grid * " already exists in " * file.filename * "!"

        end

    end

end

function write_stations(output_filename, ist::AbstractVector, jst::AbstractVector, params::ModelParameters) where T
    x,y,z = get_axes(params)
    h5open(output_filename, "cw") do file

        if !haskey(file, params.title_stations)
            group = create_group(file, params.title_stations)

            for (dataset_name, val) in zip(("x", "y"), (x[ist], y[jst]))
                ds, dtype = create_dataset(group, dataset_name, val)
                ds[:] = val
                attributes(ds)["Description"] = "Station "*dataset_name*" coordinate"
                attributes(ds)["Unit"] = "°"
            end
        else
            @warn "Write failed, group " * params.title_stations * " already exists in " * file.filename * "!"
        end
    end
end

function write_weights(file::HDF5.File, weights::AbstractVector, unit::String, it::Int, d::ModelData)

    group_name = "weights"
    dataset_name = "t" * lpad(string(it),4,'0')

    group, subgroup = ParticleDA.create_or_open_group(file, group_name)

    if !haskey(group, dataset_name)
        #TODO: use d_write instead of create_dataset when they fix it in the HDF5 package
        ds,dtype = create_dataset(group, dataset_name, weights)
        ds[:] = weights
        attributes(ds)["Description"] = "Particle Weights"
        attributes(ds)["Unit"] = unit
        attributes(ds)["Time step"] = it
        attributes(ds)["Date"] = d.dates[1]
    else
        @warn "Write failed, dataset " * group_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end

end

function ParticleDA.write_snapshot(output_filename::AbstractString,
                                   d::ModelData,
                                   avg::AbstractArray{T,4},
                                   var::AbstractArray{T,4},
                                   weights::AbstractVector{T},
                                   it::Int) where T

    if it == 0
        # These are written only at the initial state it == 0
        write_grid(output_filename, d.model_params)
        write_params(output_filename, d.model_params)
        write_stations(output_filename, d.stations.ist, d.stations.jst, d.model_params)

    end

    if any(d.model_params.particle_dump_time .== it)
        write_particles(d.model_params.particle_dump_file, d.states, it, d)
    end

    return ParticleDA.write_snapshot(output_filename, d.states, avg, var, weights, it, d)
end

function ParticleDA.write_snapshot(output_filename::AbstractString,
                                   states::StateVectors,
                                   avg::AbstractArray{T,4},
                                   var::AbstractArray{T,4},
                                   weights::AbstractVector{T},
                                   it::Int,
                                   d::ModelData) where T

    println("Writing output at timestep = ", it)

    h5open(output_filename, "cw") do file
        for (i,(name,desc,unit)) in enumerate(zip(name(states, :particles), description(states, :particles), unit(states, :particles)))
            write_field(file, @view(states.truth[:,:,1]), it, unit, d.model_params.title_syn, name, desc, d)
            write_field(file, @view(avg[:,:,:,i]), it, unit, d.model_params.title_avg, name, desc, d)
            write_field(file, @view(var[:,:,:,i]), it, "("*unit*")^2", d.model_params.title_var, name, desc, d)

        end

        write_weights(file, weights, "", it, d)
    end

end

function write_particles(output_filename::AbstractString,
                         states::StateVectors,
                         it::Int,
                         d::ModelData) where T

    println("Writing particle states at timestep = ", it)
    nprt = size(states.particles,4)

    h5open(output_filename, "cw") do file

        for iprt = 1:nprt
            group_name = "particle" * string(iprt)

            for (i,(name,desc,unit)) in enumerate(zip(name(states, :particles), description(states, :particles), unit(states, :particles)))

                write_field(file, @view(states.particles[:,:,i,iprt]), it, unit, group_name, name, desc, d)

            end

        end

    end

end

function write_field(file::HDF5.File,
                     field::AbstractArray{T},
                     it::Int,
                     unit::String,
                     group::String,
                     dataset::String,
                     description::String,
                     d::ModelData) where T

    group_name = d.model_params.state_prefix * "_" * group
    subgroup_name = "t" * lpad(string(it),4,'0')
    dataset_name = dataset

    group, subgroup = ParticleDA.create_or_open_group(file, group_name, subgroup_name)

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
        attributes(ds)["Date"] = d.dates[1]
    else
        @warn "Write failed, dataset " * group_name * "/" * subgroup_name * "/" * dataset_name *  " already exists in " * file.filename * "!"
    end
end

end # module
