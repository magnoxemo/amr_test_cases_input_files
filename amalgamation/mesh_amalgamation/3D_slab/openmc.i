!include mesh.i


num_cycles = 10
r_error_fraction = 0.4
r_stat_error = 0.1
c_stat_error = 1e-1


[AuxVariables]
  [aux_same_flux]
      order = CONSTANT
      family = MONOMIAL
  []
[]


[AuxKernels]
  [store_same_flux]
      type = ExtraElementIDAux
      extra_id_name = same_flux
      variable = aux_same_flux
  []
[]

[Problem]
    type = OpenMCCellAverageProblem
    particles = 3000
    inactive_batches = 40
    batches = 100

    verbose = true
    power = ${fparse 3000e6 / 273}

    normalize_by_global_tally = false
    source_rate_normalization = 'kappa_fission'
    assume_separate_tallies = true

    [Tallies]
        [heat_source]
            type = MeshTally
            score = 'kappa_fission scatter flux fission'
            name = 'kappa_fission scatter flux fission'
            mesh_tally_amalgamation_post_processing = true
            extra_integer_name = same_flux
            output = 'unrelaxed_tally_rel_error'
        []
    []
[]


[Adaptivity]
  marker = error_combo
  steps = ${num_cycles}

  [Indicators/error]
    type = ValueJumpIndicator
    variable = flux
  []
  [Markers]
    [error_frac]
      type = ErrorFractionMarker
      indicator = error
      refine = ${r_error_fraction}
      coarsen = 0.0
    []
    [rel_error]
      type = ValueThresholdMarker
      invert = true
      coarsen = ${c_stat_error}
      refine = ${r_stat_error}
      variable = flux_rel_error
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



[UserObjects]
    [value_difference]
        type = ValueDifferenceHeuristicUserObject
        metric_variable_name = flux
        tolerance = 0.008
    []
    [high_relative_error]
        type = ValueFractionHeuristicUserObject
        metric_variable_name = flux_rel_error
        upper_fraction = 0.2
        lower_fraction = 0
    []
    [clusteing]
        type = BooleanComboClusteringUserObject
        id_name = "same_flux"
        expression = "( value_difference and high_relative_error )"
        execute_on = TIMESTEP_BEGIN
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
        tally_score = scatter
    []

[]

[Executioner]
    type = Steady
[]

[Outputs]
    exodus = true
    csv = true
[]
