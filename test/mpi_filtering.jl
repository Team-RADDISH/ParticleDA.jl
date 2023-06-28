using ParticleDA, MPI, Statistics, Test, YAML

include(joinpath(@__DIR__, "models", "llw2d.jl"))
using .LLW2d

# Initialise MPI
MPI.Init()

# Get the number or ranks, so that we can set a number of particle as an integer
# multiple of them.
my_size = MPI.Comm_size(MPI.COMM_WORLD)
n_particle_per_rank = 5
n_particle = n_particle_per_rank * my_size

my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
master_rank = 0

input_file_path = tempname()
output_file_path = tempname()
observation_file_path = tempname()

input_params = Dict(
    "filter" => Dict(
        "nprt" => n_particle,
        "verbose"=> false,
        "output_filename" => output_file_path,
        "seed" => 456,
    ),
    "model" => Dict(
        "llw2d" => Dict(
            "nx" => 21,
            "ny" => 21,
            "n_stations_x" => 2,
            "n_stations_y" => 2,
            "padding" => 0,
            "obs_noise_std" => [10.],
        ),
    ),
    "simulate_observations" => Dict(
        "n_time_step" => 100,
        "seed" => 123,
    )
)

if my_rank == master_rank
    YAML.write_file(input_file_path, input_params)
    simulate_observations_from_model(LLW2d.init, input_file_path, observation_file_path)
end

for filter_type in (ParticleDA.BootstrapFilter, ParticleDA.OptimalFilter),
        stat_type in (ParticleDA.NaiveMeanSummaryStat, ParticleDA.MeanAndVarSummaryStat)
    states, statistics = run_particle_filter(
        LLW2d.init, input_file_path, observation_file_path, filter_type, stat_type
    )
    @test !any(isnan.(states))
    # Gather final states from all MPI ranks to master
    flat_global_states = MPI.Gather(vec(states), master_rank, MPI.COMM_WORLD)
    if my_rank == master_rank
        global_states = reshape(flat_global_states, (size(states, 1), n_particle))
        reference_statistics = (
            avg=mean(global_states; dims=2),
            var=var(global_states, corrected=true; dims=2)
        )
        for name in ParticleDA.statistic_names(stat_type)
            @test size(statistics[name]) == size(states[:, 1])
            @test !any(isnan.(statistics[name]))
            @test all(
                (statistics[name] .≈ reference_statistics[name])
                .| isapprox.(reference_statistics[name], 0; atol=1e-15)
            )
        end
    else
        @test isnothing(statistics)
    end
end
