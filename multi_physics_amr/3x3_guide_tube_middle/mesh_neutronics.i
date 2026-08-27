!include  ../mesh_neutronics.i

[Mesh]

  [guide_tube]
    ring_block_names := 'boron_carbide al_clad' # Control rod inserted 
  []

  [assembly]
    inputs:="fuel_pin guide_tube"
    pattern:='0 0 0;
              0 1 0;
              0 0 0'
  []
[]