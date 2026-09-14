!include ../mesh_hc.i

[Mesh]
    [refine_mesh]
        type=RefineBlockGenerator
        block='fuel clad gap'
        input=rename
        refinement=0
    []
    final_generator:=refine_mesh
[]
