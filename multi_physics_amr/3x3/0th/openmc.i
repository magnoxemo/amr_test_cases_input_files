# ==========================================================
# openmc.i 
#  |-- solid.i  
#       |-- sub_channel.i 
# ==========================================================

# ========================= specific to this model ==========================
total_pins_in_this_model=9
!include ../../common.i

assembly_th_power  = ${fparse  total_pins_in_this_model*power_per_fuel_pin}

!include ../../openmc.i
[Mesh]
  [file_mesh]
    type = FileMeshGenerator
    file = ../mesh_neutronics_in.e
  []
   length_unit = 'm'
[]




[Problem]
  power := ${fparse assembly_th_power}
  xml_directory=../model.xml
  particles := 2000
[]


[MultiApps]
  [solid]
    input_files := solid.i
  []
  [sub_channel]
    input_files := sub_channel.i
  []
[]