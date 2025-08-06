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
        nx = 40
        ny = 40
        nz = 40
    []
[]


[AuxVariables]

    [discrepency]
        order = CONSTANT
        family = MONOMIAL
    []

    [solution_mesh_a]
        order = CONSTANT
        family = MONOMIAL
    []

    [solution_mesh_b]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]

    [cp_sln_mesh_a]
        type= SolutionAux
        solution = sln_b
        variable = solution_mesh_a
    []

    [cp_sln_mesh_b]
        type= SolutionAux
        solution = sln_a
        variable = solution_mesh_b
    []
    [calculate_discrepancy]
        type = ParsedAux
        variable = discrepency
        coupled_variables = 'solution_mesh_a solution_mesh_b'
        expression = '( solution_mesh_a - solution_mesh_b )/ solution_mesh_a' 

    []

[]

[UserObjects]
    [sln_a]
        type = SolutionUserObject
        mesh = generate_base_data_out.e-s010
        system_variables = base_score
        timestep = 1
    [] 
    [sln_b]
        type = SolutionUserObject
        mesh = to_data_out.e-s007
        system_variables = in_mesh
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
  num_steps = 1
[]

[Outputs]
  exodus = true
[]

