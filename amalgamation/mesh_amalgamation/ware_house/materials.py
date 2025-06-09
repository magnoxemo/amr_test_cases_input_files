import openmc
material_dict = {
    'UO2': {
        'density': 10.4,
        'temperature': 300,
        'id': 1,
        'composition': {
            'U235': 0.8208,
            'U238': 0.0592,
            'O16': 0.12
        }
    },
    'Graphite': {
        'density': 1.7,
        'temperature': 300,
        'id': 2,
        'composition': {
            'C12': 1.0
        }
    }
}


def make_materials(material_dictionary: dict, percent_type, enrichment=None):

    material = openmc.Material()
    material.set_density('g/cm3', material_dictionary['density'])

    for nuclide, percent in material_dictionary['composition'].items():
        if enrichment is None:
            material.add_nuclide(
                nuclide, percent=percent, percent_type=percent_type
            )
        else:
            material.add_nuclide(
                nuclide, percent=enrichment, percent_type=percent_type
            )

    return material


