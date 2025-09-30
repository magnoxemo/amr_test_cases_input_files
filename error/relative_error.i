[Mesh]
    [file_mesh_generator]
        type = FileMeshGenerator
        file = common_mesh_out.e
        use_for_exodus_restart = true
    []
[]

[AuxVariables]
    [relative_error]
        order = CONSTANT
        family = MONOMIAL
    []
    [high_relative_error_ma]
        order = CONSTANT
        family = MONOMIAL
    []
    [same_flux_high_relative_error_ma]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
  [cp_sln_mesh_1]
    type= SolutionAux
    solution = high_err_ma
    variable = high_relative_error_ma
  []

  [cp_sln_mesh_2]
    type= SolutionAux
    solution = same_flux_high_err_ma
    variable = same_flux_high_relative_error_ma
  []
  [relative_error_calculation]
    type = ParsedAux
    variable = relative_error
    coupled_variables = 'same_flux_high_relative_error_ma high_relative_error_ma'
    expression = '100* abs ( same_flux_high_relative_error_ma - high_relative_error_ma )/ high_relative_error_ma'
  []

[]

[UserObjects]
    [high_err_ma]
        type = SolutionUserObject
        mesh = hex_high_error_ma.e-s010
        system_variables = flux
        timestep = 1
    [] 
    [same_flux_high_err_ma]
        type = SolutionUserObject
        mesh = hex_same_flux_high_err_ma.e-s010
        system_variables = flux
        timestep = 1
    []
[]

[Problem]
  type = FEProblem
  solve = false
[]

[Executioner]
  type = Steady
  solve = false
[]

[Outputs]
  exodus = true
[]
