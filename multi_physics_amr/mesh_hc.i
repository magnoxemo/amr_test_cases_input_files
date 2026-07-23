!include ../common.i

[Mesh]
  [fuel_pin]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    num_sectors_per_side = '4 4 4 4'
    polygon_size = ${fparse pitch / 2.0}
    ring_radii = '${fuel_or} ${clad_ir} ${clad_or}'
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
    heights = '${active_height}'
    num_layers = '${n_axial_layers}'
    direction = '0 0 1'
  []

  # [shift]
  #   type = TransformGenerator
  #   input = extrude
  #   transform = TRANSLATE
  #   vector_value = '0 0 ${fparse -active_height / 2.0}'
  # []

  [clad_outer_sideset]
    type = SideSetsBetweenSubdomainsGenerator
    input = extrude
    primary_block = '3'
    paired_block = '4'
    new_boundary = 'clad_outer'
  []

  [delete_water]
    type = BlockDeletionGenerator
    input = clad_outer_sideset
    block = '4'
  []
  
  [rename]
    type = RenameBlockGenerator
    input = delete_water
    old_block = '1 2 3'
    new_block = 'fuel gap clad'
  []
[]