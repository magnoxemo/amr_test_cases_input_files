!include  ../../mesh_base.i
!include csg_geometry.i

[Mesh]
  # 8 sectors per side keeps the polygonal clad outer surface within ~0.0016 cm of
  # the CSG cylinder, so even 3rd-refinement clad elements stay out of the CSG water
  # cell (clad is T-coupled, water T+rho; Cardinal forbids mixing within a cell)
  [fuel_pin]
    num_sectors_per_side := '8 8 8 8'
  []
  [assembly]
    pattern:='0 0 0;
              0 0 0;
              0 0 0'
  []
  [rename]
    type = RenameBlockGenerator
    input = extrude
    old_block = '1 2 3 4'
    new_block = 'fuel gap clad water'
  []
[]

