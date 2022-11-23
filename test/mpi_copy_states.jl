using Test, ParticleDA, MPI, Random

MPI.Init()
my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
my_size = MPI.Comm_size(MPI.COMM_WORLD)

n_particle_per_rank = 3
n_particle = n_particle_per_rank * my_size
verbose = "-v" in ARGS || "--verbose" in ARGS

for size in (1, (1, 1))

    local_states = float(
        collect(
            my_rank * n_particle_per_rank + 1 : (my_rank + 1) * n_particle_per_rank
        )
    )

    if verbose
        for i = 1:my_size
            if i == my_rank + 1
                println("rank ", my_rank, ": local states: ", local_states)
            end
            MPI.Barrier(MPI.COMM_WORLD)
        end
    end

    buffer = zeros((size..., n_particle_per_rank))

    Random.seed!(1234)
    indices = rand(1:n_particle, n_particle)

    if verbose && my_rank == 0
        println()
        println("Resampling particles to indices ", indices)
        println()
    end

    ParticleDA.copy_states!(
        reshape(local_states, (size..., n_particle_per_rank)), 
        buffer, 
        indices, 
        my_rank, 
        n_particle_per_rank
    )

    if verbose
        for i = 1:my_size
            if i == my_rank + 1
                test = (
                    local_states 
                    == float(
                        indices[
                            my_rank * n_particle_per_rank + 1 : (my_rank + 1) * n_particle_per_rank
                        ]
                    )
                )
                println("rank ", my_rank, ": local states: ",  local_states, " -- ", test)
            end
            MPI.Barrier(MPI.COMM_WORLD)
        end
    end

    @test local_states == float(
        indices[my_rank * n_particle_per_rank + 1 : (my_rank + 1) * n_particle_per_rank]
    )

end
