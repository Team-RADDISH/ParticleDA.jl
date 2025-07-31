using Pkg, Random, Test

using ParticleDA

const rng = Random.TaskLocalRNG()
Random.seed!(rng, 1234)

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

nrank = 5
n_particle = 10

println("Particle had: ", collect(1:n_particle))

resampled_indices = sort!(sample_indices(n_particle, k=5, p=0.99))
println("Resampled Indices: ", resampled_indices)

resampled_indices = ParticleDA.optimized_resample!(resampled_indices, nrank)
println("Optimized Resampled Indices: ", resampled_indices)