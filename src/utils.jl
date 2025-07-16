
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

function init_states(model, nprt_per_rank::Int, n_tasks::Int, rng::AbstractRNG)
    state_el_type = ParticleDA.get_state_eltype(model)
    state_dimension = ParticleDA.get_state_dimension(model)
    states = Matrix{state_el_type}(undef, state_dimension, nprt_per_rank)
    @sync for (task_index, particle_indices) in enumerate(index_chunks(1:nprt_per_rank; n=n_tasks))
        Threads.@spawn for particle_index in particle_indices
            sample_initial_state!(
                selectdim(states, 2, particle_index), model, rng, task_index
            )
        end
    end
    return states
end

function copy_states!(
    particles::AbstractMatrix{T},
    buffer::AbstractMatrix{T},
    resampling_indices::Vector{Int},
    my_rank::Int,
    nprt_per_rank::Int,
    to::TimerOutputs.TimerOutput = TimerOutputs.TimerOutput()
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

    @timeit_debug to "determine sends" sends_to = _determine_sends(resampling_indices, my_rank, nprt_per_rank)
    @timeit_debug to "categorize wants" local_copies, remote_copies = _categorize_wants(particles_want, my_rank, nprt_per_rank)

    # Send particles to processes that want them
    @timeit_debug to "isend loop" begin
        for (dest_rank, unique_ids) in sends_to
            for id in unique_ids
                local_id = id - my_rank * nprt_per_rank
                req = MPI.Isend(view(particles, :, local_id), dest_rank, id, MPI.COMM_WORLD)
                push!(reqs, req)
            end
        end
    end

    # Receive particles this rank wants from ranks that have them
    # If I already have them, just do a local copy
    # Receive into a buffer so we dont accidentally overwrite stuff
    @timeit_debug to "irecv loop" begin
        for (id, buffer_indices) in remote_copies
            source_rank = floor(Int, (id - 1) / nprt_per_rank)
            first_k = buffer_indices[1] # Receive into the first required slot.
            req = MPI.Irecv!(view(buffer, :, first_k), source_rank, id, MPI.COMM_WORLD)
            push!(reqs, req)
        end
    end

    @timeit_debug to "local copies" begin
        for (id, buffer_indices) in local_copies
            local_id = id - my_rank * nprt_per_rank
            source_view = view(particles, :, local_id)
            for k in buffer_indices
                buffer[:, k] .= source_view
            end
        end
    end

    # Wait for all comms to complete
    @timeit_debug to "waitall" MPI.Waitall(reqs)

    @timeit_debug to "remote duplicates copy" begin
        for (id, buffer_indices) in remote_copies
            if length(buffer_indices) > 1
                source_view = view(buffer, :, buffer_indices[1])
                for i in 2:length(buffer_indices)
                    k = buffer_indices[i]
                    buffer[:, k] .= source_view
                end
            end
        end
    end

    @timeit_debug to "write from buffer" particles .= buffer

end

function _determine_sends(resampling_indices::Vector{Int}, my_rank::Int, nprt_per_rank::Int)
    sends_to = Dict{Int, Set{Int}}()
    for (new_idx, old_id) in enumerate(resampling_indices)
        source_rank = floor(Int, (old_id - 1) / nprt_per_rank)

        if source_rank == my_rank
            dest_rank = floor(Int, (new_idx - 1) / nprt_per_rank)
            if dest_rank != my_rank
                unique_ids_for_dest = get!(() -> Set{Int}(), sends_to, dest_rank)
                push!(unique_ids_for_dest, old_id)
            end
        end
    end
    return sends_to
end

function _categorize_wants(particles_want, my_rank::Int, nprt_per_rank::Int)
    local_copies = Dict{Int, Vector{Int}}()
    remote_copies = Dict{Int, Vector{Int}}()

    for k in 1:nprt_per_rank
        id = particles_want[k]
        source_rank = floor(Int, (id - 1) / nprt_per_rank)

        if source_rank == my_rank
            get!(() -> Int[], local_copies, id) |> v -> push!(v, k)
        else
            get!(() -> Int[], remote_copies, id) |> v -> push!(v, k)
        end
    end
    return local_copies, remote_copies
end


