!include common_input.i

[Mesh]
  [Pin]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    num_sectors_per_side = '${NUM_SECTORS} ${NUM_SECTORS} ${NUM_SECTORS} ${NUM_SECTORS}'
    ring_radii = '${r_fuel}'
    ring_intervals = '${FUEL_RADIAL_DIVISIONS}'
    polygon_size = ${fparse pitch / 2.0}

    ring_block_ids = '0'
    ring_block_names = 'fuel_center'
    background_block_ids = '1'
    background_block_names = 'water'
    background_intervals = ${BACKGROUND_DIVISIONS}

    flat_side_up = true
    quad_center_elements = false
    preserve_volumes = true
    create_outward_interface_boundaries = false
  []
  [Pin_3D]
    type = AdvancedExtruderGenerator
    input = 'Pin'
    heights = '${fparse core_height}'
    num_layers = '${AXIAL_DIVISIONS}'
    direction = '0.0 0.0 1.0'

  []
  [To_Origin]
    type = TransformGenerator
    input = 'Pin_3D'
    transform = TRANSLATE_CENTER_ORIGIN
  []
  [generated_mesh]
    type = TransformGenerator
    input = 'To_Origin'
    transform = TRANSLATE
    vector_value = '0.0 0.0 ${fparse core_height / 2.0}'
  []

[]
