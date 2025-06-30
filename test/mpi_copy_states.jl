using Test, ParticleDA, MPI, Random, TimerOutputs, HDF5, Serialization
TimerOutputs.enable_debug_timings(ParticleDA)

const rng = Random.TaskLocalRNG()
Random.seed!(rng, 1234)

build_expected_buffer(indices, r, npr, nf) =
    Float64.((1:nf) .+ ((indices[r*npr .+ (1:npr)] .- 1) .* nf)')
function sample_indices(n::Int; k::Int=10, p::Float64=0.99)
    @assert 1 ≤ k < n       "k must be between 1 and n-1"
    @assert 0.0 ≤ p ≤ 1.0   "p must be in [0,1]"

    # 1. Pick k unique “favorite” indices via a random permutation
    fav = randperm(rng, n)[1:k]

    # 2. Build the complement
    other = setdiff(1:n, fav)

    # 3. Decide for each of the n draws whether it comes from fav (true) or other (false)
    mask = rand(rng, n) .< p     # Bool vector of length n

    # 4. Preallocate result
    result = Vector{Int}(undef, n)

    # 5. How many draws from each group?
    na = count(mask)
    nb = n - na

    # 6. Sample with replacement from each group
    result[mask]   .= rand(rng, fav, na)
    result[.!mask] .= rand(rng, other, nb)

    return result
end

MPI.Init()
my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
my_size = MPI.Comm_size(MPI.COMM_WORLD)

n_particle_per_rank = 1000
n_particle = n_particle_per_rank * my_size
verbose = "-v" in ARGS || "--verbose" in ARGS
output_timer = "-t" in ARGS || "--output-timer" in ARGS
if output_timer
    if length(ARGS) < 2
        error("Please provide the output filename for timers.")
    end
    output_filename = ARGS[2]
    println("Outputting timers to HDF5 file '$output_filename'")
end

# TODO: change each particle to be a vector of states(2D), >= thousands of floats to reach the network bandwidth
n_float_per_particle = 100000
# total number of floats per rank
N = n_float_per_particle * n_particle_per_rank
# build & reshape in one go, then allocate a similar array
init_local_states = reshape((my_rank*N .+ (1:N)) .* 1.0,
                            n_float_per_particle,
                            n_particle_per_rank)
local_states = similar(init_local_states)

if verbose
    for i = 1:my_size
        if i == my_rank + 1
            println("rank ", my_rank, ": local states: ", local_states)
        end
        MPI.Barrier(MPI.COMM_WORLD)
    end
end

buffer = zeros((n_float_per_particle, n_particle_per_rank))


trial_sets = Dict(
    "1:$my_size:$n_particle_per_rank:$n_float_per_particle:randperm" => sample_indices(n_particle, k=1, p=0.99),
    "10:$my_size:$n_particle_per_rank:$n_float_per_particle:randperm" => sample_indices(n_particle, k=10, p=0.99),
    "100:$my_size:$n_particle_per_rank:$n_float_per_particle:randperm" => sample_indices(n_particle, k=100, p=0.99),
    "half:$my_size:$n_particle_per_rank:$n_float_per_particle:randperm" => sample_indices(n_particle, k=div(n_particle, 2), p=0.99),
    "all:$my_size:$n_particle_per_rank:$n_float_per_particle:randperm" => randperm(n_particle),
    "1:$my_size:$n_particle_per_rank:$n_float_per_particle:firstperm" => ones(Int, n_particle),
    "10:$my_size:$n_particle_per_rank:$n_float_per_particle:firstperm" => rand(rng, 1:10, n_particle),
    "100:$my_size:$n_particle_per_rank:$n_float_per_particle:firstperm" => rand(rng, 1:100, n_particle),
    "half:$my_size:$n_particle_per_rank:$n_float_per_particle:firstperm" => rand(rng, 1:div(n_particle, 2), n_particle),
    "all:$my_size:$n_particle_per_rank:$n_float_per_particle:firstperm" => randperm(n_particle),
)

local_timer_dicts = Dict{String, Dict{String,Any}}()

for (trial_name, indices) in trial_sets
    if verbose && my_rank == 0
        println()
        println("Resampling particles to indices ", indices)
        println()
    end

    # Convert Set to Vector for indexing
    indices = collect(indices)
    # Ensure indices are within bounds
    @test all(indices .<= n_particle)
    @test all(indices .> 0)

    # repeat experiment 10 times to get average time
    timer = TimerOutputs.TimerOutput("copy_states")
    for _ in 1:10
        copyto!(local_states, init_local_states)
        ParticleDA.copy_states!(
            local_states,
            buffer, 
            indices, 
            my_rank, 
            n_particle_per_rank,
            timer
        )
    end
    local_timer_dicts[trial_name] = TimerOutputs.todict(timer)

    if verbose
        for i = 1:my_size
            if i == my_rank + 1
                # reconstruct expected buffer for this rank
                expected = build_expected_buffer(indices, my_rank,
                                    n_particle_per_rank,
                                    n_float_per_particle)

                # compare
                match = local_states == expected

                println("rank ", my_rank, ": local_states =")
                show(stdout, "text/plain", local_states); println()
                println("rank ", my_rank, ": expected =")
                show(stdout, "text/plain", expected); println()
                println("rank ", my_rank, ": match = ", match)
            end
            MPI.Barrier(MPI.COMM_WORLD)
        end
    end
    
    # build the expected buffer
    expected = build_expected_buffer(indices, my_rank,
                                    n_particle_per_rank,
                                    n_float_per_particle)

    @test local_states == expected
end

if output_timer
    all_local = MPI.gather(local_timer_dicts, MPI.COMM_WORLD; root=0)
    if my_rank == 0
        merged = Dict{String,Dict{Int,Dict{String,Any}}}()
        for r in 0:my_size-1
            for (trial, tdict) in all_local[r+1]
                rankmap = get!(merged, trial, Dict{Int,Dict{String,Any}}())
                rankmap[r] = tdict
            end
        end
    
        buf   = IOBuffer()
        serialize(buf, merged)
        blob  = take!(buf)  # Vector{UInt8}
    
        h5open(output_filename, "w") do f
            write(f, "all_timers", blob)
        end
    end
end


MPI.Barrier(MPI.COMM_WORLD)
MPI.Finalize()
