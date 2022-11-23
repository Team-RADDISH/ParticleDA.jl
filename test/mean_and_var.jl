using Test, ParticleDA, MPI, Statistics, Random

MPI.Init()
my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
my_size = MPI.Comm_size(MPI.COMM_WORLD)

rng = Random.TaskLocalRNG()
Random.seed!(rng, 1234 + my_rank)

master_rank = 0
n_particle_per_rank = 5
n_particle = n_particle_per_rank * my_size
state_eltype = Float64
dimension = 2
verbose = "-v" in ARGS || "--verbose" in ARGS

local_states = rand(rng, state_eltype, (dimension, n_particle_per_rank))

if verbose
    for i = 1:my_size
        if i == my_rank + 1
            println("rank ", my_rank, " local states")
            for state in eachcol(local_states)
                println(state)
            end
        end
        MPI.Barrier(MPI.COMM_WORLD)
    end
end

flat_global_states = MPI.Gather(vec(local_states), master_rank, MPI.COMM_WORLD)
    
if my_rank == master_rank
    global_states = reshape(flat_global_states, (dimension, n_particle))
    if verbose
        println("global states")
        for state in eachcol(global_states)
            println(state)
        end
    end
    reference_statistics = (;
        avg=mean(global_states; dims=2), var=var(global_states, corrected=true; dims=2)
    )
end

for stats_type in (
    ParticleDA.NaiveMeanSummaryStat, 
    ParticleDA.NaiveMeanAndVarSummaryStat,
    ParticleDA.MeanSummaryStat,
    ParticleDA.MeanAndVarSummaryStat
)
    statistics = ParticleDA.init_statistics(stats_type, state_eltype, dimension)
    ParticleDA.update_statistics!(statistics, local_states, master_rank)
    if my_rank == master_rank
        unpacked_statistics = ParticleDA.init_unpacked_statistics(
            stats_type, state_eltype, dimension
        )
        ParticleDA.unpack_statistics!(unpacked_statistics, statistics)
        for name in ParticleDA.statistic_names(stats_type)
            verbose && println(
                name, 
                ", locally computed: ",
                unpacked_statistics[name], 
                ", globally computed: ", 
                reference_statistics[name]
            )
            @test all(unpacked_statistics[name] .≈ reference_statistics[name])
        end
    end

end
