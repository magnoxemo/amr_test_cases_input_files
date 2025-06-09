from argparse import ArgumentParser


def argument_parser():
    ap = ArgumentParser()
    ap.add_argument('-f', dest="file_name")
    ap.add_argument('-id', dest="extra_element_integers",
                    type=list,
                    help="names of the extra_element_integers")

    return ap.parse_args()


def add_eeid_block(arguments):
    names_str = " ".join(str(name) for name in arguments.extra_element_integers)
    value_str = " ".join(str(-1) for _ in arguments.extra_element_integers)

    with open(arguments.file_name, "w") as f:
        f.write("[Mesh]\n")
        f.write("  [add_eeid_block]\n")
        f.write("     type = ParsedElementIDMeshGenerator\n")
        f.write(f"    extra_element_integer_names = '{names_str}\n'")
        f.write(f"    values = '{value_str}'\n")
        f.write("  []\n")
        f.write("[]\n\n")


def add_eeid_aux_variable_block(arguments):
    names_str = " ".join(str(name) for name in arguments.extra_element_integers)

    with open(arguments.file_name, "a") as f:
        f.write("[AuxVariables]\n")
        for name in names_str:
            if name == " ":
                continue
            f.write(f"  [aux_{name}]\n")
            f.write(f"      order = CONSTANT\n")
            f.write(f"      family = MONOMIAL\n")
            f.write(f"  []\n")
        f.write("[]\n\n")


def add_eeid_copier_aux_kernel_block(arguments):
    with open(arguments.file_name, "a") as f:
        f.write("[AuxKernels]\n")
        for name in arguments.extra_element_integers:
            if name == " ":
                continue
            f.write(f"  [store_{name}]\n")
            f.write(f"      type = ExtraElementIDAux\n")
            f.write(f"      extra_id_name = {name}\n")
            f.write(f"      variable = aux_{name}\n")
            f.write(f"  []\n")
        f.write("[]\n\n")


if __name__ == "__main__":
    args = argument_parser()
    add_eeid_block(args)
    add_eeid_aux_variable_block(args)
    add_eeid_copier_aux_kernel_block(args)

