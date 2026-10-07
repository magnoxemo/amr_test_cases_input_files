!include  ../../mesh_neutronics.i

num_neutronics_axial_layers:=40
fuel_pin_rings=2

[Mesh]
  [fuel_pin]
    # model.xml fuel rings, gap and clad radii (m); pitch comes from ../../csg_geometry.i
    ring_radii := '0.002895602269 0.004095 0.00418 0.00475'
    ring_intervals := '1 1 1 1'
    ring_block_ids := '1 1 2 3'
  []
  [extrude]
    num_layers := '${num_neutronics_axial_layers}'
  []
  final_generator=rename
[]
