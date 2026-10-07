!include  ../mesh_neutronics.i

[Mesh]
    [refine_mesh]
        type=RefineBlockGenerator
        block='fuel clad water gas'
        input=rename
        refinement=1
    []
    final_generator:=refine_mesh
[]
