!include ../../common.i
!include ../../solid.i

[Mesh]
  [load]
    type = FileMeshGenerator
    file = mesh_hc_in.e
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

  # [guide_tube_water]
  #     type = GenericConstantMaterial
  #     block = 'guide_tube_water'
  #     prop_names  = 'thermal_conductivity specific_heat density'
  #     prop_values = '0.6   4800   1000'
  # []

  # For cases where control rod is fully inserted there is no water in the guide tube.
  # So we just need to replace the guide water with B4C

  [boron_carbide]
      type = GenericConstantMaterial
      block = 'boron_carbide'
      prop_names  = 'thermal_conductivity specific_heat density'
      prop_values = '18   2700   2520'
  []
[]

[UserObjects]
  [q_prime_uo]
    points_file := '../pincenters.txt'
  []
[]
