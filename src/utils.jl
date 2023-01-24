
function normalized_exp!(weight::AbstractVector)
    weight .-= maximum(weight)
    @. weight = exp(weight)
    weight ./= sum(weight)
end

# Resample particles from given weights using Stochastic Universal Sampling
function resample!(
    resampled_indices::AbstractVector{Int}, 
    weights::AbstractVector{T}, 
    rng::Random.AbstractRNG=Random.TaskLocalRNG()
) where T

    nprt = length(weights)
    nprt_inv = 1.0 / nprt
    k = 1

    weight_cdf = cumsum(weights)
    u0 = nprt_inv * rand(rng, T)

    # Note: To parallelise this loop, updates to k and u have to be atomic.
    # TODO: search for better parallel implementations
    for ip in 1:nprt
        u = u0 + (ip - 1) * nprt_inv
        while(u > weight_cdf[k])
            k += 1
        end
        resampled_indices[ip] = k
    end
end

function init_states(model, nprt_per_rank::Int, rng::AbstractRNG)
    state_el_type = ParticleDA.get_state_eltype(model)
    state_dimension = ParticleDA.get_state_dimension(model)
    states = Matrix{state_el_type}(undef, state_dimension, nprt_per_rank)
    Threads.@threads :static for p in 1:nprt_per_rank
        sample_initial_state!(selectdim(states, 2, p), model, rng)
    end
    return states
end

function copy_states!(
    particles::AbstractMatrix{T},
    buffer::AbstractMatrix{T},
    resampling_indices::Vector{Int},
    my_rank::Int,
    nprt_per_rank::Int
) where T

    # These are the particle indices stored on this rank
    particles_have = my_rank * nprt_per_rank + 1:(my_rank + 1) * nprt_per_rank

    # These are the particle indices this rank should have after resampling
    particles_want = resampling_indices[particles_have]

    # These are the ranks that have the particles this rank should have
    rank_has = floor.(Int, (particles_want .- 1) / nprt_per_rank)

    # We could work out how many sends and receives we have to do and allocate
    # this appropriately but, lazy
    reqs = Vector{MPI.Request}(undef, 0)

    # Send particles to processes that want them
    for (k,id) in enumerate(resampling_indices)
        rank_wants = floor(Int, (k - 1) / nprt_per_rank)
        if id in particles_have && rank_wants != my_rank
            local_id = id - my_rank * nprt_per_rank
            req = MPI.Isend(view(particles, :, local_id), rank_wants, id, MPI.COMM_WORLD)
            push!(reqs, req)
        end
    end

    # Receive particles this rank wants from ranks that have them
    # If I already have them, just do a local copy
    # Receive into a buffer so we dont accidentally overwrite stuff
    for (k,proc,id) in zip(1:nprt_per_rank, rank_has, particles_want)
        if proc == my_rank
            local_id = id - my_rank * nprt_per_rank
            buffer[:, k] .= view(particles, :, local_id)
        else
            req = MPI.Irecv!(view(buffer, :, k), proc, id, MPI.COMM_WORLD)
            push!(reqs,req)
        end
    end

    # Wait for all comms to complete
    MPI.Waitall!(reqs)

    particles .= buffer

end
