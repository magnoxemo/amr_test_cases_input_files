total_pins_in_this_model=9

!include ../../common.i
!include csg_geometry.i
assembly_th_power  = ${fparse  total_pins_in_this_model*power_per_fuel_pin}

!include ../../openmc.i


# The gap is coupled too: with straight-sided (refined) elements, thin slivers of
# the mesh gap fall inside the CSG fuel cells and vice versa, and Cardinal requires
# every cell to map to elements with the same feedback settings.
[Problem]
  power := ${fparse assembly_th_power}
  xml_directory=model.xml
  temperature_blocks := 'fuel gap clad water'
  # particles := 20000
[]

[Transfers]
  [solid_temperature_from_conduction]
    to_blocks := 'fuel gap clad'
  []
[]
