import os
from ware_house.argument_parser import argument_parser

to_meter = 0.01


def create_mesh():
    args = argument_parser()
    with open("../3D_slab/mesh.i", "w") as f:
        f.write("[Mesh]\n")
        f.write("  [generated_mesh]\n")
        f.write("     type = GeneratedMeshGenerator\n")
        f.write(f"    nx = {args.Nx}\n")
        f.write(f"    ny = {args.Ny}\n")
        f.write(f"    nz = {args.Nz}\n")
        f.write(f"    xmin = {args.x_min}\n")
        f.write(f"    xmax = {args.x_max}\n")
        f.write(f"    ymin = {args.y_min}\n")
        f.write(f"    ymax = {args.y_max}\n")
        f.write(f"    zmin = {args.z_min}\n")
        f.write(f"    zmax = {args.z_max}\n")
        f.write(f"    dim = 3\n")
        f.write("  []\n")
        f.write("[]\n\n")


if __name__ == "__main__":
    create_mesh()

