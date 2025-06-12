import openmc
import numpy as np
import os
import common_input as pin_cell_param
from ware_house.materials import material_dict, make_materials
from ware_house.geomtery import make_box
from ware_house.argument_parser import argument_parser

os.environ["OPENMC_CROSS_SECTIONS"] = "/home/ebny_walid/endfb-viii.0-hdf5/cross_sections.xml"


def simulation_settings(shannon_entropy: bool):
    fuel_radius = pin_cell_param.r_fuel
    lower_left = (-fuel_radius, -fuel_radius, 0.0)
    upper_right = (fuel_radius, fuel_radius, pin_cell_param.core_height)

    setting = openmc.Settings()
    setting.source = openmc.IndependentSource(
        space=openmc.stats.Point((0, 0, pin_cell_param.core_height / 2)),
        angle=openmc.stats.Isotropic())
    setting.batches = 200
    setting.inactive = 40
    setting.particles = 20000

    if shannon_entropy:
        entropy_mesh = openmc.RegularMesh()
        entropy_mesh.lower_left = lower_left
        entropy_mesh.upper_right = upper_right
        entropy_mesh.dimension = (10, 10, 20)
        setting.entropy_mesh = entropy_mesh

    setting.temperature = {
        "default": 553.15,
        "method": "interpolation",
        "range": (290.0, 3000.0)
    }
    return setting


def axially_varying_density(z, pincell_height):
    return 1 + 10 * np.exp(-z / pincell_height)


def main(arguments):
    materials = []
    cells = []

    layers = np.linspace(0, pin_cell_param.core_height, pin_cell_param.AXIAL_DIVISIONS + 1)
    z_planes = [openmc.ZPlane(z0=z) for z in layers]
    z_planes[0].boundary_type = 'reflective'
    z_planes[-1].boundary_type = 'reflective'

    cyl = openmc.ZCylinder(r=pin_cell_param.r_fuel)

    for i in range(1, pin_cell_param.AXIAL_DIVISIONS+1):
        rho = axially_varying_density(layers[i], pin_cell_param.core_height)
        fuel_material = make_materials(material_dict["UO2"], percent_type='ao', density=rho)
        graphite_material = make_materials(material_dict['Graphite'], percent_type='ao', density=rho)

        fuel_cell = openmc.Cell(region=-cyl & +z_planes[i - 1] & -z_planes[i], fill=fuel_material)
        graphite_cell = openmc.Cell(region=+cyl & +z_planes[i - 1] & -z_planes[i], fill=graphite_material)

        cells.extend([fuel_cell, graphite_cell])
        materials.extend([fuel_material, graphite_material])

    half_pitch = pin_cell_param.pitch / 2
    bounding_cell = openmc.Cell(
        region=make_box(x_dim=[-half_pitch, half_pitch],
                        y_dim=[-half_pitch, half_pitch],
                        z_dim=[0, pin_cell_param.core_height],
                        boundary_conditions=["reflective"] * 6),
        fill=openmc.Universe(cells=cells)
    )

    model = openmc.Model(
        geometry=openmc.Geometry(openmc.Universe(cells=[bounding_cell])),
        materials=materials,
        settings=simulation_settings(arguments)
    )
    model.export_to_model_xml()


if __name__ == "__main__":
    main(argument_parser())
