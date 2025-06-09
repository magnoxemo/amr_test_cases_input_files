from argparse import ArgumentParser


def argument_parser():
    arg_parser = ArgumentParser(description="Argument parser for segmented geometry model.")

    arg_parser.add_argument('-N', dest="number_of_segments", type=int, default=20,
                            help="Number of segments in x direction.")
    arg_parser.add_argument("-n", dest="n_particles", type=int, default=1000,
                            help="Number of particles per batch.")
    arg_parser.add_argument("-i", dest="n_inactive_batches", type=int, default=50,
                            help="Number of inactive batches.")
    arg_parser.add_argument("-t", dest="n_batches", type=int, default=200,
                            help="Number of total batches.")

    arg_parser.add_argument("-x_min", dest="x_min", type=float, default=0.0, help="Minimum x dimension.")
    arg_parser.add_argument("-x_max", dest="x_max", type=float, default=100.0, help="Maximum x dimension.")
    arg_parser.add_argument("-y_min", dest="y_min", type=float, default=0.0, help="Minimum y dimension.")
    arg_parser.add_argument("-y_max", dest="y_max", type=float, default=100.0, help="Maximum y dimension.")
    arg_parser.add_argument("-z_min", dest="z_min", type=float, default=0.0, help="Minimum z dimension.")
    arg_parser.add_argument("-z_max", dest="z_max", type=float, default=100.0, help="Maximum z dimension.")

    arg_parser.add_argument("-fuel_percentage", dest="fuel_percentage", type=float, default=0.5,
                            help="Fraction of the domain in x filled with fuel.")

    return arg_parser.parse_args()
