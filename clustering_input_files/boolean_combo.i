[Mesh]
  [mesh]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 100
    xmin = -5
    xmax = 5
    ymin = -5
    ymax = 5
    extra_element_integers='value_range boolean_combo threshold'
  []
[]

[AuxVariables]
  [metric_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [std]
    order = CONSTANT
    family = MONOMIAL
  []
  [value_range_aux]
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
  [reverse_std]
    type = ParsedAux
    variable = std
    expression = ".0098-error"
    coupled_variables = error
    execute_on = 'TIMESTEP_BEGIN'
  []
  [create_metric]
    type = FunctionAux
    variable = metric_var
    function = "1+sin(x*y/10)*cos(x*y/10)"
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

[]

[Adaptivity]
  [Indicators]
    [error]
      type = ValueJumpIndicator
      variable = metric_var
    []
  []
[]

[UserObjects]
  [clustering]
    type = ThresholdHeuristicsUserObject
    execute_on = 'TIMESTEP_END'
    id_name = 'threshold' 
    metric_variable_name = 'std'
    threshold = .008
  []
  [cluster_heuristic_2]
    type = ValueRangeHeuristicUserObject
    value = 0.002
    tolerance_percentage= 0.3
    execute_on = 'TIMESTEP_END'
    id_name = 'value_range'
    metric_variable_name = error
  []
  [boolean_combo_1]
    type = BooleanComboHeuristicUserObject
    extra_ids = 'threshold value_range'
    id_name = 'boolean_combo' 
    boolean_logic = and
    metric_variable_name = error
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
