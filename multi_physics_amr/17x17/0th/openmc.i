# ========================= specific to this model ==========================
total_pins_in_this_model=289
!include ../../common.i

assembly_th_power  = ${fparse  total_pins_in_this_model*power_per_fuel_pin}

!include ../../openmc.i


[Mesh]
  [file_mesh]
    type = FileMeshGenerator
    file = openmc_mesh_in.e
  []
   length_unit = 'm'
[]


[Problem]
  power := ${fparse assembly_th_power}
  xml_directory=../model.xml
  particles := 500000
  # When control rod isn't inserted
  # temperature_blocks:= 'fuel_bottom fuel_middle fuel_top gas_gap_bottom gas_gap_middle gas_gap_top clad_bottom clad_middle clad_top al_clad guide_tube_water water'
  
  # When control rod is inserted 
  temperature_blocks:= 'fuel_bottom fuel_middle fuel_top gas_gap_bottom gas_gap_middle gas_gap_top clad_bottom clad_middle clad_top al_clad boron_carbide water'
  density_blocks:= 'water'
[]


[Transfers]
  [solid_temperature_from_conduction]
    # to_blocks := 'fuel_bottom fuel_middle fuel_top gas_gap_bottom gas_gap_middle gas_gap_top clad_bottom clad_middle clad_top al_clad guide_tube_water'

    # When control rod is inserted 
    to_blocks := 'fuel_bottom fuel_middle fuel_top gas_gap_bottom gas_gap_middle gas_gap_top clad_bottom clad_middle clad_top al_clad boron_carbide'
  []
[]


[MultiApps]
  [solid]
    input_files := solid.i
  []
  [sub_channel]
    input_files := sub_channel.i
  []
[]