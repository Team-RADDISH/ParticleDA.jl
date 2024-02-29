"""Nektar++ driftwave system state space model.

Deterministic dynamics solve two-dimensional Hasegawa-Wakatani equations with spatially
correlated additive state noise simulated by solving a Helmholtz equation driven by
a Gaussian white noise process. System is simulated on a rectangular spatial domain with
periodic boundary conditions, and a regular quadrilaterial mesh using Nektar++ spectral
element method implementation.
"""
module NektarDriftwave

using Base.Threads
using Distributions
using FillArrays
using HDF5
using Random
using PDMats
using Gmsh: gmsh
using CSV
using Tables
using XML
using ParticleDA

"""
    NektarDriftwaveModelParameters()

Parameters for Nektar++ driftwave system state space model.
"""
Base.@kwdef struct NektarDriftwaveModelParameters{S <: Real, T <: Real}
    "Path to directory containing Nektar++ binaries"
    nektar_bin_directory::String = ""
    "Path to directory containing DriftWaveSolver binary"  
    driftwave_solver_bin_directory::String = ""
    "Hasegawa-Wakatani system parameter α"
    alpha::S = 2.
    "Hasegawa-Wakatani system parameter κ"
    kappa::S = 1.
    "Lengthscale parameter for bump function used for initial field means"
    s::S = 2.
    "Lengthscale parameter for state noise in dynamics and initialisation"
    lambda::S = 0.1
    "Number of quadrilateral elements along each axis in mesh"
    mesh_dims::Vector{Int} = [32, 32]
    "Size (extents) of rectangular spatial domain mesh is defined on"
    mesh_size::Vector{Float64} = [40., 40.]
    "Number of modes in expansion (one higher than the polynomial order)"
    num_modes::Int = 4
    "Time step for numerical integraton in time"
    time_step::S = 0.0005
    "Number of time integrations steps to perform between each observation of state"
    num_steps_per_observation_time::Int = 1000
    "Points at which state is observed in two-dimensional spatial domain"
    observed_points::Vector{Vector{Float64}} = map(
        collect, vec(collect(Iterators.product(-10.:10.:10., -10.:10.:10.)))
    )
    "Which of field variables are observed (subset of {phi, zeta, n})"
    observed_variables::Vector{String} = ["phi"]
    "Output scale parameter for initial state field Gaussian process"
    initial_state_scale::Union{S, Vector{S}} = 0.05
    "Output scale parameter for additive state noise fields Gaussian process"
    state_noise_scale::Union{S, Vector{S}} = 0.05
    "Scale parameter (standard deviation) of independent Gaussian noise in observations"
    observation_noise_std::Union{T, Vector{T}} = 0.1
end

function get_params(
    P::Type{NektarDriftwaveModelParameters{S, T}}, model_params_dict::Dict
) where {S <: Real, T <: Real}
    return P(; (; (Symbol(k) => v for (k, v) in model_params_dict)...)...)
end

function make_gmsh_quadrilateral_mesh(output_path, mesh_dim, mesh_size)
    point_dim, line_dim, surface_dim = 0, 1, 2
    point_tag, (bottom_tag, top_tag, left_tag, right_tag, surface_tag) = 1, 1:5
    gmsh.initialize()
    # Create point at bottom-left corner
    gmsh.model.geo.addPoint(-mesh_size[1] / 2, -mesh_size[2] / 2, 0)
    # Extrude point to a segmented line rightwards along x-axis forming bottom edge
    gmsh.model.geo.extrude([(point_dim, point_tag)], mesh_size[1], 0, 0, [mesh_dim[1]])
    # Extrude segmented line to a quadrilateralized surface upwards along y-axis
    gmsh.model.geo.extrude([(line_dim, bottom_tag)], 0, mesh_size[2], 0, [mesh_dim[2]], [], true)
    gmsh.model.geo.synchronize()
    # Add physical groups for quadrilateralized surface and four boundaries
    gmsh.model.addPhysicalGroup(surface_dim, [surface_tag], 0)
    gmsh.model.addPhysicalGroup(line_dim, [bottom_tag], 1)
    gmsh.model.addPhysicalGroup(line_dim, [right_tag], 2)
    gmsh.model.addPhysicalGroup(line_dim, [top_tag], 3)
    gmsh.model.addPhysicalGroup(line_dim, [left_tag], 4)
    # Generate mesh and write to file
    gmsh.model.mesh.generate(surface_dim)
    gmsh.write(output_path)
    gmsh.finalize()
end

function change_extension(path, new_extension)
    path_stem, old_extension = splitext(path)
    return "$(path_stem).$(new_extension)"
end

struct MeshFilePaths
    with_expansions::String
    no_expansions::String
end

function make_mesh_files(parameters, output_directory, nek_mesh_path)
    mesh_file_path = joinpath(output_directory, "mesh.xml")
    mesh_no_expansions_file_path = joinpath(output_directory, "mesh_no_expansions.xml")
    gmsh_mesh_file_path = change_extension(mesh_file_path, "msh")
    make_gmsh_quadrilateral_mesh(gmsh_mesh_file_path, parameters.mesh_dims, parameters.mesh_size)
    run(`$(nek_mesh_path) -f $(gmsh_mesh_file_path) $(mesh_file_path)`)
    # Output additional copy of mesh file which removes the default EXPANSIONS element
    # to avoid interfering with solver specific element in conditions files when
    # conditions files is passed as a preceding argument (necessary with solver commands
    # for session name inferred from names of XML files passed in to be specific to the
    # conditions file rather than named after the mesh file)
    mesh_root_node = read(mesh_file_path, Node)
    filter!(node -> tag(node) != "EXPANSIONS", children(mesh_root_node[end]))
    XML.write(mesh_no_expansions_file_path, mesh_root_node)
    return MeshFilePaths(mesh_file_path, mesh_no_expansions_file_path)
end

function make_driftwave_conditions_file(output_path, previous_state_path, parameters)
    xml_content = """
    <?xml version="1.0" encoding="utf-8" ?>
    <NEKTAR>
        <COLLECTIONS DEFAULT="auto" />
        <EXPANSIONS>
            <E COMPOSITE="C[0]" NUMMODES="$(parameters.num_modes)" TYPE="MODIFIED" FIELDS="zeta,n,phi" />
        </EXPANSIONS>
        <CONDITIONS>
            <SOLVERINFO>
                <I PROPERTY="EQTYPE" VALUE="DriftWaveSystem" />
                <I PROPERTY="Projection" VALUE="DisContinuous" />
                <I PROPERTY="TimeIntegrationMethod" VALUE="ClassicalRungeKutta4" />
            </SOLVERINFO>
            <PARAMETERS>
                <P> NumSteps = $(parameters.num_steps_per_observation_time) </P>
                <P> TimeStep = $(parameters.time_step) </P>
                <P> IO_InfoSteps = 0 </P>
                <P> IO_CheckSteps = 0 </P>
                <P> s = $(parameters.s) </P>
                <P> kappa = $(parameters.kappa) </P>
                <P> alpha = $(parameters.alpha) </P>
            </PARAMETERS>
            <VARIABLES>
                <V ID="0"> zeta </V>
                <V ID="1"> n </V>
                <V ID="2"> phi </V>
            </VARIABLES>
            <BOUNDARYREGIONS>
                <B ID="0"> C[1] </B>
                <B ID="1"> C[2] </B>
                <B ID="2"> C[3] </B>
                <B ID="3"> C[4] </B>
            </BOUNDARYREGIONS>
            <BOUNDARYCONDITIONS>
                <REGION REF="0">
                    <P VAR="zeta" VALUE="[2]" />
                    <P VAR="n"    VALUE="[2]" />
                    <P VAR="phi"  VALUE="[2]" />
                </REGION>
                <REGION REF="1">
                    <P VAR="zeta" VALUE="[3]" />
                    <P VAR="n"    VALUE="[3]" />
                    <P VAR="phi"  VALUE="[3]" />
                </REGION>
                <REGION REF="2">
                    <P VAR="zeta" VALUE="[0]" />
                    <P VAR="n"    VALUE="[0]" />
                    <P VAR="phi"  VALUE="[0]" />
                </REGION>
                <REGION REF="3">
                    <P VAR="zeta" VALUE="[1]" />
                    <P VAR="n"    VALUE="[1]" />
                    <P VAR="phi"  VALUE="[1]" />
                </REGION>
            </BOUNDARYCONDITIONS>
            <FUNCTION NAME="InitialConditions">
                <F VAR="n,zeta,phi" FILE="$(previous_state_path)" />
            </FUNCTION>
        </CONDITIONS>
    </NEKTAR>    
    """
    open(output_path, "w") do f
        write(f, xml_content)
    end
end

function make_grf_conditions_file(output_path, parameters)
    xml_content = """
    <NEKTAR>
        <COLLECTIONS DEFAULT="auto" />
        <EXPANSIONS>
            <E COMPOSITE="C[0]" NUMMODES="$(parameters.num_modes)" TYPE="MODIFIED" FIELDS="u" />
        </EXPANSIONS>
        <CONDITIONS>
            <SOLVERINFO>
                <I PROPERTY="EQTYPE" VALUE="Helmholtz" />
                <I PROPERTY="Projection" VALUE="DisContinuous" />
            </SOLVERINFO>
            <PARAMETERS>
                <P> lambda = $(parameters.lambda) </P>
            </PARAMETERS>
            <VARIABLES>
                <V ID="0"> u </V>
            </VARIABLES>
            <BOUNDARYREGIONS>
                <B ID="0"> C[1] </B>
                <B ID="1"> C[2] </B>
                <B ID="2"> C[3] </B>
                <B ID="3"> C[4] </B>
            </BOUNDARYREGIONS>
            <BOUNDARYCONDITIONS>
                <REGION REF="0">
                    <P VAR="u" VALUE="[2]" />
                </REGION>
                <REGION REF="1">
                    <P VAR="u" VALUE="[3]" />
                </REGION>
                <REGION REF="2">
                    <P VAR="u" VALUE="[0]" />
                </REGION>
                <REGION REF="3">
                    <P VAR="u" VALUE="[1]" />
                </REGION>
            </BOUNDARYCONDITIONS>
            <FUNCTION NAME="Forcing">
                <E VAR="u" VALUE="awgn(1)" />
            </FUNCTION>
        </CONDITIONS>
    </NEKTAR>
    """
    open(output_path, "w") do f
        write(f, xml_content)
    end
end

function make_poisson_conditions_file(output_path, forcing_field_path, parameters)
    # TODO: Identify why we get numerical issues when using discontinuous projection
    xml_content = """
    <NEKTAR>
        <COLLECTIONS DEFAULT="auto" />
        <EXPANSIONS>
            <E COMPOSITE="C[0]" NUMMODES="$(parameters.num_modes)" TYPE="MODIFIED" FIELDS="u" />
        </EXPANSIONS>
        <CONDITIONS>
            <SOLVERINFO>
                <I PROPERTY="EQTYPE" VALUE="Poisson" />
                <I PROPERTY="Projection" VALUE="Continuous" />
            </SOLVERINFO>
            <PARAMETERS> </PARAMETERS>
            <VARIABLES>
                <V ID="0"> u </V>
            </VARIABLES>
            <BOUNDARYREGIONS>
                <B ID="0"> C[1] </B>
                <B ID="1"> C[2] </B>
                <B ID="2"> C[3] </B>
                <B ID="3"> C[4] </B>
            </BOUNDARYREGIONS>
            <BOUNDARYCONDITIONS>
                <REGION REF="0">
                    <P VAR="u" VALUE="[2]" />
                </REGION>
                <REGION REF="1">
                    <P VAR="u" VALUE="[3]" />
                </REGION>
                <REGION REF="2">
                    <P VAR="u" VALUE="[0]" />
                </REGION>
                <REGION REF="3">
                    <P VAR="u" VALUE="[1]" />
                </REGION>
            </BOUNDARYCONDITIONS>
            <FUNCTION NAME="Forcing">
                <F VAR="u" FILE="$(forcing_field_path)" />
            </FUNCTION>
        </CONDITIONS>
    </NEKTAR>
    """
    open(output_path, "w") do f
        write(f, xml_content)
    end
end

struct NektarExecutablePaths
    adr_solver::String
    driftwave_solver::String
    field_convert::String
    nek_mesh::String
end

function NektarExecutablePaths(parameters::NektarDriftwaveModelParameters)
    return NektarExecutablePaths(
        joinpath(parameters.nektar_bin_directory, "ADRSolver"),
        joinpath(parameters.driftwave_solver_bin_directory, "DriftWaveSolver"),
        joinpath(parameters.nektar_bin_directory, "FieldConvert"),
        joinpath(parameters.nektar_bin_directory, "NekMesh"),
    )
end

struct NektarConditionsFilePaths
    driftwave::String
    grf::String
    poisson::String
end

function NektarConditionsFilePaths(parent_directory::String)
    return NektarConditionsFilePaths(
        joinpath(parent_directory, "driftwave.xml"),
        joinpath(parent_directory, "grf.xml"),
        joinpath(parent_directory, "poisson.xml")
    )
end

get_field_file_path(conditions_file_path) = change_extension(conditions_file_path, "fld")

struct NektarDriftwaveModel{S <: Real, T <: Real}
    parameters::NektarDriftwaveModelParameters{S, T}
    executable_paths::NektarExecutablePaths
    root_working_directory::String
    mesh_file_paths::MeshFilePaths
    observed_points_file_path::String
    task_working_directories::Vector{String}
    task_conditions_file_paths::Vector{NektarConditionsFilePaths}
    observation_noise_distribution::MvNormal{T}
end

function make_observed_points_file(parameters, root_working_directory)
    observed_points_file_path = joinpath(root_working_directory, "observed_points.csv")
    observed_points_table = Tables.table(
        # In Julia 1.9+ we can use stack(...; dims=1) but we use hcat for compatibility
        reduce(hcat, parameters.observed_points)'
    )
    CSV.write(observed_points_file_path, observed_points_table; header=["# x", "y"])
    return observed_points_file_path
end

function generate_gaussian_random_field_file(model, task_index, variable, noise_scale, mean_expression=nothing)
    conditions_file_paths = model.task_conditions_file_paths[task_index]
    grf_field_file_path = get_field_file_path(conditions_file_paths.grf)
    field_expression_string = 
    if isnothing(mean_expression)
        field_expression_string = "$(noise_scale) * u"
    else
        field_expression_string = "$(mean_expression) + $(noise_scale) * u"
    end
    run(`$(model.executable_paths.adr_solver) -f -i Hdf5 $(conditions_file_paths.grf) $(model.mesh_file_paths.no_expansions)`)
    variable_field_path = joinpath(model.task_working_directories[task_index], "$(variable).fld")
    run(`$(model.executable_paths.field_convert) -f -m fieldfromstring:fieldstr="$(field_expression_string)":fieldname="$(variable)" $(model.mesh_file_paths.with_expansions) $(grf_field_file_path) $(variable_field_path):fld:format=Hdf5`)
    run(`$(model.executable_paths.field_convert) -f -m removefield:fieldname="u" $(model.mesh_file_paths.with_expansions) $(variable_field_path) $(variable_field_path):fld:format=Hdf5`)
    return variable_field_path
end

function concatenate_fields(model, field_file_paths, concatenated_field_file_path)
    run(`$(model.executable_paths.field_convert) -f $(model.mesh_file_paths.with_expansions) $(field_file_paths) $(concatenated_field_file_path):fld:format=Hdf5`)
end

function add_fields(model, field_file_path_1, field_file_path_2, output_field_file_path)
    run(`$(model.executable_paths.field_convert) -f -m addfld:fromfld=$(field_file_path_1) $(model.mesh_file_paths.with_expansions) $(field_file_path_2) $(output_field_file_path):fld:format=Hdf5`)
end

function update_phi(model, task_index)
    conditions_file_paths = model.task_conditions_file_paths[task_index]
    poisson_field_file_path = get_field_file_path(conditions_file_paths.poisson)
    driftwave_field_file_path = get_field_file_path(conditions_file_paths.driftwave)
    run(`$(model.executable_paths.adr_solver) -f -i Hdf5 $(conditions_file_paths.poisson) $(model.mesh_file_paths.no_expansions)`)
    run(`$(model.executable_paths.field_convert) -f $(model.mesh_file_paths.with_expansions) $(driftwave_field_file_path) $(poisson_field_file_path) $(driftwave_field_file_path):fld:format=Hdf5`)
    run(`$(model.executable_paths.field_convert) -f -m fieldfromstring:fieldstr="u":fieldname="phi" $(model.mesh_file_paths.with_expansions) $(driftwave_field_file_path) $(driftwave_field_file_path):fld:format=Hdf5`)
    run(`$(model.executable_paths.field_convert) -f -m removefield:fieldname="u" $(model.mesh_file_paths.with_expansions) $(driftwave_field_file_path) $(driftwave_field_file_path):fld:format=Hdf5`)
end

function write_state_to_field_file(field_file_path, state)
    h5open(field_file_path, "r+") do field_file
        field_file["NEKTAR"]["DATA"][:] = state
    end
end

function read_state_from_field_file!(state, field_file_path)
    h5open(field_file_path, "r") do field_file
        state .= field_file["NEKTAR"]["DATA"][:]
    end    
end

function interpolate_field_at_observed_points(model, task_index, field_file_path)
    interpolated_field_file_path = joinpath(model.task_working_directories[task_index], "interpolated_field.csv")
    run(`$(model.executable_paths.field_convert) -f -m interppoints:fromxml=$(model.mesh_file_paths.with_expansions):fromfld=$(field_file_path):topts=$(model.observed_points_file_path) $(interpolated_field_file_path)`)
    interpolated_field_data = CSV.File(interpolated_field_file_path; select=(i, name) -> String(name) in model.parameters.observed_variables)
    return Tables.matrix(interpolated_field_data)
end

function distribution_observation_given_state(state, model, task_index)
    cd(model.task_working_directories[task_index])
    conditions_file_paths = model.task_conditions_file_paths[task_index]
    driftwave_field_file_path = get_field_file_path(conditions_file_paths.driftwave)
    write_state_to_field_file(driftwave_field_file_path, state)
    field_at_observed_points = interpolate_field_at_observed_points(model, task_index, driftwave_field_file_path)
    return field_at_observed_points[:] + model.observation_noise_distribution
end

function init(
    parameters_dict::Dict,
    n_tasks::Int=1;
    S::Type{<:Real}=Float64,
    T::Type{<:Real}=Float64
)
    parameters = get_params(NektarDriftwaveModelParameters{S, T}, parameters_dict)
    executable_paths = NektarExecutablePaths(parameters)
    root_working_directory = mktempdir(; prefix="jl_ParticleDA_nektar_driftwave_")
    task_working_directories = [
        joinpath(root_working_directory, "task_$(t)") for t in 1:n_tasks
    ]
    task_conditions_file_paths = [
        NektarConditionsFilePaths(task_working_directory)
        for task_working_directory in task_working_directories
    ]
    mesh_file_paths = make_mesh_files(parameters, root_working_directory, executable_paths.nek_mesh)
    observed_points_file_path = make_observed_points_file(parameters, root_working_directory)
    for (task_working_directory, conditions_file_paths) in zip(task_working_directories, task_conditions_file_paths)
        mkdir(task_working_directory)
        driftwave_field_file_path = get_field_file_path(conditions_file_paths.driftwave)
        make_driftwave_conditions_file(conditions_file_paths.driftwave, driftwave_field_file_path, parameters)
        make_grf_conditions_file(conditions_file_paths.grf, parameters)
        make_poisson_conditions_file(conditions_file_paths.poisson, "$(driftwave_field_file_path):zeta", parameters)
    end
    observation_dimension = length(parameters.observed_points)
    observation_noise_distribution = MvNormal(
        Zeros{T}(observation_dimension),
        ScalMat(observation_dimension, parameters.observation_noise_std^2)
    )
    return NektarDriftwaveModel(
        parameters,
        executable_paths,
        root_working_directory,
        mesh_file_paths,
        observed_points_file_path,
        task_working_directories,
        task_conditions_file_paths,
        observation_noise_distribution
    )
end

ParticleDA.get_state_dimension(model::NektarDriftwaveModel) = (
    model.parameters.mesh_dims[1] * model.parameters.mesh_dims[1] * model.parameters.num_modes^2 * 3
)
ParticleDA.get_observation_dimension(model::NektarDriftwaveModel) = length(
    model.parameters.observed_points
)
ParticleDA.get_state_eltype(::NektarDriftwaveModel{S, T}) where {S, T} = S
ParticleDA.get_observation_eltype(::NektarDriftwaveModel{S, T}) where {S, T} = T

function ParticleDA.sample_initial_state!(
    state::AbstractVector{T},
    model::NektarDriftwaveModel{S, T}, 
    rng::Random.AbstractRNG,
    task_index::Integer=1
) where {S, T}
    conditions_file_paths = model.task_conditions_file_paths[task_index]
    driftwave_field_file_path = get_field_file_path(conditions_file_paths.driftwave)
    cd(model.task_working_directories[task_index])
    variable_mean_expressions = Dict(
        "n" => "exp((-x*x-y*y)/$(model.parameters.s^2))",
        "zeta" => "4*exp((-x*x-y*y)/($(model.parameters.s^2)))*(-$(model.parameters.s^2)+x*x+y*y)/$(model.parameters.s^4)",
    )
    variable_field_file_paths = [
        generate_gaussian_random_field_file(
            model, task_index, variable, model.parameters.initial_state_scale, mean_expression
        )
        for (variable, mean_expression) in pairs(variable_mean_expressions)
    ]
    concatenate_fields(model, variable_field_file_paths, driftwave_field_file_path)
    update_phi(model, task_index)
    read_state_from_field_file!(state, driftwave_field_file_path)
end

function ParticleDA.update_state_deterministic!(
    state::AbstractVector{T}, 
    model::NektarDriftwaveModel{S, T}, 
    time_index::Integer,
    task_index::Integer=1
) where {S, T}
    cd(model.task_working_directories[task_index])
    conditions_file_paths = model.task_conditions_file_paths[task_index]
    driftwave_field_file_path = get_field_file_path(conditions_file_paths.driftwave)
    write_state_to_field_file(driftwave_field_file_path, state)
    run(`$(model.executable_paths.driftwave_solver) -f -i Hdf5 $(conditions_file_paths.driftwave) $(model.mesh_file_paths.no_expansions)`)
    read_state_from_field_file!(state, driftwave_field_file_path)
end

function ParticleDA.update_state_stochastic!(
    state::AbstractVector{T}, 
    model::NektarDriftwaveModel{S, T}, 
    rng::Random.AbstractRNG,
    task_index::Integer=1
) where {S, T}
    cd(model.task_working_directories[task_index])
    conditions_file_paths = model.task_conditions_file_paths[task_index]
    driftwave_field_file_path = get_field_file_path(conditions_file_paths.driftwave)
    noise_field_file_path = joinpath(model.task_working_directories[task_index], "noise.fld")
    write_state_to_field_file(driftwave_field_file_path, state)
    variable_field_file_paths = [
        generate_gaussian_random_field_file(
            model, task_index, variable, model.parameters.state_noise_scale
        )
        for variable in ["n", "zeta"]
    ]
    concatenate_fields(model, variable_field_file_paths, noise_field_file_path)
    add_fields(model, driftwave_field_file_path, noise_field_file_path, driftwave_field_file_path)
    update_phi(model, task_index)
    read_state_from_field_file!(state, driftwave_field_file_path)
end
    
function ParticleDA.sample_observation_given_state!(
    observation::AbstractVector{T},
    state::AbstractVector{S}, 
    model::NektarDriftwaveModel{S, T}, 
    rng::Random.AbstractRNG,
    task_index::Integer=1 
) where {S <: Real, T <: Real}
    return rand!(rng, distribution_observation_given_state(state, model, task_index), observation)
end

function ParticleDA.get_log_density_observation_given_state(
    observation::AbstractVector{T},
    state::AbstractVector{S},
    model::NektarDriftwaveModel{S, T},
    task_index::Integer=1
) where {S <: Real, T <: Real}
    return logpdf(distribution_observation_given_state(state, model, task_index), observation)
end

function ParticleDA.write_model_metadata(file::HDF5.File, model::NektarDriftwaveModel)
    group_name = "parameters"
    if !haskey(file, group_name)
        group = create_group(file, group_name)
        for field in fieldnames(typeof(model.parameters))
            value = getfield(model.parameters, field)
            attributes(group)[string(field)] = (
                isa(value, AbstractVector) ? collect(value) : value
            )
        end
    else
        @warn "Write failed, group $group_name already exists in  $(file.filename)!"
    end
end

end
