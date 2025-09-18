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
    },
    'Water': {
        'density': 1.0,
        'composition': {
            'H': 0.1119,
            'O': 0.8881
        }
    },
    'Concrete': {
        'density': 2.3,
        'composition': {
            'O': 0.52,
            'Si': 0.33,
            'Ca': 0.06,
            'Al': 0.05,
            'Fe': 0.03,
            'H': 0.01
        }
    },
    'Boronated Polyethylene (5%)': {
        'density': 0.95,
        'composition': {
            'H': 0.135,
            'C': 0.815,
            'B': 0.05
        }
    },
    'Lead': {
        'density': 11.34,
        'composition': {
            'Pb': 1.0
        }
    },
    'Iron': {
        'density': 7.87,
        'composition': {
            'Fe': 1.0
        }
    },
    'Stainless Steel (304)': {
        'density': 8.0,
        'composition': {
            'Fe': 0.70,
            'Cr': 0.20,
            'Ni': 0.10
        }
    },
    'Tungsten': {
        'density': 19.3,
        'composition': {
            'W': 1.0
        }
    },
    'Polyethylene': {
        'density': 0.94,
        'composition': {
            'C': 0.857,
            'H': 0.143
        }
    },
    'Heavy Concrete': {
        'density': 3.5,
        'composition': {
            'O': 0.45,
            'Si': 0.25,
            'Fe': 0.15,
            'Ca': 0.08,
            'H': 0.02,
            'Al': 0.05
        }
    },
    'Air': {
        'density': 0.001225,
        'composition': {
            'N': 0.755,
            'O': 0.231,
            'Ar': 0.013,
            'C': 0.001
        }
    },
    'Boron Carbide': {
        'density': 2.52,
        'composition': {
            'B': 0.8,
            'C': 0.2
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
