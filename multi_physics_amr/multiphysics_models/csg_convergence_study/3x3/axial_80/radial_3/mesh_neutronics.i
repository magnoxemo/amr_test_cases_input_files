!include  ../../mesh_neutronics.i

num_neutronics_axial_layers:=80
fuel_pin_rings=3

[Mesh]
  [fuel_pin]
    # model.xml fuel rings, gap and clad radii (m); pitch comes from ../../csg_geometry.i
    ring_radii := '0.002364249352 0.003343553499 0.004095 0.00418 0.00475'
    ring_intervals := '1 1 1 1 1'
    ring_block_ids := '1 1 1 2 3'
  []
  [extrude]
    num_layers := '${num_neutronics_axial_layers}'
  []
  final_generator=rename
[]
