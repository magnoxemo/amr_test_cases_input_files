[Mesh]
	[file]
		type = FileMeshGenerator
		file = mesh_in.e
	[]
[]

[Functions]
    
    [set_mean_heat_source]
        type=ParsedFunction
        expression= mean_heat_source
        symbol_names= mean_heat_source
        symbol_values= mean_heat_source
    []
    
    [set_n_elements]
        type=ParsedFunction
        expression=  n_elements
        symbol_names= n_elements
        symbol_values= n_elements
    []
[]

[AuxVariables]

[mean_heat_source]
        order = CONSTANT
        family = MONOMIAL
    []
    
    
    [std_heat_source]
        order = CONSTANT
        family = MONOMIAL
    []
    
    [z_scores]
        order = CONSTANT
        family = MONOMIAL
    []
    [n_elements]
        order = CONSTANT
        family = MONOMIAL
    []
[]
[AuxKernels]

	[mean_heat_source]
		type=FunctionAux
		variable=mean_heat_source
		function=set_mean_heat_source
	[]
	[n_elements]
		type=FunctionAux
		variable=n_elements
		function=set_n_elements
	[]
	
    [std_heat_source]
        type = ParsedAux
        variable = std_heat_source
        coupled_variables = 'heat_source mean_heat_source n_elements'
        execute_on = 'TIMESTEP_END'
        expression = 'sqrt(((heat_source - mean_heat_source)^2) / n_elements)'

    []
    [z_scores]
        type = ParsedAux
        variable = z_scores
        coupled_variables = 'heat_source mean_heat_source std_heat_source'
        execute_on = 'TIMESTEP_END'
        function = 'abs(heat_source - mean_heat_source) / std_heat_source'

    []
[]

[Problem]
    type = OpenMCCellAverageProblem
    particles = 1000
    inactive_batches = 10
    batches = 50
    verbose = true
    power = ${fparse 3000e6 / 273 / (17 * 17)}
    cell_level = 1
    normalize_by_global_tally = false

    [Tallies]
        [heat_source]
            type = MeshTally
            score = 'kappa_fission'
            name = heat_source
            output = 'unrelaxed_tally_rel_error'
        []
    []
[]

[Adaptivity]
    marker = z_score_marker
    steps = 3

    [Markers]
        [z_score_marker]
            type = ValueRangeMarker
            variable = z_scores
            lower_bound = 0
            upper_bound = 1
            third_state = COARSEN
            invert = false
        []
    []
[]


[Postprocessors]
    [n_elements]
        type = NumElements
        execute_on = 'TIMESTEP_END'
    []

    [mean_heat_source]
        type=ElementAverageValue
        variable=heat_source
        execute_on = 'TIMESTEP_END'
    []
[]

[Executioner]
type = Steady
[]

[Outputs]
exodus = true
csv = true
console = true
[]

