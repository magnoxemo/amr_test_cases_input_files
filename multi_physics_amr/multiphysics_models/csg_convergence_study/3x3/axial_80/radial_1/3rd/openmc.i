!include ../openmc.i

[Mesh]
  [file_mesh]
    file := mesh_neutronics_in.e
  []
[]

[Problem]
  xml_directory := ../model.xml
  particles := 100000
  batches := 20000
[]

# file parameters resolve relative to the input that sets them, so point the
# sub-apps at this level's inputs (and hence this level's mesh_hc_in.e)
[MultiApps]
  [solid]
    input_files := solid.i
  []
  [sub_channel]
    input_files := sub_channel.i
  []
[]
