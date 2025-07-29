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
        nx = 10
        ny = 10
        nz = 10
        elem_type = TET4
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
    [copy_base_score]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]

    [fill_up_data]
        type = FunctionAux
        variable = in_mesh
        function = "sin(x*x/100+y*y/100)"
        execute_on = 'TIMESTEP_BEGIN'
    []
    [cp_base_score]
        type= SolutionAux
        solution = sln
        variable = copy_base_score
    []

    [discrepency]
        type= DiscrepancyAux
        solution = sln
        variable =discrepency
        in_mesh_variable = in_mesh
        out_mesh_variable = base_score
    []
[]

[UserObjects]
    [sln]
        type = SolutionUserObject
        mesh = generate_base_data_out.e
        system_variables = base_score
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