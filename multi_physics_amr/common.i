#================= common parameters =================
#================= geometry ==========================
pitch      = 1.25984e-2 # m
fuel_or    = 0.39218e-2 # m
clad_ir    = 0.40005e-2 # m
clad_or    = 0.45720e-2 # m
gt_ir      = 0.56134e-2 # m
gt_or      = 0.60198e-2 # m
ba_or      = 0.56134e-2 # m
pi         = 3.1416


#================= 3x3 subchannel geometry ==============
n_pins_x        = 3
n_pins          = 9            # 3x3, all heated
n_gt            = 0            # no guide tubes in this bundle
n_axial_layers  = 150   
       

#============== neutronics ==========================
number_of_axial_layer_neutronics = 20
n_bottom                         = 7
n_middle                         = 6
n_top                            = 7
active_height                    = 0.9278 # m


inlet_temperature     = 560        # Kelvin
pressure_outlet       = 1.57e7     # Pa
mass_flow_rate        = 0.20       # kg/s 
assembly_th_power     = 3e6        # W
initial_vel           = 0.33       # m/sec
