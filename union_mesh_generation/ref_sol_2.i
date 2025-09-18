[Mesh]
    [generate_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        xmin = 0
        xmax = 10
        ymin = 0
        ymax = 10
        nx = 2
        ny = 2
    []
[]

[AuxVariables]
    [in_mesh]
        order = CONSTANT
        family = MONOMIAL
    []
    [hierarchy]
        order = CONSTANT
        family = MONOMIAL
    []
    [discrepency]
        order = CONSTANT
        family = MONOMIAL
    []

    [copied_sln]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
  [hierarchy_aux_kernel]
    type=ElementHierarchyAux
    variable=hierarchy
  []

    [fill_up_data]
        type = FunctionAux
        variable = in_mesh
        function = "x*x/100+y*y"
        execute_on = 'TIMESTEP_BEGIN'
    []
[]

[Adaptivity]
    marker = error_fraction
    steps = 1
  [Indicators]
    [error]
      type = ValueJumpIndicator
      variable = in_mesh
	  execute_on = 'TIMESTEP_BEGIN'
    []
  []

  [Markers]
    [error_fraction]
      type = ErrorFractionMarker
      indicator = error
      refine = 0.3
      coarsen = 0.2
	  execute_on = 'TIMESTEP_BEGIN'
    []
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
  num_steps = 3
[]

[Outputs]
  exodus = true
[]

