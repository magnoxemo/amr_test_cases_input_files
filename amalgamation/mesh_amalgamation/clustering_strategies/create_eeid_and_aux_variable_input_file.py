from argparse import ArgumentParser


def argument_parser():
    ap = ArgumentParser()
    ap.add_argument('-f', dest="file_name")
    ap.add_argument('-id', dest="extra_element_integers",
                    help="names of the extra_element_integers")
    ap.add_argument("-mesh_name", dest="mesh_file_name")

    return ap.parse_args()


def add_eeid_block(arguments):
    names_str = arguments.extra_element_integers.split(" ")
    value_str = "-1 " * len(names_str)
    names_formatted = " ".join(names_str)

    with open(arguments.file_name, "w") as f:
        f.write("[Mesh]\n")
        f.write("  [add_eeid_block]\n")
        f.write("    type = ParsedElementIDMeshGenerator\n")
        f.write(f"    extra_element_integer_names = '{names_formatted}'\n")
        f.write(f"    values = '{value_str.strip()}'\n")
        f.write(f"    input = {args.mesh_file_name}\n")
        f.write("  []\n")
        f.write("[]\n\n")


def add_eeid_aux_variable_block(arguments):
    names_str = arguments.extra_element_integers.split(" ")
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
        for name in arguments.extra_element_integers.split(" "):
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

