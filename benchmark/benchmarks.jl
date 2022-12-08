using BenchmarkTools
using ParticleDA
using MPI
using Random
using Base.Threads
using HDF5

include(joinpath(joinpath(@__DIR__, "..", "test"), "models", "llw2d.jl"))
using .LLW2d

if !MPI.Initialized()
    MPI.Init()
end

const SUITE = BenchmarkGroup()
const my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
const my_size = MPI.Comm_size(MPI.COMM_WORLD)

const params = Dict(
    "filter" => Dict(
        "nprt" => 32,
        "enable_timers" => true,
        "verbose" => true,
    ),
    "model" => Dict(
        "llw2d" => Dict(
            "nx" => 200,
            "ny" => 200,
            "n_stations_x" => 8,
            "n_stations_y" => 8,
            "padding" => 0,
        ),
    ),
)

const n_time_step = 20
const nprt_per_rank = Int(params["filter"]["nprt"] / my_size)
const rng = Random.TaskLocalRNG()
Random.seed!(rng, 1234)
const model = LLW2d.init(params["model"])
const filter_params = ParticleDA.get_params(ParticleDA.FilterParameters, params["filter"])
const state = Vector{ParticleDA.get_state_eltype(model)}(
    undef, ParticleDA.get_state_dimension(model)
)
const observation = Vector{ParticleDA.get_observation_eltype(model)}(
    undef, ParticleDA.get_observation_dimension(model)
)
const observation_sequence = ParticleDA.simulate_observations_from_model(
    model, n_time_step
)


SUITE["Model interface"] = BenchmarkGroup()

SUITE["Model interface"]["sample_initial_state!"] = @benchmarkable ParticleDA.sample_initial_state!(
    local_state, $(model), local_rng
) setup=(
    local_state = copy($(state)); 
    local_rng = copy($(rng));
)
SUITE["Model interface"]["update_state_deterministic!"] = @benchmarkable ParticleDA.update_state_deterministic!(
    local_state, $(model), 0
) setup=(
    local_state = copy($(state));
    local_rng = copy($(rng));
    ParticleDA.sample_initial_state!(local_state, $(model), local_rng);
)
SUITE["Model interface"]["update_state_stochastic!"] = @benchmarkable ParticleDA.update_state_stochastic!(
    local_state, $(model), local_rng
) setup=(
    local_state = copy($(state));
    local_rng = copy($(rng));
    ParticleDA.sample_initial_state!(local_state, $(model), local_rng);
    ParticleDA.update_state_deterministic!(local_state, $(model), 0);
)
SUITE["Model interface"]["sample_observation_given_state!"] = @benchmarkable ParticleDA.sample_observation_given_state!(
    local_observation, local_state, $(model), local_rng
) setup=(
    local_state = copy($(state));
    local_observation = copy($(observation));
    local_rng = copy($(rng));
    ParticleDA.sample_initial_state!(local_state, $(model), local_rng);
)
SUITE["Model interface"]["get_log_density_observation_given_state!"] = @benchmarkable ParticleDA.get_log_density_observation_given_state(
    local_observation, local_state, $(model)
) setup=(
    local_state = copy($(state));
    local_observation = copy($(observation));
    local_rng = copy($(rng));
    ParticleDA.sample_initial_state!(local_state, $(model), local_rng);
    ParticleDA.sample_observation_given_state!(
        local_observation, local_state, $(model), local_rng
    );
)


SUITE["Model interface"]["get_observation_mean_given_state!"] = @benchmarkable ParticleDA.get_observation_mean_given_state!(
    observation_mean, local_state, $(model)
) setup=(
    local_state = copy($(state));
    observation_mean = copy($(observation));
    local_rng = copy($(rng));
    ParticleDA.sample_initial_state!(local_state, $(model), local_rng);
)
SUITE["Model interface"]["get_covariance_observation_noise"] = (
    @benchmarkable ParticleDA.get_covariance_observation_noise($(model))
)
SUITE["Model interface"]["get_covariance_state_observation_given_previous_state"] = (
    @benchmarkable ParticleDA.get_covariance_state_observation_given_previous_state(
        $(model)
    )
)
SUITE["Model interface"]["get_covariance_observation_observation_given_previous_state"] = (
    @benchmarkable ParticleDA.get_covariance_observation_observation_given_previous_state(
        $(model)
    )
)

SUITE["Model interface"]["simulate_observations_from_model"] = @benchmarkable (
    ParticleDA.simulate_observations_from_model($(model), $(n_time_step))
)

for filter_type in (BootstrapFilter, OptimalFilter), statistics_type in (
    ParticleDA.NaiveMeanSummaryStat, 
    ParticleDA.NaiveMeanAndVarSummaryStat,
    ParticleDA.MeanSummaryStat,
    ParticleDA.MeanAndVarSummaryStat
)
    group = SUITE["Filtering ($(filter_type), $(statistics_type))"] = BenchmarkGroup()
    group["init_filter"] = @benchmarkable (
        ParticleDA.init_filter(
            $(filter_params),
            $(model),
            $(nprt_per_rank),
            $(filter_type),
            $(statistics_type)
        )
    )
    group["sample_proposal_and_compute_log_weights!"] = @benchmarkable (
        ParticleDA.sample_proposal_and_compute_log_weights!(
            states, 
            log_weights, 
            local_observation, 
            0, 
            $(model), 
            filter_data, 
            $(filter_type),
            local_rng
        )
    ) setup=(
        local_rng=copy($(rng));
        states=ParticleDA.init_states($(model), $(nprt_per_rank), local_rng);
        log_weights=Vector{Float64}(undef, $(nprt_per_rank));
        local_state = copy($(state));
        local_observation = copy($(observation));
        ParticleDA.sample_initial_state!(local_state, $(model), local_rng);
        ParticleDA.sample_observation_given_state!(
            local_observation, local_state, $(model), local_rng
        );
        filter_data = ParticleDA.init_filter(
            $(filter_params),
            $(model),
            $(nprt_per_rank),
            $(filter_type),
            $(statistics_type)
        )
        
    )
    group["run_particle_filter"] = @benchmarkable ( 
        ParticleDA.run_particle_filter(
            LLW2d.init,
            local_filter_params,
            $(params["model"]),
            $(observation_sequence),
            $(filter_type),
            $(statistics_type);
            rng=local_rng
        );
        rm(output_filename);
    ) seconds=30 evals=1 setup=(
        local_rng=copy($(rng));
        output_filename = tempname();
        local_filter_params = ParticleDA.FilterParameters(;
            output_filename=output_filename, 
            (; (Symbol(k) => v for (k, v) in $(params["filter"]))...)...
        );
    )
end
