#================= Common Parameters =================

pi = 3.1416


#================= Geometry ==========================

pin_pitch                 = 1.25984e-2                     # m
fuel_outer_radius         = 0.39218e-2            # m
cladding_inner_radius     = 0.40005e-2        # m
cladding_outer_radius     = 0.45720e-2        # m
guide_tube_inner_radius   = 0.3400e-2     # m
guide_tube_outer_radius   = 0.54e-2      # m

burnable_absorber_outer_radius = 0.56134e-2   # m


#================= Neutronics ========================

num_neutronics_axial_layers = 20
num_bottom_layers  = 7
num_middle_layers  = 6
num_top_layers     = 7
active_core_height = 1.9278               # m


#================= Heat Conduction ===================

axial_layer_refinement = 3
num_heat_axial_layers = ${fparse axial_layer_refinement * num_neutronics_axial_layers}


#================= SCM Constant Parameters ===========
coolant_inlet_temperature = 560           # K
coolant_outlet_pressure = 1.57e7          # Pa


#================= Power Profile =====================

total_reactor_power = 3000e6              # 3000 MW thermal
num_assemblies = 121
assembly_rows = 17
assembly_columns = 17

pins_per_assembly = ${fparse assembly_rows * assembly_columns}
guide_tubes_per_assembly = 28             # Standard 17×17 PWR assembly
fuel_pins_per_assembly = ${fparse pins_per_assembly - guide_tubes_per_assembly}
total_fuel_pins = ${fparse fuel_pins_per_assembly * num_assemblies}
power_per_fuel_pin = ${fparse total_reactor_power / total_fuel_pins}



#================= Subchannel Flow ===================

mass_flux = 3800  #kg/sec/m^2 # google search. I need citation for this


#================= Duct/Assembly Envelope =============
side_gap = 0.00095  # this is from moose example 
