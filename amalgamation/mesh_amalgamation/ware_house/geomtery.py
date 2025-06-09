import openmc


def make_box(x_dim: list, y_dim: list, z_dim: list, boundary_conditions=None):
    """
    :return:
    a box region
    """
    if boundary_conditions is None:
        boundary_conditions = ["transmission"] * 6

    xmin = openmc.XPlane(x0=x_dim[0], boundary_type=boundary_conditions[0])
    xmax = openmc.XPlane(x0=x_dim[1], boundary_type=boundary_conditions[1])
    ymin = openmc.YPlane(y0=y_dim[0], boundary_type=boundary_conditions[2])
    ymax = openmc.YPlane(y0=y_dim[1], boundary_type=boundary_conditions[3])
    zmin = openmc.ZPlane(z0=z_dim[0], boundary_type=boundary_conditions[4])
    zmax = openmc.ZPlane(z0=z_dim[1], boundary_type=boundary_conditions[5])

    return +xmin & -xmax & +ymin & -ymax & +zmin & -zmax
