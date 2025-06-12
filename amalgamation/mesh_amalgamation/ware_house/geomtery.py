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


def make_cylindrical_region(radius_1: float, radius_2: float, boundary_condition_for_outer_cylinder=None):
    if boundary_condition_for_outer_cylinder is None:
        boundary_condition_for_outer_cylinder = "transmission"

    if radius_2 == 0 and radius_1 != 0:
        return - openmc.ZCylinder(radius_1)
    elif radius_1 == 0 and radius_2 != 0:
        return - openmc.ZCylinder(radius_2)
    elif radius_1 == 0 and radius_2 == 0:
        return ValueError(" radius can't be zero")

    cylinder_1 = openmc.ZCylinder(min(radius_2, radius_1),
                                  boundary_type=boundary_condition_for_outer_cylinder)  # inner cylinder radius
    cylinder_2 = openmc.ZCylinder(max(radius_2, radius_1))  # outer cylinder radius

    return -cylinder_2 & + cylinder_1
