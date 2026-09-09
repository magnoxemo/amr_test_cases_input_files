!include  ../mesh_neutronics.i

num_neutronics_axial_layers:=40
fuel_pin_rings=3

[Mesh]
  [fuel_pin]
    ring_intervals := '${fuel_pin_rings} 1 1'

  []
   [extrude]
    num_layers := '${num_neutronics_axial_layers}'
  []
    final_generator=rename
[]
