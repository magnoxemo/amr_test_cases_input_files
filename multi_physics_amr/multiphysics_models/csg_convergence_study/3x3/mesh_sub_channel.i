!include ../../common.i

[Mesh]
  [assembly]
    type = SCMDetailedQuadAssemblyMeshGenerator
    nx = 4
    ny = 4
    n_cells = ${n_axial_layers}
    pitch = ${pitch}
    pin_diameter = ${fparse clad_or*2}
    side_gap = ${fparse pitch/2 -clad_or }
    heated_length = ${active_height}
  []
[]
