!include common.i

[Mesh]
  [fuel_pin]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    num_sectors_per_side = '4 4 4 4'
    polygon_size = ${fparse pin_pitch / 2.0}
    ring_radii = '${fuel_outer_radius} ${cladding_inner_radius} ${cladding_outer_radius}'
    ring_intervals = '6 1 2'
    ring_block_ids = '1 2 3'
    background_block_ids = '4'
    quad_center_elements = true
    preserve_volumes = true
    flat_side_up = true
  []
  [assembly]
    type = PatternedCartesianMeshGenerator
    inputs = 'fuel_pin'
    pattern = '0 0 0;
               0 0 0;
               0 0 0'
    pattern_boundary = 'none'
  []
  [extrude]
    type = AdvancedExtruderGenerator
    input = assembly
    heights = '${fparse active_core_height}'
    num_layers = '${num_heat_axial_layers}'
    direction = '0 0 1'
  []
[]