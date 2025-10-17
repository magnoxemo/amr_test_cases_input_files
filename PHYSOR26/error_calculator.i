union_mesh_file_name = common_mesh_out.e-s004
ref_mesh_file_name = openmc_out.e
test_mesh_file_name = openmc_out.e
variable = flux
variable_rel_error = flux_rel_error

[Mesh]
    [file_mesh_generator]
        type = FileMeshGenerator
        file = $union_mesh_file_name
        use_for_exodus_restart = true
    []
[]

[AuxVariables]
    [flux_relative_discrepancy]
        order = CONSTANT
        family = MONOMIAL
    []
    [flux_rel_error_discrepancy]
        order = CONSTANT
        family = MONOMIAL
    []
    [z_score]
        order = CONSTANT
        family = MONOMIAL
    []
    [ref_flux_mean]
        order = CONSTANT
        family = MONOMIAL
    []
    [test_flux_mean]
        order = CONSTANT
        family = MONOMIAL
    []
    [ref_flux_rel_stat_error]
        order = CONSTANT
        family = MONOMIAL
    []
    [test_flux_rel_stat_error]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[UserObjects]
    [ref_sln_mean_user_obj]
        type = SolutionUserObject
        mesh = ${ref_mesh_file_name}
        system_variables = ${variable}
        timestep = 1
    [] 
    [test_sln_mean_user_obj]
        type = SolutionUserObject
        mesh = ${test_mesh_file_name}
        system_variables = ${variable}
        timestep = 1
    []
    [ref_sln_stat_error_user_obj]
        type = SolutionUserObject
        mesh = ${ref_mesh_file_name}
        system_variables = ${variable_rel_error}
        timestep = 1
    []
    [test_sln_stat_error_user_obj]
        type = SolutionUserObject
        mesh = ${test_mesh_file_name}
        system_variables = ${variable_rel_error}
        timestep = 1
    []  
[]


[AuxKernels]
  [load_ref_sln_mean]
    type= SolutionAux
    solution = ref_sln_mean_user_obj
    variable = ref_flux_mean
  []
  [load_ref_sln_stat_error]
    type= SolutionAux
    solution = ref_sln_stat_error_user_obj
    variable = ref_flux_rel_stat_error
  []
  [load_test_sln_mean]
    type= SolutionAux
    solution = test_sln_mean_user_obj
    variable = test_flux_mean
  []
  [load_test_sln_stat_error]
    type= SolutionAux
    solution = test_sln_stat_error_user_obj
    variable = test_flux_rel_stat_error
  []

  [flux_relative_discrepancy_calculation]

    type = ParsedAux
    variable = flux_relative_discrepancy    
    coupled_variables = 'test_flux_mean ref_flux_mean'
    expression = '( ref_flux_mean - test_flux_mean )/ ref_flux_mean'

  []
  
  [flux_error_discrepancy_calculation]
    type = ParsedAux
    variable = flux_rel_error_discrepancy
    coupled_variables = 'ref_flux_rel_stat_error test_flux_rel_stat_error'
    expression = '( test_flux_rel_stat_error - ref_flux_rel_stat_error )/ ref_flux_rel_stat_error'
  [] 
  
  [z_score_calculation]
    type = ParsedAux
    variable = z_score
    coupled_variables = 'ref_flux_rel_stat_error flux_relative_discrepancy'
    expression = 'flux_relative_discrepancy / ref_flux_rel_stat_error '
  []
  
[]

[UserObjects]
    [test_flux_mean_csv]
    	type = ElementCentroidCSV
    	metric_variable_name = test_flux_mean
    	csv_file_name = "test_flux_mean.csv"
    []
    [ref_flux_mean_csv]
    	type = ElementCentroidCSV
    	metric_variable_name = ref_flux_mean
    	csv_file_name = "ref_flux_mean.csv"
    []
    [test_flux_rel_stat_error_csv]
    	type = ElementCentroidCSV
    	metric_variable_name = test_flux_rel_stat_error
    	csv_file_name = "test_flux_rel_stat_error.csv"
    []
    [ref_flux_rel_stat_error_csv]
    	type = ElementCentroidCSV
    	metric_variable_name = ref_flux_rel_stat_error
    	csv_file_name = "ref_flux_rel_stat_error.csv"
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