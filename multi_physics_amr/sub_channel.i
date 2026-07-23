!include common.i

# Subchannel operating conditions
mass_flux_in = 25000                       # kg/s-m^2 this is magic number. I need to calculate what should be the flow rate
T_in_scm     = ${inlet_temperature}        # from common.i
P_out_scm    = ${pressure_outlet}          # from common.i

[QuadSubChannelMesh]
  [sub_channel]
    type = SCMQuadAssemblyMeshGenerator
    nx = 4   # place_holder
    ny = 4   # place_holder
    n_cells = ${n_axial_layers}
    pitch = ${pitch}
    pin_diameter = ${fparse clad_or * 2}
    side_gap = ${fparse pitch / 2 - clad_or}
    heated_length = ${active_height}
  []
[]

[FluidProperties]
  [water]
    type = Water97FluidProperties
    T_initial_guess = ${inlet_temperature}
    p_initial_guess = ${pressure_outlet}
  []
[]

[SubChannel]
  type = QuadSubChannel1PhaseProblem
  fp = water
  n_blocks = ${n_axial_layers}
  P_tol = 1e-6
  T_tol = 1e-6
  full_output = true
  compute_density = true
  compute_viscosity = true
  compute_power = true
  P_out = ${P_out_scm}
  friction_closure = 'MATRA'
  mixing_closure = 'constant_beta'
  pin_HTC_closure = 'Dittus-Boelter'
[]

[SCMClosures]
  [MATRA]
    type = SCMFrictionMATRA
  []
  # controls the cross flow 
  [constant_beta]
    type = SCMMixingConstantBeta
    beta = 0.006
    CT = 2.0
  []
  [Dittus-Boelter]
    type = SCMHTCDittusBoelter
  []
[]

[ICs]
  [T_ic]
    type = ConstantIC
    variable = T
    value = ${T_in_scm}
  []
  [q_prime_IC]
    type = SCMQuadPowerIC
    variable = q_prime
    power = ${fparse assembly_th_power}
    filename = 'power_profile.txt'    # normalized axial shape
  []
  [P_ic]
    type = ConstantIC
    variable = P
    value = 0.0
  []
  [Dpin_ic]
    type = ConstantIC
    variable = Dpin
    value = ${fparse clad_or * 2}
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
    mass_flux = ${mass_flux_in}
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