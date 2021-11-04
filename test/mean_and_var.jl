using Test, ParticleDA, MPI, Statistics, Random

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

@testset for size in ((1,1,1), (1,1,1,1))

    stats = Array{ParticleDA.SummaryStat{Float64},length(size)}(undef, size)
    ParticleDA.get_mean_and_var!(stats,reshape(local_particles,size...,nprt_per_rank),0)
    @test_throws ErrorException ParticleDA.get_mean_and_var!(stats,reshape(local_particles,size[begin:end-1]...,nprt_per_rank),0)

    global_particles = MPI.Gather(local_particles, 0, MPI.COMM_WORLD)

    if my_rank == 0
        gather_mean = Statistics.mean(global_particles)
        gather_var = Statistics.var(global_particles, corrected=true)

        println("Mean     ",stats[1].avg, " -- ", stats[1].avg ≈ gather_mean)
        println("Variance ",stats[1].var, " -- ", stats[1].var ≈ gather_var)

        @test stats[1].avg ≈ gather_mean
        @test stats[1].var ≈ gather_var
    end

end
