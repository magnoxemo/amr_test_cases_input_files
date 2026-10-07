!include  ../mesh_neutronics.i

[Mesh]
  [refine_mesh]
    type = RefineBlockGenerator
    block = 'fuel gap clad water'
    input = rename
    refinement = 2
  []
  final_generator := refine_mesh
[]
