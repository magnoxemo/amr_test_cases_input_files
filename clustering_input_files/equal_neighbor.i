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
  [grad_metric]
	order = CONSTANT
	family = MONOMIAL
  []
[]

[AuxKernels]
  [create_metric]
    type = FunctionAux
    variable = metric_var
    function = "sin(x*y/10)"
    execute_on = 'TIMESTEP_BEGIN'  
  []
  [store_element_id]
    type=ExtraElementIDAux
    extra_id_name ="cluster_id"
    variable=cluster_id_aux
  []

[]

[UserObjects]
  [cluster_heuristic]
    type = ValueDifferenceHeuristicUserObject
    tolerance = 0.01
    execute_on = 'TIMESTEP_END'
    id_name = 'cluster_id' 
    metric_variable_name = metric_var
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
