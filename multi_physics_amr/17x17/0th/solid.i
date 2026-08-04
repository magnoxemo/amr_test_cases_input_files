
!include ../../common.i
!include ../../solid.i


[Mesh]
  [load]
    type = FileMeshGenerator
    file = ../mesh_hc_in.e
  []
  length_unit = 'm'
[]

[Materials]
  [al_clad]
    type = GenericConstantMaterial
    block = 'al_clad'
    prop_names  = 'thermal_conductivity specific_heat density'
    prop_values = '10   350   6500' 
  []
  [guide_tube_water]
      type = GenericConstantMaterial
      block = 'guide_tube_water guide_center'
      prop_names  = 'thermal_conductivity specific_heat density'
      prop_values = '0.6   4180   1000'
  []
[]

[UserObjects]
  [q_prime_uo]
    points_file := '../pincenters.txt'
  []
[]

