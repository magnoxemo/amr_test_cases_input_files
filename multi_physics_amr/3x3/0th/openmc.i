# ==========================================================
# openmc.i 
#  |-- solid.i  
#       |-- sub_channel.i 
# ==========================================================
!include ../mesh_neutronics.i

[Mesh]
  [load]
    type = FileMeshGenerator
    file = mesh_neutronics_in.e
  []
   length_unit = 'm'
[]