using ExactOptimalTransport, HiGHS

function normalized_exp!(weight::AbstractVector)
    weight .-= maximum(weight)
    @. weight = exp(weight)
    weight ./= sum(weight)
end

# Solve an optimal transport problem to minimize the number of particles
# that need to be communicated between ranks during resampling.
function optimized_resample!(resampled_indices::AbstractVector{Int}, nrank::Int)
    nprt_per_rank = length(resampled_indices) ÷ nrank
    stock_queue = [Int[] for _ in 1:nrank]

    # Assign each resampled index to its corresponding rank
    for resampled_idx in resampled_indices
        rank = div(resampled_idx - 1, nprt_per_rank) + 1
        push!(stock_queue[rank], resampled_idx)
    end

    supply_vector = Float64[length(stock_queue[rank]) for rank in 1:nrank]
    demand_vector = Float64.(fill(nprt_per_rank, nrank))
    cost_matrix = ones(Float64, nrank, nrank)
    for i in 1:nrank
        cost_matrix[i, i] = 0
    end

    # Solve the optimal transport problem using the HiGHS solver
    y = emd(supply_vector, demand_vector, cost_matrix, HiGHS.Optimizer())

    # update resampled_indices
    for i in 1:nrank
        idx = 1
        for j in 1:nrank
            nmove = Int(y[j, i])
            for _ in 1:nmove
                resampled_indices[(i - 1) * nprt_per_rank + idx] = popfirst!(stock_queue[j])
                idx += 1
            end
        end
    end
    return resampled_indices
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
    to::TimerOutputs.TimerOutput = TimerOutputs.TimerOutput(),
    dedup::Bool = false
) where T

    if dedup
        return copy_states_dedup!(particles, buffer, resampling_indices, my_rank, nprt_per_rank, to)
    end

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
    @timeit_debug to "send loop" begin
        for (k,id) in enumerate(resampling_indices)
            rank_wants = floor(Int, (k - 1) / nprt_per_rank)
            if id in particles_have && rank_wants != my_rank
                local_id = id - my_rank * nprt_per_rank
                req = MPI.Isend(view(particles, :, local_id), rank_wants, id, MPI.COMM_WORLD)
                push!(reqs, req)
            end
        end
    end

    # Receive particles this rank wants from ranks that have them
    # If I already have them, just do a local copy
    # Receive into a buffer so we dont accidentally overwrite stuff
    @timeit_debug to "receive loop" begin
        for (k,proc,id) in zip(1:nprt_per_rank, rank_has, particles_want)
            if proc == my_rank
                @timeit_debug to "local copy" begin
                    local_id = id - my_rank * nprt_per_rank
                    buffer[:, k] .= view(particles, :, local_id)
                end
            else
                @timeit_debug to "remote receive" begin
                    req = MPI.Irecv!(view(buffer, :, k), proc, id, MPI.COMM_WORLD)
                    push!(reqs,req)
                end
            end
        end
    end

    # Wait for all comms to complete
    @timeit_debug to "waitall phase" MPI.Waitall(reqs)

    @timeit_debug to "buffer write-back" particles .= buffer

end

# An optimized version of copy_states that minimizes the number of messages sent
# by deduplicating particles that need to be sent between ranks.
function copy_states_dedup!(
    particles::AbstractMatrix{T},
    buffer::AbstractMatrix{T},
    resampling_indices::Vector{Int},
    my_rank::Int,
    nprt_per_rank::Int,
    to::TimerOutputs.TimerOutput = TimerOutputs.TimerOutput()
) where T

    # Same as copy_states
    particles_have = my_rank * nprt_per_rank + 1:(my_rank + 1) * nprt_per_rank
    particles_want = resampling_indices[particles_have]
    reqs = Vector{MPI.Request}(undef, 0)

    # Determine which particles need to be sent where
    @timeit_debug to "send plan" sends_to = _determine_sends(resampling_indices, my_rank, nprt_per_rank)
    # Categorize the particles this rank wants into local copies and remote copies
    @timeit_debug to "receive plan" local_copies, remote_copies = _categorize_wants(particles_want, my_rank, nprt_per_rank)

    # Send particles to processes that want them
    @timeit_debug to "send loop" begin
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
    @timeit_debug to "receive loop" begin
        for (id, buffer_indices) in remote_copies
            source_rank = floor(Int, (id - 1) / nprt_per_rank)
            first_k = buffer_indices[1] # Receive into the first required slot.
            req = MPI.Irecv!(view(buffer, :, first_k), source_rank, id, MPI.COMM_WORLD)
            push!(reqs, req)
        end
    end

    # Perform local copies
    @timeit_debug to "local replication" begin
        for (id, buffer_indices) in local_copies
            local_id = id - my_rank * nprt_per_rank
            source_view = view(particles, :, local_id)
            Threads.@threads for k in buffer_indices
                buffer[:, k] .= source_view
            end
        end
    end

    # Wait for all comms to complete
    @timeit_debug to "waitall phase" MPI.Waitall(reqs)

    # Perform remote copies for particles received from other ranks
    @timeit_debug to "remote replication" begin
        for (id, buffer_indices) in remote_copies
            if length(buffer_indices) > 1
                source_view = view(buffer, :, buffer_indices[1])
                # TODO: threading in chunks
                Threads.@threads for i in 2:length(buffer_indices)
                    k = buffer_indices[i]
                    buffer[:, k] .= source_view
                end
            end
        end
    end

    @timeit_debug to "buffer write-back" begin
        Threads.@threads for j in 1:size(particles, 2)
            # @views creates a non-allocating view of the column, which is faster inside a loop
            @views particles[:, j] .= buffer[:, j]
        end
    end
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


