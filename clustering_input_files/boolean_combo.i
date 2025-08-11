[Mesh]
  [mesh]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    extra_element_integers='value_range boolean_combo threshold'
  []
[]

[AuxVariables]
  [metric_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [boolean_combo_aux]
    order = CONSTANT
    family = MONOMIAL
  []

[]

[AuxKernels]

  [create_metric]
    type = FunctionAux
    variable = metric_var
    function = "5*x+1"
    execute_on = 'TIMESTEP_BEGIN'  
  []

  [store_element_id_3]
    type=ExtraElementIDAux
    extra_id_name ="boolean_combo"
    variable=boolean_combo_aux
  []

[]


[UserObjects]
  [threshold]
    type = ThresholdHeuristicsUserObject
    threshold = 3
    metric_variable_name = metric_var
  []
  [threshold_2]
    type = ThresholdHeuristicsUserObject
    threshold = 4
    metric_variable_name = metric_var
  []
  [boolean]
    type = BooleanComboClusteringUserObject
    id_name = 'boolean_combo' 
    expression = " ( threshold and not threshold_2 )"
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
