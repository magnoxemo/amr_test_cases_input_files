[Mesh]
    [generate_mesh]
        type = GeneratedMeshGenerator
        dim = 3
        xmin = 0
        xmax = 10
        ymin = 0
        ymax = 10
        zmin = 0
        zmax = 10
        nx = 5
        ny = 5
        nz = 5 
    []
[]

[AuxVariables]
    [in_mesh]
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

    [fill_up_data]
        type = FunctionAux
        variable = in_mesh
        function = "sin(x*x/10+y*y*y/100)"
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
  num_steps = 7
[]

[Outputs]
  exodus = true
[]

[Postprocessors]
  [max_hierarchy]
    type = ElementMaxLevelPostProcessor
    level = h 
  []
[]