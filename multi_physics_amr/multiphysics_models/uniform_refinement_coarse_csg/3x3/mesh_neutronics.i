!include  ../../mesh_base.i

[Mesh]
  [assembly]
    pattern:='0 0 0;
              0 0 0;
              0 0 0'
  []
  [rename]
    type = RenameBlockGenerator
    input = extrude
    old_block = '1 2 3 4'
    new_block = 'fuel gas clad water'
  []
[]

