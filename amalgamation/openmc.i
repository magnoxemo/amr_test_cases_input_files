[Mesh]

    [file_mesh]
        type = FileMeshGenerator
        file = mesh_in.e
    []

    [adding_eeid]
        type= ParsedElementIDMeshGenerator
        extra_element_integer_names="value_diff threshold boolean_combo"
        values='-1 -1 -1'
        input=file_mesh
    []

[]

[AuxVariables]

    [value_diff_aux]
        order = CONSTANT
        family = MONOMIAL
    []
    [boolean_combo_aux]
        order = CONSTANT
        family = MONOMIAL
    []
    [threshold_aux]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
    [store_element_id_2]
        type=ExtraElementIDAux
        extra_id_name ="value_diff"
        variable=value_diff_aux
    []
    [store_element_id_3]
    type=ExtraElementIDAux
    extra_id_name ="boolean_combo"
    variable=boolean_combo_aux
    []
    [store_element_id_4]
    type=ExtraElementIDAux
    extra_id_name ="threshold"
    variable=threshold_aux
    []
[]


[Adaptivity]

    marker = error_combo
    steps = 10

    [Indicators/error]
        type = ValueJumpIndicator
        variable = heat_source
    []


[Markers]
    [error_frac]
        type = ErrorFractionMarker
        indicator = error
        refine = 0.5
        coarsen = 0.2
    []

[rel_error]
    type = ValueThresholdMarker
    invert = true
    coarsen = 2e-1
    refine = 1e-2
    variable = heat_source_rel_error
    third_state = DO_NOTHING
[]
[error_combo]
    type = BooleanComboMarker
    refine_markers = 'rel_error error_frac'
    coarsen_markers = 'rel_error'
    boolean_operator = and
[]

[]

[]

[Problem]
    type = OpenMCCellAverageProblem
    particles = 5000
    inactive_batches = 60
    batches = 80

    verbose = true
    power = ${fparse 3000e6 / 273 / (17 * 17)}
    cell_level = 1
    normalize_by_global_tally = false

    [Tallies]
        [heat_source]
            type = MeshTally
            score = 'kappa_fission'
            name = heat_source
            extra_integer_name=boolean_combo
            mesh_tally_amalgamation_post_processing = true
            output = 'unrelaxed_tally_rel_error'
        []
    []
[]


[UserObjects]

    [clustering]
        type = ThresholdHeuristicsUserObject
        execute_on = 'TIMESTEP_END'
        id_name = 'threshold'
        metric_variable_name = heat_source_rel_error
        threshold = 0.008
    []

    [cluster_heuristic_2]
        type = ValueDifferenceHeuristicUserObject
        tolerance= 2
        execute_on = 'TIMESTEP_END'
        id_name = 'value_diff'
        metric_variable_name = heat_source
    []

    [boolean_combo_1]
        type = BooleanComboHeuristicUserObject
        extra_ids = 'threshold value_diff'
        id_name = boolean_combo
        boolean_logic = and
        metric_variable_name = error
        execute_on = 'TIMESTEP_END'
    []

[]

[Executioner]
    type = Steady
[]

[Postprocessors]
    [num_active]
        type = NumElements
        elem_filter = active
    []
    [num_total]
        type = NumElements
        elem_filter = total
    []
    [max_rel_err]
        type = TallyRelativeError
        value_type = max
        tally_score = kappa_fission
    []
[]

[Outputs]
    exodus = true
    csv = true
[]
