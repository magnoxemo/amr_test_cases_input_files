!include common.i

[QuadSubChannelMesh]
  [sub_channel]
    type = SCMDetailedQuadAssemblyMeshGenerator
    nx = 3
    ny = 3
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
[]

[Problem]
  type = NoSolveProblem            # transfer-only
[]

[Executioner]
  type = Steady
[]

[Outputs]
  exodus = true
  file_base = subchannel_detailed
[]