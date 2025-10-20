union_mesh_file_name = common_mesh_out.e-s004
ref_mesh_file_name = openmc_out.e
test_mesh_file_name = openmc_out.e

variables="flux flux_rel_error"
tally_variable="flux"
tally_rel_error_variable="flux_rel_error"

[Mesh]
    [file_mesh_generator]
        type = FileMeshGenerator
        file = ${union_mesh_file_name}
        use_for_exodus_restart = true
    []
[]

[AuxVariables]
    [ref_flux_mean]
        order = CONSTANT
        family = MONOMIAL
    []
    [ref_flux_rel_stat_error]
        order = CONSTANT
        family = MONOMIAL
    []
    [test_flux_mean]
        order = CONSTANT
        family = MONOMIAL
    []
    [test_flux_rel_stat_error]
        order = CONSTANT
        family = MONOMIAL
    []
    [flux_rel_discrepancy_mean]
        order = CONSTANT
        family = MONOMIAL
    []
    [flux_rel_discrepancy_stat_error]
        order = CONSTANT
        family = MONOMIAL
    []
    [z_score]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
  [load_ref_sln_mean]
    type= SolutionAux
    solution = ref_sln_user_obj
    variable = ref_flux_mean
    from_variable =${tally_variable}
  []
  [load_ref_sln_stat_error]
    type= SolutionAux
    solution = ref_sln_user_obj
    variable = ref_flux_rel_stat_error
    from_variable = ${tally_rel_error_variable}
  []
  [load_test_sln_mean]
    type= SolutionAux
    solution = test_sln_user_obj
    variable = test_flux_mean
    from_variable = ${tally_variable}
  []
  [load_test_sln_stat_error]
    type= SolutionAux
    solution = test_sln_user_obj
    variable = test_flux_rel_stat_error
    from_variable = ${tally_rel_error_variable}
  []

  [flux_relative_discrepancy_calculation]

    type = ParsedAux
    variable = flux_rel_discrepancy_mean
    coupled_variables = 'test_flux_mean ref_flux_mean'
    expression = '( ref_flux_mean - test_flux_mean )/ ref_flux_mean'

  []
  
  [flux_error_discrepancy_calculation]
    type = ParsedAux
    variable = flux_rel_discrepancy_stat_error
    coupled_variables = 'ref_flux_rel_stat_error test_flux_rel_stat_error'
    expression = '( test_flux_rel_stat_error - ref_flux_rel_stat_error )/ ref_flux_rel_stat_error'
  [] 
  
  [z_score_calculation]
    type = ParsedAux
    variable = z_score
    coupled_variables = 'ref_flux_rel_stat_error flux_rel_discrepancy_mean'
    expression = 'flux_rel_discrepancy_mean / ref_flux_rel_stat_error '
  []
  
[]

[UserObjects]

    [ref_sln_user_obj]
        type = SolutionUserObject
        mesh = ${ref_mesh_file_name}
        system_variables = ${variables}
    [] 
    [test_sln_user_obj]
        type = SolutionUserObject
        mesh = ${test_mesh_file_name}
        system_variables =  ${variables}
    []

    #csv files sections 
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
