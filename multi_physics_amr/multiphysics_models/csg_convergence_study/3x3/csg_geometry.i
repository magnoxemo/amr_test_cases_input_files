# Pin geometry of the CSG model (model.xml, in m). Overrides common.i so the
# neutronics mesh, heat conduction mesh and subchannel all match the CSG cells.
# setup_uniform_refinement.py checks these against every model.xml.
pin_pitch             := 1.26e-2
fuel_outer_radius     := 0.4095e-2
cladding_inner_radius := 0.418e-2
cladding_outer_radius := 0.475e-2
