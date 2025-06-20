import openmc
import openmc.stats
from ware_house.materials import material_dict, make_materials


def main():
    concrete = make_materials(material_dict['Heavy Concrete'], percent_type='ao')
    air = make_materials(material_dict['Air'], percent_type='ao')
    vacuum_region = -openmc.Sphere(r=5)
    concrete_region = +openmc.Sphere(r=5) & -openmc.Sphere(r=10, boundary_type='vacuum')

    vacuum_cell = openmc.Cell(region=vacuum_region, fill=air)
    concrete_cell = openmc.Cell(region=concrete_region, fill=concrete)

    return openmc.Materials([air, concrete]), openmc.Geometry([vacuum_cell, concrete_cell])


def simulation_settings():
    source = openmc.IndependentSource()
    source.space = openmc.stats.Point((0, 0, 0))
    source.angle = openmc.stats.Isotropic()
    source.energy = openmc.stats.Discrete([14.0e6], [1.0])
    source.strength = 1

    settings = openmc.Settings()
    settings.source = source
    settings.batches = 10
    settings.particles = 10000
    settings.run_mode = "fixed source"
    return settings


if __name__ == "__main__":
    materials, geometry = main()
    settings = simulation_settings()
    openmc.Model(geometry, materials, settings).run(geometry_debug=True)
