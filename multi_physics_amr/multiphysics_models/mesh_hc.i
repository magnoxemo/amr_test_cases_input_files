!include mesh_base.i

[Mesh]
  [fuel_pin]
    quad_center_elements := true
    ring_block_ids := '1 2 3'

  []

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
  final_generator=rename
[]