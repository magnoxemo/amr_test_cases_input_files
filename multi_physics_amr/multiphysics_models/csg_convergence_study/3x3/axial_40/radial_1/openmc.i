!include ../../openmc.i

[Mesh]
  [file_mesh]
    type = FileMeshGenerator
    file = mesh_neutronics_in.e
  []
  length_unit = 'm'
[]
