[Mesh]
  [file_mesh]
    type = FileMeshGenerator
    file = ../mesh_neutronics_in.e
  []
  [refine_fuel]
    type=RefineBlockGenerator
    input=file_mesh
    block='fuel_bottom fuel_middle fuel_top gas_gap_bottom gas_gap_middle gas_gap_top clad_bottom clad_middle clad_top water al_clad boron_carbide'
    refinement=0
  []
  length_unit = 'm'
[]