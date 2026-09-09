total_pins_in_this_model=9
!include ../../common.i
assembly_th_power  = ${fparse  total_pins_in_this_model*power_per_fuel_pin}
!include ../../openmc.i


[Problem]
  power := ${fparse assembly_th_power}
  xml_directory=model.xml
  # particles := 20000
[]

