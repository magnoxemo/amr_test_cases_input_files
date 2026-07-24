
!include ../../common.i
!include ../../solid.i


[Mesh]
  [load]
    type = FileMeshGenerator
    file = ../mesh_hc_in.e
  []
  length_unit = 'm'
[]



[UserObjects]
  [layered_clad_T]
    num_layers := ${num_heat_axial_layers}
  []
[]

