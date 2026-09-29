!include  ../../mesh_neutronics.i

num_neutronics_axial_layers:=80
fuel_pin_rings=1

[Mesh]
  [fuel_pin]
    ring_radii := '${fuel_outer_radius} ${cladding_inner_radius} ${cladding_outer_radius}'
    ring_intervals := '1 1 1'
    ring_block_ids := '1 2 3'
  []
   [extrude]
    num_layers := '${num_neutronics_axial_layers}'
  []
    final_generator=rename
[]
