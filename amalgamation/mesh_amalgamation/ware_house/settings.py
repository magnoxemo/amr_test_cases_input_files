import openmc


def simulation_settings(argparse, space_dist=None):

    setting = openmc.Settings()
    setting.particles = argparse.n_particles
    setting.inactive = argparse.n_inactive_batches
    setting.batches = argparse.n_batches
    if space_dist is None:
        return setting
    setting.source = openmc.IndependentSource(space=space_dist)

    return setting
