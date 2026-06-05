ref_mesh_file_name="openmc_out.e"
tally_variable="FoM"

[Mesh]
    [file_mesh_generator]
        type = FileMeshGenerator
        file = ${ref_mesh_file_name}
        use_for_exodus_restart = true
    []
[]

[AuxVariables]
    [FoM]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
  [load_ref_sln_mean]
    type= SolutionAux
    solution = ref_sln_user_obj
    variable = FoM
    from_variable =${tally_variable}
  []
[]

[UserObjects]
    [ref_sln_user_obj]
        type = SolutionUserObject
        mesh = ${ref_mesh_file_name}
        system_variables = ${tally_variable}
    []
[]

[VectorPostprocessors]
  [csv_data_extractor]
    type = ElementValueSampler
    sort_by = "x"
    variable = ${tally_variable}
    execute_on = 'initial timestep_end'
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
  csv = true
[]
