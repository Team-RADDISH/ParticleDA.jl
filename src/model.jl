using .Default_params

struct RandomField{F<:GaussianRandomField,X<:AbstractArray,W<:AbstractArray,Z<:AbstractArray}
    grf::F
    xi::X
    w::W
    z::Z
end

struct StateVectors{T<:AbstractArray, S<:AbstractArray}

    particles::T
    buffer::T
    truth::S

end

struct ObsVectors{T<:AbstractArray,S<:AbstractArray}

    truth::T
    model::S

end

struct StationVectors{T<:AbstractArray}

    ist::T
    jst::T

end

struct ModelData
    states
    observations
    stations
    field_buffer
    background_grf
    model_matrices
    rng
end
get_particles(d::ModelData) = d.states.particles
# TODO: we should probably get rid of the next two functions and find other ways
# to pass them around.  `get_truth` is only used as return value of
# `particle_filter`, we may just return the whole `model_data`.
get_buffer(d::ModelData) = d.states.buffer
get_truth(d::ModelData) = d.states.truth
function write_initial_state(d::ModelData, weights, params)
    write_grid(params)
    write_params(params)
    write_stations(d.stations.ist, d.stations.jst, params)
    unpack_statistics!(d.avg_arr, d.var_arr, d.statistics)
    write_snapshot(d.states.truth, d.avg_arr, d.var_arr, weights, 0, params)
end

function init(params::Parameters, rng::AbstractVector{<:Random.AbstractRNG}, nprt_per_rank::Int)
    states, observations, stations, field_buffer = init_arrays(params, nprt_per_rank)

    background_grf = init_gaussian_random_field_generator(params)

    # Set up tsunami model
    model_matrices = LLW2d.setup(params.nx,
                                 params.ny,
                                 params.bathymetry_setup,
                                 params.absorber_thickness_fraction,
                                 params.boundary_damping,
                                 params.cutoff_depth)

    set_stations!(stations, params)

    set_initial_state!(states, model_matrices, field_buffer, rng, nprt_per_rank, params)

    return ModelData(states, observations, stations, field_buffer, background_grf, model_matrices, rng)
end

function update_truth!(d::ModelData, params)
    tsunami_update!(@view(d.field_buffer[:, :, 1, 1]),
                    @view(d.field_buffer[:, :, 2, 1]),
                    d.states.truth, d.model_matrices, params)

    # Get observation from true synthetic wavefield
    get_obs!(d.observations.truth, d.states.truth, d.stations.ist, d.stations.jst, params)
    return d.observations.truth
end

function update_particles!(d::ModelData, nprt_per_rank, params)
    Threads.@threads for ip in 1:nprt_per_rank
        tsunami_update!(@view(d.field_buffer[:, :, 1, threadid()]), @view(d.field_buffer[:, :, 2, threadid()]),
                        @view(d.states.particles[:, :, :, ip]), d.model_matrices, params)

    end
    add_random_field!(d.states.particles,
                      d.field_buffer,
                      d.background_grf,
                      d.rng,
                      params.n_state_var,
                      nprt_per_rank)

    # Add process noise, get observations, add observation noise (to particles)
    for ip in 1:nprt_per_rank
        get_obs!(@view(d.observations.model[:,ip]),
                 @view(d.states.particles[:, :, :, ip]),
                 d.stations.ist,
                 d.stations.jst,
                 params)
    add_noise!(@view(d.observations.model[:,ip]), d.rng[1], params)
    end
    return d.observations.model
end
