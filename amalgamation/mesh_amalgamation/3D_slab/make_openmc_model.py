import numpy as np
import openmc
import os
from ware_house.materials import material_dict, make_materials
from ware_house.settings import simulation_settings
from ware_house.argument_parser import argument_parser
from ware_house.geomtery import make_box

os.environ["OPENMC_CROSS_SECTIONS"] = "/home/ebny_walid/endfb-viii.0-hdf5/cross_sections.xml"


def find_material_by_xp_pos(x, args):
    if x / abs(args.x_max - args.x_min) < args.fuel_percentage:
        return "fuel"
    return "graphite"


def density_by_x_pos(x, args):
    return 10*np.exp(-abs(x / (args.x_max - args.x_min)))


def make_model():
    args = argument_parser()
    boundary_conditions_1 = ['reflective', 'transmission',  # x: left, right
                             'reflective', 'reflective',  # y
                             'reflective', 'reflective']
    boundary_conditions_2 = ['transmission', 'transmission',  # x: left, right
                             'reflective', 'reflective',  # y
                             'reflective', 'reflective']
    boundary_conditions_3 = ['transmission', 'reflective',  # x: left, right
                             'reflective', 'reflective',  # y
                             'reflective', 'reflective']
    x_pos = np.linspace(args.x_min, args.x_max, args.Nx+1)
    cells = []
    materials = []
    for i in range(args.Nx):

        if find_material_by_xp_pos(x_pos[i], args) == "fuel":
            materials.append(
                make_materials(material_dict['UO2'], percent_type='ao', density=density_by_x_pos(x_pos[i], args)))
        else:
            materials.append(make_materials(material_dict['Graphite'], percent_type='ao'))

        if i == 0:
            box = make_box(x_dim=[x_pos[i], x_pos[i + 1]],
                           y_dim=[args.y_min, args.y_max],
                           z_dim=[args.z_min, args.z_max],
                           boundary_conditions=boundary_conditions_1)
        elif i == (args.Nx - 1):
            box = make_box(x_dim=[x_pos[i], x_pos[i + 1]],
                           y_dim=[args.y_min, args.y_max],
                           z_dim=[args.z_min, args.z_max],
                           boundary_conditions=boundary_conditions_3)
        else:
            box = make_box(x_dim=[x_pos[i], x_pos[i + 1]],
                           y_dim=[args.y_min, args.y_max],
                           z_dim=[args.z_min, args.z_max],
                           boundary_conditions=boundary_conditions_2)

        cells.append(openmc.Cell(region=box, fill=materials[-1]))

    model = openmc.Model()
    model.geometry = openmc.Geometry(root=openmc.Universe(cells=cells))
    model.materials = openmc.Materials(materials=materials)
    model.settings = simulation_settings(args, space_dist=openmc.stats.Box(
        lower_left=(args.x_min, args.y_min, args.z_min),
        upper_right=(args.x_max, args.y_max, args.z_max)))

    return model


if __name__ == "__main__":
    make_model().run(geometry_debug=True)
