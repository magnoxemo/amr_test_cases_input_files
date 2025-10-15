[Mesh]
    [file_mesh_generator]
        type = FileMeshGenerator
        file = common_mesh_out.e-s004
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
    [amr_flux_tally]
        order = CONSTANT
        family = MONOMIAL
    []
    [ma_flux_tally]
        order = CONSTANT
        family = MONOMIAL
    []
    [amr_flux_tally_statistical_error]
        order = CONSTANT
        family = MONOMIAL
    []
    [ma_flux_tally_statistical_error]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
  [cp_sln_mesh_1]
    type= SolutionAux
    solution = amr_solution_user_object
    variable = amr_flux_tally
  []
  [cp_sln_mesh_2]
    type= SolutionAux
    solution = amr_user_object_statistical_error
    variable = amr_flux_tally_statistical_error
  []
  [cp_sln_mesh_3]
    type= SolutionAux
    solution = mesh_amalgamation_user_object_statistical_error
    variable = ma_flux_tally_statistical_error
  []
  [cp_sln_mesh_5]
    type= SolutionAux
    solution = mesh_amalgamation_user_object
    variable = ma_flux_tally
  []
  
  
  #actual calculation part
  [flux_relative_discrepancy_calculation]
    type = ParsedAux
    variable = flux_relative_discrepancy    
    coupled_variables = 'ma_flux_tally amr_flux_tally'
    expression = '( amr_flux_tally - ma_flux_tally )/ amr_flux_tally'
  []
  
  [flux_error_discrepancy_calculation]
    type = ParsedAux
    variable = flux_rel_error_discrepancy
    coupled_variables = 'amr_flux_tally_statistical_error ma_flux_tally_statistical_error'
    expression = '( ma_flux_tally_statistical_error - amr_flux_tally_statistical_error )/ amr_flux_tally_statistical_error'
  [] 
  
  [z_score_calculation]
    type = ParsedAux
    variable = z_score
    coupled_variables = 'amr_flux_tally_statistical_error flux_relative_discrepancy'
    expression = 'flux_relative_discrepancy / amr_flux_tally_statistical_error '
  []
  
[]

[UserObjects]
    [amr_solution_user_object]
        type = SolutionUserObject
        mesh = gt_truth.e
        system_variables = flux
        timestep = 1
    [] 
    [mesh_amalgamation_user_object]
        type = SolutionUserObject
        mesh = ma_test.e
        system_variables = flux
        timestep = 1
    []
    [amr_user_object_statistical_error]
        type = SolutionUserObject
        mesh = gt_truth.e
        system_variables = flux_rel_error
        timestep = 1
    []
    [mesh_amalgamation_user_object_statistical_error]
        type = SolutionUserObject
        mesh = ma_test.e
        system_variables = flux_rel_error
        timestep = 1
    [] 
    #csv data
    [csv_data]
    	type = ElementCentroidCSV
    	metric_variable_name = "flux_relative_discrepancy"
	csv_file_name = "flux_relative_discrepancy_data.csv"
    []
    [z_score_csv_data]
    	type = ElementCentroidCSV
    	metric_variable_name = "z_score"
    	csv_file_name = "z_score_csv_data.csv"
    []
    [flux_rel_error_discrepancy_csv_data]
    	type = ElementCentroidCSV
    	metric_variable_name = "flux_rel_error_discrepancy"
    	csv_file_name = "flux_rel_error_discrepancy_csv_data.csv"
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
