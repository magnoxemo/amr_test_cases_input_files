!include ../common.i

[Mesh]
  [load]
    type = FileMeshGenerator
    file = mesh_hc_in.e
  []
  length_unit = 'm'
[]

[Variables]
  [T]
    initial_condition = 600.0
  []
[]

[AuxVariables]
  [heat_source]                    # W/m^3
    family = MONOMIAL
    order = CONSTANT
    block = 'fuel'
  []
  [T_fluid]                        # from THM, K
    initial_condition = ${inlet_temperature}
  []
  [heat_transfer_co_efficient]     # from THM, W/m^2-K
    initial_condition = 30000.0
  []
  [T_wall_send]                    # to THM, K
    family = MONOMIAL
    order = CONSTANT
    initial_condition = 600.0
    boundary = 'clad_outer'  
  []
[]

[Kernels]
  [conduction]
    type = HeatConduction
    variable = T
  []

  [time_T]
    type = HeatConductionTimeDerivative
    variable = T
  []
  [source]
    type = CoupledForce
    variable = T
    v = heat_source
    block = 'fuel'
  []
[]

[AuxKernels]
  [sample_wall_T]
    type = SpatialUserObjectAux
    variable = T_wall_send
    user_object = layered_clad_T
    boundary = 'clad_outer'
  []

[]

[UserObjects]
  [layered_clad_T]
    type = NearestPointLayeredSideAverage
    variable = T
    boundary = 'clad_outer'
    direction = z
    num_layers = ${n_axial_layers}
    points = '0 0 0'
    execute_on = 'initial timestep_end'
  []
[]

[BCs]
  [clad_to_coolant]
    type = CoupledConvectiveHeatFluxBC
    variable = T
    boundary = 'clad_outer'
    T_infinity = T_fluid
    htc = heat_transfer_co_efficient
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
    prop_values = '0.15  5000 0.197'    
  []
  [clad_k]
    type = GenericConstantMaterial
    block = 'clad'
    prop_names  = 'thermal_conductivity specific_heat density'
    prop_values = '22   350   6500' 
  []
[]





[Executioner]
  type = Transient
  nl_abs_tol = 5e-6
  nl_rel_tol = 5e-6
  l_max_its = 50
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  dtmin = 0.001

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    optimal_iterations = 15
    iteration_window = 2
    linear_iteration_ratio = 100
    growth_factor = 2
    cutback_factor = 0.5
  []

  solve_type=NEWTON
  line_search = none
  automatic_scaling = true

[]

[Postprocessors]
  [max_fuel_T]
    type = ElementExtremeValue
    variable = T
    block = 'fuel'
  []
  [max_T_fluid]
    type = ElementExtremeValue
    variable = T_fluid
    value_type = max
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
  [avg_coolant_T]
    type = ElementAverageValue
    variable = T_fluid
  []
  [max_T_wall_send]
    type = SideExtremeValue
    variable = T_wall_send
    boundary = 'clad_outer'
    value_type = max
  []
  [min_T_wall_send]
    type = SideExtremeValue
    variable = T_wall_send
    boundary = 'clad_outer'
    value_type = min
  []
  [min_T_fluid]
    type = ElementExtremeValue
    variable = T_fluid
    value_type = min
  []
  [heat_source_integral]
    type = ElementIntegralVariablePostprocessor
    variable = heat_source
    block = 'fuel'
  []
[]

[Outputs]
  exodus = true
  csv = true
[]