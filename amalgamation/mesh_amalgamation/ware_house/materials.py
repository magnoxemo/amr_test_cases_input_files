import openmc

material_dict = {
    'UO2': {
        'density': 10.4,
        'composition': {
            'U': 0.88,
            'O': 0.12
        }
    },
    'Graphite': {
        'density': 1.7,
        'composition': {
            'C': 1.0
        }
    }
}


def make_materials(material_dictionary: dict, percent_type: str, density=None):
    mat = openmc.Material()
    if density is not None:
        mat.set_density('g/cm3', density)
    else:
        mat.set_density('g/cm3', material_dictionary['density'])
    for element, percent in material_dictionary['composition'].items():
        mat.add_element(element, percent=percent, percent_type=percent_type)

    return mat
