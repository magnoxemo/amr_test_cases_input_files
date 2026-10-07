!include ../openmc.i

[Mesh]
  [file_mesh]
    file := mesh_neutronics_in.e
  []
[]

[Problem]
  xml_directory := ../model.xml
[]
