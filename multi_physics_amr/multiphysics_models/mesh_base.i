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
    preserve_volumes = true
    flat_side_up = true
    create_outward_interface_boundaries = true
    quad_center_elements= true
  []

  [guide_tube]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    num_sectors_per_side = '4 4 4 4'
    ring_radii = '${guide_tube_inner_radius} ${guide_tube_outer_radius}'
    ring_intervals = '6 1'
    polygon_size = ${fparse pin_pitch / 2.0}
    ring_block_ids = '101 111'
    ring_block_names = 'guide_tube_water al_clad'
    background_block_ids = '4'
    background_block_names = 'water'
    flat_side_up = true
    create_outward_interface_boundaries = true
    quad_center_elements= true

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
