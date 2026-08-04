!include ../../common.i
!include ../../sub_channel.i 

assembly_th_power= ${fparse 18*18* power_per_fuel_pin}

[QuadSubChannelMesh]
  [subchannel]
    nx :=18
    ny :=18
  []
[]

[ICs]
  [q_prime_IC]
    power := ${assembly_th_power}
    filename := '../power_profile.txt'   
  []
[]

[MultiApps]
  [viz]
    input_files := ../subchannel_viz.i
  []
[]