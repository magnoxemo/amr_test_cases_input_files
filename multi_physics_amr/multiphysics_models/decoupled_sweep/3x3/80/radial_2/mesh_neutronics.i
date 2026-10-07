!include  ../../mesh_neutronics.i

num_neutronics_axial_layers:=80
fuel_pin_rings=2

[Mesh]
  [fuel_pin]
    ring_radii := '${fparse fuel_outer_radius*sqrt(1/fuel_pin_rings)} ${fuel_outer_radius} ${cladding_inner_radius} ${cladding_outer_radius}'
    ring_intervals := '1 1 1 1'
    ring_block_ids := '1 1 2 3'
  []
   [extrude]
    num_layers := '${num_neutronics_axial_layers}'
  []
    final_generator=rename
[]
