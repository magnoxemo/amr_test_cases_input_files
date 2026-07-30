!include mesh_base.i

[Mesh]
  [fuel_pin]
    num_sectors_per_side := '2 2 2 2'
    ring_intervals := '1 1 1'
  []
  [guide_tube]
    num_sectors_per_side := '2 2 2 2'
    ring_intervals := '2 1'
  []
  [extrude]
    heights := '${fparse active_core_height * num_bottom_layers / num_neutronics_axial_layers} ${fparse active_core_height * num_middle_layers / num_neutronics_axial_layers} ${fparse active_core_height * num_top_layers / num_neutronics_axial_layers}'

    num_layers := '${num_bottom_layers} ${num_middle_layers} ${num_top_layers}'
    subdomain_swaps:='1 11 2 21 3 31;
                      1 12 2 22 3 32;
                      1 13 2 23 3 33'
  []
  [rename]
    type = RenameBlockGenerator
    input = extrude
    old_block = '11 12 13 21 22 23 31 32 33 4'
    new_block = 'fuel_bottom fuel_middle fuel_top gas_gap_bottom gas_gap_middle gas_gap_top clad_bottom clad_middle clad_top water'
  []
[]
