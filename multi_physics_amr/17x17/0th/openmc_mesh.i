[Mesh]
  [file_mesh]
    type = FileMeshGenerator
    file = ../mesh_neutronics_in.e
  []
  # [refine_fuel]
  #   type=RefineBlockGenerator
  #   input=file_mesh
  #   block='fuel_bottom fuel_middle fuel_top'
  #   refinement=1
  # []
   length_unit = 'm'
[]