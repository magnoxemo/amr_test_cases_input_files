!include mesh.i
# The number of refinement cycles.
num_cycles = 10

# The upper error fraction. Elements are sorted from highest to lowest error,
# and then the elements with the largest error that sum to r_error_fraction
# multiplied by the total error are refined. This refinement scheme assumes
# error is well approximated by the jump discontinuity in the tally field.
r_error_fraction = 0.3

# The upper limit of statistical relative error - elements with a relative error larger
# then r_stat_error will not be refined.
r_stat_error = 1e-2

# The lower limit of statistical relative error - elements with a relative error larger
# then c_stat_error will be coarsened.
c_stat_error = 1e-1


[Mesh]
  [add_eeid_block]
    type = ParsedElementIDMeshGenerator
    extra_element_integer_names = 'boolean'
    values = '-1'
    input = generated_mesh
  []
[]

[AuxVariables]
  [aux_boolean]
      order = CONSTANT
      family = MONOMIAL
  []
[]

[AuxKernels]
  [store_boolean]
      type = ExtraElementIDAux
      extra_id_name = boolean
      variable = aux_boolean
  []
[]

[Problem]
  type = OpenMCCellAverageProblem
  particles = 20000
  inactive_batches = 50
  batches = 150

  verbose = true
  power = ${fparse 3000e6/3000}
  cell_level = 1
  normalize_by_global_tally = false

  [Tallies]
        [heat_source]
            type = MeshTally
            score = 'kappa_fission flux fission'
            name = 'kappa_fission flux fission'
            mesh_tally_amalgamation_post_processing = true
            extra_integer_name = boolean_combo_or
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
      variable = heat_source_rel_error
      third_state = DO_NOTHING
    []
    [error_combo]
      type = BooleanComboMarker
      refine_markers = 'rel_error error_frac'
      # from large relative errors causes the 'error_frac' marker to erroneously mark elements
      # for refinement.
      coarsen_markers = 'rel_error'
      boolean_operator = and
    []
  []
[]

[UserObjects]
    [clustering_1]
        type = ErrorFractionHeuristicUserObject
        upper_fraction=0.0
        lower_fraction=0.3
        metric_variable_name = flux_rel_error
    []
    [clustering_2]
        type = ValueDifferenceHeuristicUserObject
        tolerance=0.001
        metric_variable_name = flux
    []
    [boolean_combo_2]
        type = BooleanComboHeuristicUserObject
        name_of_the_user_objects= "clustering_1 clustering_2"
        id_name = 'boolean'
        expression ="( clustering_1 and clustering_2 )"
        execute_on = 'TIMESTEP_END'
    []
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
