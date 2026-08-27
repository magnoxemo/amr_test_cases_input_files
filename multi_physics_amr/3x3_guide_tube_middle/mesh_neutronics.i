!include  ../mesh_neutronics.i

[Mesh]

  [guide_tube]
    ring_block_names := 'guide_tube_water al_clad' # Control rod inserted
  []

  [assembly]
    inputs:="fuel_pin guide_tube"
    pattern:='0 0 0;
              0 1 0;
              0 0 0'
  []
[]
