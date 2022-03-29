using BenchmarkTools
using ParticleDA
using MPI
using Random
using Base.Threads

include(joinpath(joinpath(@__DIR__, "..", "test"), "model", "model.jl"))
using .Model

if !MPI.Initialized()
    MPI.Init()
end

const SUITE = BenchmarkGroup()
const my_rank = MPI.Comm_rank(MPI.COMM_WORLD)
const my_size = MPI.Comm_size(MPI.COMM_WORLD)

SUITE["base"] = BenchmarkGroup()
SUITE["BootstrapFilter"] = BenchmarkGroup()
SUITE["OptimalFilter"] = BenchmarkGroup()

const params = Dict(
    "filter" => Dict(
        "nprt" => 32,
        "enable_timers" => true,
        "verbose" => true,
        "n_time_step" => 20,
    ),
    "model" => Dict(
        "llw2d" => Dict(
            "nx" => 200,
            "ny" => 200,
            "nobs" => 64,
            "padding" => 0,
        ),
    ),
)

const nprt_per_rank = Int(params["filter"]["nprt"] / my_size)
const rng = Random.TaskLocalRNG()
const model_data = Model.init(params["model"]["llw2d"], nprt_per_rank, my_rank, rng)
const bootstrap_filter_data = ParticleDA.init_filter(ParticleDA.get_params(ParticleDA.FilterParameters, params["filter"]), model_data, nprt_per_rank, rng, Float64, BootstrapFilter())
const filter_params = ParticleDA.get_params(ParticleDA.FilterParameters, params["filter"])

SUITE["base"]["get_particles"] = @benchmarkable ParticleDA.get_particles($(model_data))
SUITE["base"]["get_mean_and_var!"] = @benchmarkable ParticleDA.get_mean_and_var!(statistics, $(ParticleDA.get_particles(model_data)), $(filter_params.master_rank)) setup=(statistics=similar(bootstrap_filter_data.statistics))
SUITE["base"]["update_truth!"] = @benchmarkable ParticleDA.update_truth!($(model_data), $(nprt_per_rank))
SUITE["base"]["update_particle_dynamics!"] = @benchmarkable ParticleDA.update_particle_dynamics!($(model_data), $(nprt_per_rank))
SUITE["base"]["update_particle_noise!"] = @benchmarkable ParticleDA.update_particle_noise!($(model_data), $(nprt_per_rank))
SUITE["base"]["get_log_weights!"] = @benchmarkable ParticleDA.get_log_weights!(weights, truth_observations, model_observations, $(filter_params.weight_std)) setup=(weights = Vector{Float64}(undef, nprt_per_rank); truth_observations=ParticleDA.update_truth!(model_data, nprt_per_rank); model_observations = ParticleDA.get_particle_observations!(model_data, nprt_per_rank))
SUITE["base"]["normalized_exp!"] = @benchmarkable ParticleDA.normalized_exp!(weights) setup=(weights = rand(filter_params.nprt))
SUITE["base"]["resample!"] = @benchmarkable ParticleDA.resample!(resampling_indices, weights) setup=(resampling_indices = Vector{Int}(undef, filter_params.nprt); weights = rand(filter_params.nprt))
# SUITE["base"]["copy_states!"] = @benchmarkable ParticleDA.copy_states!($(ParticleDA.get_particles(model_data)), $(bootstrap_filter_data.copy_buffer), $(bootstrap_filter_data.resampling_indices), $(my_rank), $(nprt_per_rank))

SUITE["BootstrapFilter"]["init_filter"] = @benchmarkable ParticleDA.init_filter($(filter_params), $(model_data), $(nprt_per_rank), $(rng), Float64, $(BootstrapFilter()))
SUITE["BootstrapFilter"]["run_particle_filter"] = @benchmarkable ParticleDA.run_particle_filter($(Model.init), $(params), $(BootstrapFilter())) seconds=30 setup=(cd(mktempdir()))

SUITE["OptimalFilter"]["init_filter"] = @benchmarkable ParticleDA.init_filter($(filter_params), $(model_data), $(nprt_per_rank), $(rng), Float64, $(OptimalFilter()))
SUITE["OptimalFilter"]["run_particle_filter"] = @benchmarkable ParticleDA.run_particle_filter($(Model.init), $(params), $(OptimalFilter())) seconds=30 setup=(cd(mktempdir()))
