!include common.i

[QuadSubChannelMesh]
  [sub_channel]
    type = SCMDetailedQuadAssemblyMeshGenerator
    nx = 3
    ny = 3
    n_cells = ${n_axial_layers}
    pitch = ${pitch}
    pin_diameter = ${fparse clad_or * 2}
    side_gap = ${fparse pitch / 2 - clad_or}
    heated_length = ${active_height}
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