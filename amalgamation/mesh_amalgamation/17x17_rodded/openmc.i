[Mesh]

    [file_mesh]
        type = FileMeshGenerator
        file = mesh_in.e
    []

    [adding_eeid]
        type= ParsedElementIDMeshGenerator
        extra_element_integer_names="same_flux_gradient low_std boolean_combo_and boolean_combo_or"
        values='-1 -1 -1 -1'
        input=file_mesh
    []

[]

[AuxVariables]
    [same_flux_gradient]
        order = CONSTANT
        family = MONOMIAL
    []
    [low_std]
        order = CONSTANT
        family = MONOMIAL
    []
    [boolean_combo_and]
        order = CONSTANT
        family = MONOMIAL
    []
    [boolean_combo_or]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
    [store_element_id_2]
        type=ExtraElementIDAux
        extra_id_name ="boolean_combo_or"
        variable=boolean_combo_or
    []
    [store_element_id_3]
        type=ExtraElementIDAux
        extra_id_name ="boolean_combo_and"
        variable=boolean_combo_and
    []
    [store_element_id_4]
        type=ExtraElementIDAux
        extra_id_name ="same_flux_gradient"
        variable=same_flux_gradient
    []
    [store_element_id_5]
        type=ExtraElementIDAux
        extra_id_name ="low_std"
        variable=low_std
    []
[]


[Adaptivity]

    marker = error_combo
    steps = 10

    [Indicators]
        [flux_gradient]
            type = ValueJumpIndicator
            variable = flux
        []
        [fission_optical_depth]
            type=ElementOpticalDepthIndicator
            rxn_rate='fission'
            h_type = 'cube_root' 
        []
        [scattering_optical_depth]
            type=ElementOpticalDepthIndicator
            rxn_rate='scatter'
            h_type = 'cube_root' 
        []
    []

    [Markers]
        [error_frac]
            type = ErrorFractionMarker
            indicator = fission_optical_depth
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
    source_rate_normalization = 'kappa_fission'
    normalize_by_global_tally = false

    [Tallies]
        [heat_source]
            type = MeshTally
            score = 'kappa_fission fission scatter flux'
            name = "heat_source fission scatter flux"
            extra_integer_name=boolean_combo_and
            mesh_tally_amalgamation_post_processing = true
            output = 'unrelaxed_tally_rel_error'
        []
    []
[]


[UserObjects]

    [clustering_1]
        type = ErrorFractionHeuristicUserObject
        execute_on = 'TIMESTEP_END'
        id_name = 'low_std'
        upper_fraction=0.0
        lower_fraction=0.3
        metric_variable_name = flux_rel_error
    []

    [cluster_heuristic_2]
        type = ValueDifferenceHeuristicUserObject
        tolerance= .1
        execute_on = 'TIMESTEP_END'
        id_name = 'same_flux_gradient'
        metric_variable_name = flux_gradient
    []

    [boolean_combo_or]
        type = BooleanComboHeuristicUserObject
        extra_ids = 'same_flux_gradient low_std'
        id_name = boolean_combo_or
        boolean_logic = or
        metric_variable_name = flux_gradient
        execute_on = 'TIMESTEP_END'
        
    []
    [boolean_combo_and]
        type = BooleanComboHeuristicUserObject
        extra_ids = 'same_flux_gradient low_std'
        id_name = boolean_combo_and
        boolean_logic = and
        metric_variable_name = flux_gradient
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
