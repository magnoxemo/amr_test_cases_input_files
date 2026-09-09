
!include ../../common.i
!include ../../solid.i

[Mesh]
  [load]
    type = FileMeshGenerator
    file = mesh_hc_in.e
  []
  length_unit = 'm'
[]

[UserObjects]
  [q_prime_uo]
    points_file := 'pincenters.txt'
  []
[]

