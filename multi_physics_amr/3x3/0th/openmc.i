# ==========================================================
# openmc.i 
#  |-- solid.i  
#       |-- sub_channel.i 
# ==========================================================

!include ../scm_pparams.i

[Mesh]
  [load]
    type = FileMeshGenerator
    file = ../mesh_neutronics_in.e
  []
   length_unit = 'm'
[]


[Problem]
  power = ${fparse power}
[]
