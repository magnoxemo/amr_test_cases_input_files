[Mesh]
  [mesh]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 100
    xmin = 0
    xmax = 10
    ymin = 0
    ymax = 10
    extra_element_integers='value_range error_fraction threshold boolean_combo'
  []
[]

[AuxVariables]
  [metric_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [value_range_aux]
    order = CONSTANT
    family = MONOMIAL
  []
  [error_fraction_aux]
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
  [create_metric]
    type = FunctionAux
    variable = metric_var
    function = "sin(x*x/100+y*y/100)"
    execute_on = 'TIMESTEP_BEGIN'
  []
  [store_element_id_2]
    type=ExtraElementIDAux
    extra_id_name ="value_range"
    variable=value_range_aux
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

  [store_element_id_5]
    type=ExtraElementIDAux
    extra_id_name ="error_fraction"
    variable=error_fraction_aux
  []

[]

[UserObjects]

  [clustering]
    type = ErrorFractionHeuristicUserObject
    execute_on = 'TIMESTEP_END'
    upper_fraction = 0.3
    lower_fraction = 0.2
    id_name = 'error_fraction'
    metric_variable_name =  metric_var
  []
  [clustering_01]
    type = ThresholdHeuristicsUserObject
    execute_on = 'TIMESTEP_END'
    id_name = 'threshold'
    metric_variable_name = metric_var
    threshold = .5
  []
  [cluster_heuristic_2]
    type = ValueRangeHeuristicUserObject
    value = 0.5
    tolerance_percentage= 0.3
    execute_on = 'TIMESTEP_END'
    id_name = 'value_range'
    metric_variable_name = metric_var
  []
  [boolean_combo_1]
    type = BooleanComboHeuristicUserObject
    extra_ids = 'threshold error_fraction value_range'
    id_name = 'boolean_combo'
    boolean_logic = "and or"
    metric_variable_name = metric_var
    execute_on = 'TIMESTEP_END'
  []

[]

[Problem]
  type = FEProblem
  solve = false
[]
[Executioner]
  type = Transient
  solve = false
  dt = 1
  num_steps = 4
[]

[Outputs]
  exodus = true
[]

