
[ICs]
  [temp]
    type = ConstantIC
    variable = temp
    value = ${coolant_inlet_temperature}
  []
  [density]
    type = ConstantIC
    variable = density
    value = ${fparse 1.00423e3 + -0.21390*coolant_inlet_temperature+-1.1046e-5*coolant_inlet_temperature^2}
  []
[]


[AuxVariables]
  [cell_temperature]
    family = MONOMIAL
    order = CONSTANT
  []
  [cell_density]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [cell_temperature]
    type = CellTemperatureAux
    variable = cell_temperature
  []
  [cell_density]
    type = CellDensityAux
    variable = cell_density
  []
[]


[Problem]
  type = OpenMCCellAverageProblem
  power = ${fparse assembly_th_power}
  verbose = true

  temperature_blocks  = 'fuel_bottom fuel_middle fuel_top gas_gap_bottom gas_gap_middle gas_gap_top clad_bottom clad_middle clad_top water'
  temperature_variables = temp
  density_blocks= 'water'
  density_variables = density
  cell_level = 1
  initial_properties  = xml
  source_rate_normalization = kappa_fission
  relaxation    = robbins_monro
  scaling = 100
  particles = 50000
  inactive_batches = 200
  batches = 1000


  [Tallies]
    [heat_source]
      type = MeshTally
      score   = 'kappa_fission flux fission scatter absorption'
      name    = "heat_source neutron_flux fission_reaction_rate scattering_reaction_rate absorption_reaction_rate"
      normalize_by_global_tally = false
      output  = 'unrelaxed_tally_std_dev unrelaxed_tally_rel_error'
    []
  []
[]


[Executioner]
  type = Transient
  num_steps = 50
[]


# ============================== MultiApps =================================

[MultiApps]
  [solid]
    type = TransientMultiApp
    input_files = solid.i
    execute_on  = 'timestep_end'
    sub_cycling = true
  []
  [sub_channel]
    type = FullSolveMultiApp
    input_files = sub_channel.i
    execute_on = 'timestep_begin'
    max_procs_per_app = 1
  []
[]

[Transfers]
  [heat_source_to_solid]
    type = MultiAppGeneralFieldNearestLocationTransfer
    to_multi_app = solid
    source_variable = heat_source
    variable = heat_source
    from_postprocessors_to_be_preserved = openmc_power_integral
    to_postprocessors_to_be_preserved   = conduction_power_integral
  []
  [solid_temperature_from_conduction]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = solid
    source_variable = T
    variable = temp
    to_blocks = 'fuel_bottom fuel_middle fuel_top gas_gap_bottom gas_gap_middle gas_gap_top clad_bottom clad_middle clad_top water'
  []

  [linear_heat_rate_to_subchannel]
    type = MultiAppGeneralFieldNearestLocationTransfer
    to_multi_app = sub_channel
    from_multi_app = solid
    source_variable = q_prime
    variable = q_prime
    greedy_search = true
    use_bounding_boxes = false
    to_blocks = 'fuel_pins'
  []


  [fluid_temperature_from_subchannel]
    type = MultiAppGeneralFieldNearestLocationTransfer
    source_variable = T
    variable = temp
    from_multi_app = sub_channel
    greedy_search = true
    use_bounding_boxes = false
    to_blocks = 'water'
    from_blocks = 'subchannel'
  []
  [fluid_density_from_subchannel]
    type = MultiAppGeneralFieldNearestLocationTransfer
    source_variable = rho
    variable = density
    from_multi_app = sub_channel
    greedy_search = true
    use_bounding_boxes = false
    to_blocks = 'water'
    from_blocks = 'subchannel'
  []
  [clad_surface_temperature_to_conduction]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = sub_channel
    to_multi_app = solid
    source_variable = Tpin
    variable = T_wall
  []
[]

[Postprocessors]
  [openmc_power_integral]
    type = ElementIntegralVariablePostprocessor
    variable = heat_source
    execute_on = 'transfer timestep_end'
  [] 
  [k]
    type = KEigenvalue
    value_type = 'combined'
    output = 'mean'
  []
  [k_std_dev]
    type = KEigenvalue
    value_type = 'combined'
    output = 'std_dev'
  []
  [max_coolant_T]
    type = ElementExtremeValue
    variable = temp
    block = 'water'
    value_type = max
  []
  [avg_coolant_T]
    type = ElementAverageValue
    variable = temp
    block = 'water'
  []
  [min_coolant_T]
    type = ElementExtremeValue
    variable = temp
    block = 'water'
    value_type = min
  []
  [max_coolant_rho]
    type = ElementExtremeValue
    variable = density
    block = 'water'
    value_type = max
  []
  [avg_coolant_rho]
    type = ElementAverageValue
    variable = density
    block = 'water'
  []
  [min_coolant_rho]
    type = ElementExtremeValue
    variable = density
    block = 'water'
    value_type = min
  []

  
[]




[Outputs]
  exodus = true
  csv = true
[]