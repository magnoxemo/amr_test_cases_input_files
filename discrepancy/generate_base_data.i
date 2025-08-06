
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
    [base_score]
        order = CONSTANT
        family = MONOMIAL
    []
[]
[Adaptivity]
    marker = error_fraction
    steps = 1
  [Indicators]
    [error]
      type = ValueJumpIndicator
      variable = base_score
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


[AuxKernels]
    [fill_up_data]
        type = FunctionAux
        variable = base_score
        function = "x*x+y*y"
        execute_on = 'TIMESTEP_BEGIN'
    []
[]

[Problem]
  type = FEProblem
  solve = false
[]

[Postprocessors]
  [max_hierarchy]
    type = ElementMaxLevelPostProcessor
    level = h 
  []
[]
[Executioner]
  type = Transient
  solve = false
  dt = 1
  num_steps = 10
[]

[Outputs]
  exodus = true
[]
