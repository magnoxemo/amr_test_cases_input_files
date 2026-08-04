import openmc


pin_pitch_m               = 1.25984e-2   # m
fuel_outer_radius_m       = 0.39218e-2   # m
cladding_inner_radius_m   = 0.40005e-2   # m
cladding_outer_radius_m   = 0.45720e-2   # m
guide_tube_inner_radius_m = 0.56134e-2   # m
guide_tube_outer_radius_m = 0.60198e-2   # m
active_core_height_m      = 3.8556       # m


M_TO_CM = 100.0
pin_pitch               = pin_pitch_m               * M_TO_CM
fuel_outer_radius       = fuel_outer_radius_m       * M_TO_CM
cladding_inner_radius   = cladding_inner_radius_m   * M_TO_CM
cladding_outer_radius   = cladding_outer_radius_m   * M_TO_CM
guide_tube_inner_radius = guide_tube_inner_radius_m * M_TO_CM
guide_tube_outer_radius = guide_tube_outer_radius_m * M_TO_CM
active_core_height      = active_core_height_m      * M_TO_CM

LATTICE_DIM = 17


uo2 = openmc.Material(material_id=4, name="UO2")
uo2.set_density('atom/cm3', 6.9334999999e+22)
uo2.add_nuclide('U235', 0.012475661642748973, 'ao')
uo2.add_nuclide('U238', 0.32090574745799383, 'ao')
uo2.add_nuclide('O16',  0.6650324386240716, 'ao')
uo2.add_nuclide('O17',  0.0002526484459508185, 'ao')
uo2.add_nuclide('O18',  0.0013335038292348741, 'ao')
uo2.temperature = 700
uo2.depletable = True

water = openmc.Material(material_id=6, name="H2O")
water.set_density('atom/cm3', 1.005278e+23)
water.add_nuclide('H1',  0.6663785084324934, 'ao')
water.add_nuclide('H2',  0.00010379795439669424, 'ao')
water.add_nuclide('O16', 0.3324482391935365, 'ao')
water.add_nuclide('O17', 0.00012629839706031565, 'ao')
water.add_nuclide('O18', 0.0006666156028481673, 'ao')
water.add_nuclide('B10', 5.4810311177604604e-05, 'ao')
water.add_nuclide('B11', 0.0002217301084874035, 'ao')
water.temperature = 560

zirc = openmc.Material(material_id=8, name="ZR_C")
zirc.set_density('atom/cm3', 4.299999999999999e+22)
zirc.add_nuclide('Zr90', 0.5145, 'ao')
zirc.add_nuclide('Zr91', 0.1122, 'ao')
zirc.add_nuclide('Zr92', 0.1715, 'ao')
zirc.add_nuclide('Zr94', 0.1738, 'ao')
zirc.add_nuclide('Zr96', 0.028, 'ao')
zirc.temperature = 700


helium = openmc.Material(name="He_Gap")
helium.set_density('g/cm3', 0.0015981)
helium.add_nuclide('He4', 1.0, 'ao')
helium.temperature = 600


materials = openmc.Materials([uo2, water, zirc, helium])


# ---------------------------------------------------------------------
fuel_or   = openmc.ZCylinder(r=fuel_outer_radius)
clad_ir   = openmc.ZCylinder(r=cladding_inner_radius)   # surface "2" equivalent
clad_or   = openmc.ZCylinder(r=cladding_outer_radius)   # surface "3" equivalent

# square water "bounding box" around the pin, half-pitch on each side
half_pitch = pin_pitch / 2.0
min_x = openmc.XPlane(x0=-half_pitch, name="minimum x")
max_x = openmc.XPlane(x0= half_pitch, name="maximum x")
min_y = openmc.YPlane(y0=-half_pitch, name="minimum y")
max_y = openmc.YPlane(y0= half_pitch, name="maximum y")


fuel_cell  = openmc.Cell(cell_id=13, name="UO2 Fuel Pin", fill=uo2,
                          region=-fuel_or)
gap_cell   = openmc.Cell(cell_id=14, name="Pin Gap", fill=helium, region=+fuel_or & -clad_ir)
clad_cell  = openmc.Cell(cell_id=15, name="Pin Zr Clad", fill=zirc,
                          region=+clad_ir & -clad_or)
water_cell = openmc.Cell(cell_id=16, name="Pin Water Bounding Box", fill=water,
                          region=+clad_or & +min_x & -max_x & +min_y & -max_y)

pin_universe = openmc.Universe(universe_id=4, name="pincell",
                                cells=[fuel_cell, gap_cell, clad_cell, water_cell])

guide_ir = openmc.ZCylinder(r=guide_tube_inner_radius)
guide_or = openmc.ZCylinder(r=guide_tube_outer_radius)

gt_water_center = openmc.Cell(cell_id=17, name="Guide Tube Water", fill=water,
                               region=-guide_ir)
gt_clad         = openmc.Cell(cell_id=18, name="Guide Tube Clad", fill=zirc,
                               region=+guide_ir & -guide_or)
gt_water_box    = openmc.Cell(cell_id=19, name="Guide Tube Water Bounding Box", fill=water,
                               region=+guide_or & +min_x & -max_x & +min_y & -max_y)

guide_tube_universe = openmc.Universe(universe_id=5, name="guide_tube",
                                       cells=[gt_water_center, gt_clad, gt_water_box])

guide_tube_pattern = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]
assert len(guide_tube_pattern) == LATTICE_DIM
assert all(len(row) == LATTICE_DIM for row in guide_tube_pattern)

lattice = openmc.RectLattice(lattice_id=9, name="Fuel Assembly")
lattice.pitch = (pin_pitch, pin_pitch)
lattice.lower_left = (-LATTICE_DIM / 2.0 * pin_pitch, -LATTICE_DIM / 2.0 * pin_pitch)
lattice.universes = [
    [guide_tube_universe if cell else pin_universe for cell in row]
    for row in guide_tube_pattern
]


TOP_PAD = 0.0   # cm of extra reflector above active_core_height, if any

assembly_half = LATTICE_DIM / 2.0 * pin_pitch
lattice_min_x = openmc.XPlane(x0=-assembly_half, boundary_type='reflective')
lattice_max_x = openmc.XPlane(x0= assembly_half, boundary_type='reflective')
lattice_min_y = openmc.YPlane(y0=-assembly_half, boundary_type='reflective')
lattice_max_y = openmc.YPlane(y0= assembly_half, boundary_type='reflective')

z_bottom = openmc.ZPlane(z0=0.0, boundary_type='reflective')
z_top    = openmc.ZPlane(z0=active_core_height + TOP_PAD, boundary_type='vacuum')

root_cell = openmc.Cell(cell_id=27, name="17x17 Fuel Lattice Cell", fill=lattice,
                         region=+lattice_min_x & -lattice_max_x &
                                +lattice_min_y & -lattice_max_y &
                                +z_bottom & -z_top)

root_universe = openmc.Universe(universe_id=0, cells=[root_cell])
geometry = openmc.Geometry(root_universe)

settings = openmc.Settings()
settings.run_mode = 'eigenvalue'
settings.particles = 50000
settings.batches = 1000
settings.inactive = 200

settings.temperature = {
    'default': 293.15,
    'method': 'interpolation',
    'range': (293.15, 3000.0),
    'tolerance': 1000.0,
}

bounds = [-assembly_half, -assembly_half, 0.0,
           assembly_half,  assembly_half, active_core_height]
uniform_dist = openmc.stats.Box(bounds[:3], bounds[3:])
settings.source = openmc.IndependentSource(space=uniform_dist)


model = openmc.Model(geometry=geometry, materials=materials, settings=settings)
model.export_to_model_xml()