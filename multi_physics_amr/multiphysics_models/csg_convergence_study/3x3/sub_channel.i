!include ../../common.i
!include ../../sub_channel.i 

assembly_th_power= ${fparse 9 * power_per_fuel_pin}

[QuadSubChannelMesh]
  [subchannel]
    nx :=4
    ny :=4
  []
[]