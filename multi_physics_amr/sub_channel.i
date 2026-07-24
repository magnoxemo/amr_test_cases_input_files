# Subchannel operating conditions
T_in_scm     = ${coolant_inlet_temperature}        # from common.i
P_out_scm    = ${coolant_outlet_pressure}          # from common.i

[FluidProperties]
  [water]
    type = Water97FluidProperties
    T_initial_guess = ${T_in_scm}
    p_initial_guess = ${P_out_scm}
  []
[]



[QuadSubChannelMesh]
  [subchannel]
    type = SCMQuadAssemblyMeshGenerator
    nx = 4   # place_holder
    ny = 4   # place_holder
    n_cells = ${num_heat_axial_layers}
    pitch = ${pin_pitch}
    pin_diameter = ${fparse cladding_outer_radius * 2}
    side_gap = ${fparse side_gap}
    heated_length = ${active_core_height}
  []
[]


[AuxVariables]
  [mdot]
    block = subchannel
  []
  [SumWij]
    block = subchannel
  []
  [P]
    block = subchannel
  []
  [DP]
    block = subchannel
  []
  [h]
    block = subchannel
  []
  [T]
    block = subchannel
  []
  [Tpin]
    block = fuel_pins
  []
  [rho]
    block = subchannel
  []
  [mu]
    block = subchannel
  []
  [S]
    block = subchannel
  []
  [w_perim]
    block = subchannel
  []
  [q_prime]
    block = fuel_pins
  []
  [Dpin]
    block = fuel_pins
  []
[]


[SubChannel]
  type = QuadSubChannel1PhaseProblem
  fp = water
  n_blocks = ${num_heat_axial_layers}
  compute_density = true
  compute_viscosity = true
  compute_power = true
  P_out = ${P_out_scm}
  implicit = false
  verbose_subchannel = true
  interpolation_scheme = exponential
  friction_closure = 'MATRA'
  mixing_closure = 'constant_beta'
  pin_HTC_closure = 'Dittus-Boelter'
  full_output = true
[]

[SCMClosures]
  [MATRA]
    type = SCMFrictionMATRA
  []
  [Dittus-Boelter]
    type = SCMHTCDittusBoelter
    correction_factor = none
  []
  [constant_beta]
    type = SCMMixingConstantBeta
    beta = 0.08
    CT = 2.6
  []
[]



[ICs]
  [T_ic]
    type = ConstantIC
    variable = T
    value = ${T_in_scm}
  []
  [q_prime_IC]
    type = ConstantIC
    variable = q_prime
    value = 0.0
  []
  [P_ic]
    type = ConstantIC
    variable = P
    value = 0.0
  []
  [Dpin_ic]
    type = ConstantIC
    variable = Dpin
    value = ${fparse cladding_outer_radius * 2}
  []
  [Viscosity_ic]
    type = ViscosityIC
    variable = mu
    p = ${P_out_scm}
    T = T
    fp = water
  []
  [rho_ic]
    type = RhoFromPressureTemperatureIC
    variable = rho
    p = ${P_out_scm}
    T = T
    fp = water
  []
  [h_ic]
    type = SpecificEnthalpyFromPressureTemperatureIC
    variable = h
    p = ${P_out_scm}
    T = T
    fp = water
  []
  [mdot_ic]
    type = ConstantIC
    variable = mdot
    value = 0.0
  []
[]

[AuxKernels]
  [T_in_bc]
    type = ConstantAux
    variable = T
    boundary = inlet
    value = ${T_in_scm}
    execute_on = 'timestep_begin'
  []
  [mdot_in_bc]
    type = SCMMassFlowRateAux
    variable = mdot
    boundary = inlet
    area = S
    mass_flux = ${mass_flux}
    execute_on = 'timestep_begin'
  []
[]

[MultiApps]
  [viz]
    type = FullSolveMultiApp
    input_files = subchannel_viz.i
    execute_on = 'final'
  []
[]

[Transfers]
  [T_to_viz]
    type = SCMSolutionTransfer
    to_multi_app = viz
    variable = 'T mdot h rho mu P Dpin q_prime'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  line_search = basic
  start_time = 0
  end_time = .2
  dt = 0.1

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-4
  nl_max_its = 50
[]

[Outputs]
  
  exodus = true
[]