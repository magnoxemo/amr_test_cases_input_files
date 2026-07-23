!include common.i

h_bottom = ${fparse active_height * n_bottom / number_of_axial_layer_neutronics}
h_middle = ${fparse active_height * n_middle / number_of_axial_layer_neutronics}
h_top    = ${fparse active_height * n_top    / number_of_axial_layer_neutronics}


[Mesh]
  [fuel_pin]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    num_sectors_per_side = '2 2 2 2'
    polygon_size = ${fparse pitch / 2.0}
    ring_radii = '${fuel_or} ${clad_or}'
    ring_intervals = '2 1'
    ring_block_ids = '1 3'
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
    generate_core_metadata = false
  []

  [extrude]
    type = AdvancedExtruderGenerator
    input = assembly
    heights    = '${h_bottom} ${h_middle} ${h_top}'
    num_layers = '${n_bottom} ${n_middle} ${n_top}'
    direction = '0 0 1'
    subdomain_swaps = '1 11;
                       1 12;
                       1 13'
  []
  # [shift]
  #   type = TransformGenerator
  #   input = extrude
  #   transform = TRANSLATE
  #   vector_value = '0 0 ${fparse -active_height / 2.0}'
  # []

  [rename]
    type = RenameBlockGenerator
    input = extrude
    old_block = '11            12            13         3      4'
    new_block = 'fuel_bottom   fuel_middle   fuel_top   clad   water'
  []
[]