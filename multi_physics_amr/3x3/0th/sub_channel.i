!include ../../../sub_channel.i

[QuadSubChannelMesh]
  [sub_channel]
    nx := 4   
    ny := 4  
  []
[]

[ICs]
  [q_prime_IC]
    filename := '../power_profile.txt'    
  []

[]