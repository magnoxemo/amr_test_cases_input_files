# ==========================================================
# openmc.i 
#  |-- solid.i  
#       |-- sub_channel.i 
# ==========================================================
!include ../common.i

[

[Problem]
  type = OpenMCCellAverageProblem
  power = ${fparse assembly_th_power}
  verbose = true

  temperature_blocks  = 'fuel_top fuel_middle fuel_bottom clad water'
  temperature_variables     = temp
  density_blocks= 'water'
  density_variables   = density
  cell_level    = 1
  initial_properties  = xml
  source_rate_normalization = kappa_fission
  relaxation    = robbins_monro
  scaling = 100
  particles = 40000
  inactive_batches = 5
  batches = 15


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



[MultiApps]
  [solid]
    type = TransientMultiApp
    input_files = solid.i
    execute_on  = 'initial timestep_end'
    sub_cycling = true
  []
  [sub_channel]
    type = TransientMultiApp
    input_files = sub_channel.i
    execute_on = 'initial timestep_end'
    sub_cycling = true
  []
[]

[Transfers]
 [heat_source_to_solid]
    type = MultiAppGeneralFieldNearestLocationTransfer
    to_multi_app = solid
    source_variable = heat_source
    variable = heat_source
  []
  [T_from_solid]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = solid
    source_variable = T
    variable = temp
    to_blocks = 'fuel_top fuel_middle fuel_bottom clad water'
  []
  [T_fluid_from_solid]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = sub_channel
    source_variable = T
    variable = temp
    to_blocks = 'water'
  []

  [rho_fluid_from_subchannel]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = sub_channel
    source_variable = rho
    variable = density
    execute_on = 'initial timestep_end'
  []

  [T_wall_to_sub_channel]
    type = MultiAppGeneralFieldNearestLocationTransfer
    to_multi_app = sub_channel
    from_multi_app = solid
    source_variable = T_wall_send
    variable = Tpin                # was T_wall — SCM expects Tpin
    execute_on = 'initial timestep_end'
  []

  [T_fluid_from_subchannel]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = sub_channel
    to_multi_app = solid
    source_variable = T
    variable = T_fluid
    execute_on = 'initial timestep_end'
  []

  [htc_from_sub_channel]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = sub_channel
    to_multi_app = solid
    source_variable = HTC
    variable = heat_transfer_co_efficient
    execute_on = 'initial timestep_end'
  []
[]

[Postprocessors]
  [heat_source_pp]
    type = ElementIntegralVariablePostprocessor
    variable = heat_source
    block = 'fuel_top fuel_middle fuel_bottom'
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
  [k_rel_err]
    type = KEigenvalue
    value_type = 'combined'
    output = 'rel_err'
  []
[]


[Executioner]
  type = Transient
  dt = 0.1
  num_steps = 20 # 20 iterations gives essentially steady-state convergence with steady_state_tolerance=0.001 on the heat_source AuxVar
[]

[Outputs]
  exodus = true
  csv = true
  [console]
    type = Console
    execute_postprocessors_on = 'timestep_end'
  []
[]