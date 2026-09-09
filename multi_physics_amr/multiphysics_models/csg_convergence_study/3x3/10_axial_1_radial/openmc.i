!include ../openmc.i

[Mesh]
  [file_mesh]
    type = FileMeshGenerator
    file = mesh_neutronics_in.e
  []
  length_unit = 'm'
[]

[Problem]
  particles := 50000
[]

[MultiApps]
  [solid]
    input_files := solid.i
  []
  [sub_channel]
    input_files := sub_channel.i
  []
[]
