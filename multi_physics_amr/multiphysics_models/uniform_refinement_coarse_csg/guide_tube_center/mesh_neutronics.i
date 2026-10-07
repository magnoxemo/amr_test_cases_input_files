!include  ../../mesh_base.i

[Mesh]
  [assembly]
    inputs := 'fuel_pin guide_tube'
    pattern :='0 0 0;
               0 1 0;
               0 0 0'
  []
  [rename]
    type = RenameBlockGenerator
    input = extrude
    old_block = '1 2 3 4'
    new_block = 'fuel gas clad water'
  []
[]

