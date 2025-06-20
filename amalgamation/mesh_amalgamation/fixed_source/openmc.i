!include mesh.i
!include ../amr_strategies/value_jump.i
!include eeiid.i

[AuxVariables]
    [gradient_flux]
        order = CONSTANT
        family = MONOMIAL
    []
    [gradient_flux_vector]
        type = VectorMooseVariable
        order = CONSTANT
        family = MONOMIAL_VEC
    []
[]
[AuxKernels]
    [comp_gradient_flux]
        type = FDTallyGradAux
        variable = gradient_flux_vector
        score = 'flux'
    []
    [mag]
        type = VectorVariableMagnitudeAux
        vector_variable = gradient_flux_vector
        variable = gradient_flux
    []
[]

[Problem]
    type = OpenMCCellAverageProblem
    particles = 200000
    batches = 20

    verbose = true
    power = ${fparse 3000e6 / 273}

    normalize_by_global_tally = false
    source_rate_normalization = 'heating'
    assume_separate_tallies = false
    source_strength = 10e16
    check_tally_sum = false

    [Tallies]
        [heat_source]
            type = MeshTally
            score = 'scatter flux kappa_fission'
            name = 'scatter flux kappa_fission'
            mesh_tally_amalgamation_post_processing = true
            extra_integer_name =boolean
            output = 'unrelaxed_tally_rel_error'
        []
    []
[]
[UserObjects]
    [clustering_1]
        type = ThresholdHeuristicsUserObject
        execute_on = 'TIMESTEP_END'
        id_name = 'low_std'
        threshold = ${c_stat_error}
        cluster_if_above_threshold = false
        metric_variable_name = flux_rel_error
    []
    [clustering_2]
        type = ErrorFractionHeuristicUserObject
        execute_on = 'TIMESTEP_END'
        id_name = 'gradient_flux'
        upper_fraction=0.0
        lower_fraction=0.2
        metric_variable_name = gradient_flux
    []
    [boolean_combo_or]
        type = BooleanComboHeuristicUserObject
        extra_ids = 'gradient_flux high_rel_error'
        id_name = 'boolean'
        boolean_logic = and
        metric_variable_name = flux
        execute_on = 'TIMESTEP_END'
    []
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

[Executioner]
    type = Steady
[]

[Outputs]
    exodus = true
    csv = true
[]
