# Subchannel operating conditions
T_in_scm     = ${coolant_inlet_temperature}        # from common.i
P_out_scm    = ${coolant_outlet_pressure}          # from common.i




[AuxVariables]
  [q_prime]
    block = fuel_pins
  []
  [Tpin]
    block = fuel_pins
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


[ICs]
  [T_IC]
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
[]


[FluidProperties]
  [water]
    type = Water97FluidProperties
    T_initial_guess = ${T_in_scm}
    p_initial_guess = ${P_out_scm}
  []
[]


[SubChannel]
  type = QuadSubChannel1PhaseProblem
  fp = water
  n_blocks = 1
  implicit = true
  compute_density = true
  compute_viscosity = true
  compute_power = true
  P_out = ${P_out_scm}
  P_tol = 1.0e-5
  T_tol = 1.0e-5
  verbose_subchannel = true
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
    beta = 0.006
    CT = 2.6
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
    execute_on = 'timestep_end'
  []
[]

[Transfers]
  [T_to_viz]
    type = SCMSolutionTransfer
    to_multi_app = viz
    variable = 'T mdot h rho mu P'
  []

  [pin_transfer]
    type = SCMPinSolutionTransfer
    to_multi_app = viz
    variable = 'q_prime'
  []
[]

[Executioner]
    type = Transient
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre boomeramg'
    num_steps = 1
[]

[Outputs]
  csv= true
  exodus = true
[]