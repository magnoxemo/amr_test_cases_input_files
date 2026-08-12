[Variables]
  [T]
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
  [time_T]
    type = HeatConductionTimeDerivative
    variable = T
  []
  [heat_source_fuel]
    type = CoupledForce
    variable = T
    v = heat_source
    block = 'fuel'
  []
[]



[Materials]
  [fuel_k]
    type = GenericConstantMaterial
    block = 'fuel'
    prop_names  = 'thermal_conductivity specific_heat density'
    prop_values = '3    300   10970'  
  []
  [gap_k]
    type = GenericConstantMaterial
    block = 'gap'
    prop_names  = 'thermal_conductivity specific_heat density'
    prop_values = '1.5  5000 3.5'    
  []
  [clad_k]
    type = GenericConstantMaterial
    block = 'clad'
    prop_names  = 'thermal_conductivity specific_heat density'
    prop_values = '10   350   6500' 
  []
[]

[AuxVariables]
  [T_wall]
    initial_condition = ${coolant_inlet_temperature}
  []
  [heat_source]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = .5e6
    block = 'fuel'
  []
  [q]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = 0.0
    block = 'fuel'
  []
  [q_prime]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = 0.0
    block = 'fuel'
  []
  [z]
  []
[]

[BCs]
  [cladding_outer_bc]
    type = MatchedValueBC
    variable = T
    v = T_wall
    boundary = 'clad_outer'
  []
[]

[Executioner]
  type = Transient
[]

[AuxKernels]
  [q]
    type = SpatialUserObjectAux
    variable = q
    user_object = q_prime_uo
    block = 'fuel'
  []
  [q_prime] # divide by height of each averaging layer to get W/m from W
    type = ParsedAux
    variable = q_prime
    coupled_variables = 'q'
    expression = 'q / ${fparse active_core_height /num_heat_axial_layers}'
    block = 'fuel'
  []
  [z]
    type = ParsedAux
    variable = z
    use_xyzt = true
    expression = 'z'
  []
[]

[UserObjects]
  [q_prime_uo]
    type = NearestPointLayeredIntegral
    variable = heat_source
    block = 'fuel'
    direction = z
    points_file = '../pin_centers.txt'  # place holder 
    num_layers = ${num_heat_axial_layers}
    execute_on = 'initial timestep_begin'
  []
[]

[Postprocessors]
  [z_location_of_T_max_fuel]
    type = ElementExtremeValue
    proxy_variable = T
    variable = z
    block = 'fuel'
  []
  [z_location_of_T_max_clad]
    type = ElementExtremeValue
    proxy_variable = T
    variable = z
    block = 'clad'
  []
  [z_location_of_T_max_wall]
    type = ElementExtremeValue
    proxy_variable = T_wall
    variable = z
    block = 'clad'
  []

  [conduction_power_integral]
    type = ElementIntegralVariablePostprocessor
    variable = heat_source
    block = 'fuel'
    execute_on = 'transfer'
  []
  [max_fuel_T]
    type = ElementExtremeValue
    variable = T
    block = 'fuel'
  []

  [max_clad_T]
    type = ElementExtremeValue
    variable = T
    block = 'clad'
  []
  [avg_fuel_T]
    type = ElementAverageValue
    variable = T
    block = 'fuel'
  []
  [max_T_wall_send]
    type = SideExtremeValue
    variable = T_wall
    boundary = 'clad_outer'
    value_type = max
  []
  [min_T_wall_send]
    type = SideExtremeValue
    variable = T_wall
    boundary = 'clad_outer'
    value_type = min
  []
[]


[Outputs]
  exodus = true
  csv = true
[]