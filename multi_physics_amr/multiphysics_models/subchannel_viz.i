!include common.i

[QuadSubChannelMesh]
  [sub_channel]
    type = SCMDetailedQuadAssemblyMeshGenerator
    nx = 4
    ny = 4
    n_cells = ${num_heat_axial_layers}
    pitch = ${pin_pitch}
    pin_diameter = ${fparse cladding_outer_radius * 2}
    side_gap = ${fparse pin_pitch / 2 - cladding_outer_radius}
    heated_length = ${active_core_height}
  []
[]

[AuxVariables]
    [T]
    []
    [mdot]
    []
    [h]
    []
    [rho]
    []
    [mu]
    []
    [P]
    []
    [Dpin]
    []
    [q_prime]
    []
    [Tpin]
    []
[]
[Postprocessors]
  [avg_coolant_T]
    type = ElementAverageValue
    variable = T
    block='subchannel'
  []
  [max_T_fluid]
    type = ElementExtremeValue
    variable = T
    value_type = max
    block='subchannel'
  []
  [min_T_fluid]
    type = ElementExtremeValue
    variable = T
    value_type = min
    block='subchannel'
  []
[]
[Problem]
  type = NoSolveProblem            # transfer-only
[]

[Executioner]
  type = Steady
[]

[Outputs]
  exodus = true
  csv=true
  file_base = subchannel_detailed
[]