using Test, ParticleDA, MPI, Random

MPI.Init()
my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
my_size = MPI.Comm_size(MPI.COMM_WORLD)

nprt_per_rank = 3
n = nprt_per_rank * my_size

local_particles = float(collect(my_rank * nprt_per_rank + 1 : (my_rank + 1) * nprt_per_rank))

for i = 1:my_size
    if i == my_rank + 1
        println("rank ",my_rank,": particle states: ", local_particles)
    end
    MPI.Barrier(MPI.COMM_WORLD)
end

buffer = zeros(1,1,1,nprt_per_rank)

Random.seed!(1234)
indices = rand(1:n, n)

if my_rank == 0
    println()
    println("Resampling particles to indices ", indices)
    println()
end

ParticleDA.copy_states!(reshape(local_particles, (1,1,1,nprt_per_rank)), buffer, indices, my_rank, nprt_per_rank)

for i = 1:my_size
    if i == my_rank + 1
        test = local_particles ≈ float(indices[my_rank * nprt_per_rank + 1 : (my_rank + 1) * nprt_per_rank])
        println("rank ",my_rank,": particle states: ", local_particles, " -- ",test)
    end
    MPI.Barrier(MPI.COMM_WORLD)
end

@test local_particles ≈ float(indices[my_rank * nprt_per_rank + 1 : (my_rank + 1) * nprt_per_rank])
