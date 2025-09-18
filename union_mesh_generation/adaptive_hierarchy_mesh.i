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
    [adaptive_hierarchy]
        order = CONSTANT
        family = MONOMIAL
    []
    [element_refinement_step]
        order = CONSTANT
        family = MONOMIAL
    []
    [hierarchy_field_from_ref_1]
        order = CONSTANT
        family = MONOMIAL
    []

    [max_elemental_hierachy]
        order = CONSTANT
        family = MONOMIAL
    []


    [hierarchy_field_from_ref_2]
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
    solution = ref_copier_1
    variable = hierarchy_field_from_ref_1
  []

  [cp_sln_mesh_2]
    type= SolutionAux
    solution = ref_copier_2
    variable = hierarchy_field_from_ref_2
  []

  [calculate_max_hierarchy_refinement_step]
    type = ParsedAux
    variable = max_elemental_hierachy
    coupled_variables = 'hierarchy_field_from_ref_1 hierarchy_field_from_ref_2'
    expression = 'max(hierarchy_field_from_ref_1, hierarchy_field_from_ref_2)'
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
    [ref_copier_1]
        type = SolutionUserObject
        mesh = to_data_out.e-s004
        system_variables = hierarchy
        timestep = 1
    [] 

    [ref_copier_2]
        type = SolutionUserObject
        mesh = ref_sol_2_out.e-s003
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
