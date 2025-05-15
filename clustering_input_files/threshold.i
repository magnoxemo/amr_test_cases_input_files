

[Mesh]
  [mesh]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin = -10
    xmax = 10
    ymin = -10
    ymax = 10
    extra_element_integers = 'cluster_id' 
  []
[]

[AuxVariables]
  [metric_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [cluster_id_aux]
	order = CONSTANT
	family = MONOMIAL
  []
  [gradientjump]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [create_metric]
    type = FunctionAux
    variable = metric_var
    function = "sin(x+y)"
    execute_on = 'TIMESTEP_BEGIN'   
  []
  [store_element_id]
    type=ExtraElementIDAux
    extra_id_name ="cluster_id"
    variable=cluster_id_aux
  []

[]
[Adaptivity]
  [Indicators]
    [error]
    type = ValueJumpIndicator 
    variable = "metric_var"
    []
  []
[]

[UserObjects]
  [clustering]
  type = ThresholdHeuristicsUserObject
  execute_on = 'TIMESTEP_END'

  id_name = 'cluster_id' 
  metric_variable_name = 'metric_var' 
  threshold = .5
  []
[]

[Problem]
  type = FEProblem
  solve = false
[]

[Executioner]
  type = Transient
  solve = false
  dt = 0.1
  num_steps = 10
[]

[Outputs]
  exodus = true
[]
