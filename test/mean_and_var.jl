using Test, TDAC, MPI, Statistics, Random

MPI.Init()
my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
my_size = MPI.Comm_size(MPI.COMM_WORLD)

Random.seed!(1234 + my_rank)

nprt_per_rank = 5
n = nprt_per_rank * my_size

local_particles = rand(nprt_per_rank)

for i = 1:my_size
    if i == my_rank + 1
        println("rank ",my_rank,": particle states: ", local_particles)
    end
    MPI.Barrier(MPI.COMM_WORLD)
end

buffer = zeros(1,1,1)
avg = zeros(1,1,1)
var = zeros(1,1,1)

TDAC.get_parallel_mean_and_var!(avg,
                                var,
                                buffer,
                                reshape(local_particles, (1,1,1,nprt_per_rank)),
                                my_size,
                                nprt_per_rank,
                                0)

global_particles = MPI.Gather(local_particles, 0, MPI.COMM_WORLD)

if my_rank == 0
    gather_mean = Statistics.mean(global_particles)
    gather_var = Statistics.var(global_particles)

    println("Mean     ",avg[1], " -- ", avg[1] ≈ gather_mean)
    println("Variance ",var[1], " -- ", var[1] ≈ gather_var)

    @test avg[1] ≈ gather_mean
    @test var[1] ≈ gather_var
end
