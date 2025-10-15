[Mesh]
  [generated_mesh]
     type = GeneratedMeshGenerator
    nx = 20
    ny = 4
    nz = 4
    xmin = 0.0
    xmax = 100.0
    ymin = 0.0
    ymax = 10.0
    zmin = 0.0
    zmax = 10.0
    dim = 3
  []
[]


[AuxVariables]
    [adaptive_hierarchy]
        order = CONSTANT
        family = MONOMIAL
    []
    [element_refinement_step]
        order = CONSTANT
        family = MONOMIAL
    []
    [same_flux_high_relative_error_ma]
        order = CONSTANT
        family = MONOMIAL
    []

    [max_elemental_hierachy]
        order = CONSTANT
        family = MONOMIAL
    []

    [high_relative_error_ma]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]

  [adaptive_hierarchy_aux]
    type=ElementHierarchyAux
    variable=adaptive_hierarchy
  []

  [cp_sln_mesh_1]
    type= SolutionAux
    solution = amr_solution_user_object
    variable = high_relative_error_ma
  []

  [cp_sln_mesh_2]
    type= SolutionAux
    solution = mesh_amalgamation_user_object
    variable = same_flux_high_relative_error_ma
  []

  [calculate_max_hierarchy_refinement_step]
    type = ParsedAux
    variable = max_elemental_hierachy
    coupled_variables = 'same_flux_high_relative_error_ma high_relative_error_ma'
    expression = 'max(same_flux_high_relative_error_ma, high_relative_error_ma)'
  []

  [calculate_refinement_step]
    type = ParsedAux
    variable = element_refinement_step
    coupled_variables = 'adaptive_hierarchy max_elemental_hierachy'
    expression = 'abs(max_elemental_hierachy - adaptive_hierarchy)'
  []
[]

[Adaptivity]
    marker = marker
    steps = 1

  [Markers]
    [marker]
      type = ValueThresholdMarker
      coarsen = -2
      refine = 0.7
      variable = element_refinement_step
    []

  []
[]


[UserObjects]
    [amr_solution_user_object]
        type = SolutionUserObject
        mesh = gt.e-s011
        system_variables = hierarchy
        timestep = 1
    [] 

    [mesh_amalgamation_user_object]
        type = SolutionUserObject
        mesh = hex_same_flux_high_err_ma.e-s010
        system_variables = hierarchy
        timestep = 1
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
