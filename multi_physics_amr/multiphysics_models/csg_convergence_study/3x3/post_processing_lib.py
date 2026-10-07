"""Small helpers to collect results from nested case directories into nested dicts.

Layout assumed: parent_dir/axial_<n>/radial_<m>/<refinement>/<data_file>
Every query returns a nested dict keyed by folder names; the leaves are small
DataFrames (leaf['time'], leaf[qoi], ...). Plotting stays in the notebook.
"""
import os
import re
from pathlib import Path

import h5py
import numpy as np
import openmc
import pandas as pd
from scipy.io import netcdf_file

LAT = re.compile(r'l\d+\((\d+),(\d+),(\d+)\)')
M_TO_CM = 100.0  # Exodus meshes are in m, CSG in cm


# ---------------------------------------------------------------- discovery

def list_files_recursive(path, data_file_name):
    """All sub directories of `path` (any depth) that contain `data_file_name`."""
    sub_directories = []
    for entry in sorted(os.listdir(path)):
        full_path = os.path.join(path, entry)
        if os.path.isdir(full_path):
            if os.path.exists(os.path.join(full_path, data_file_name)):
                sub_directories.append(Path(full_path))
            sub_directories.extend(list_files_recursive(full_path, data_file_name))
    return sub_directories


def discover_test_cases(parent_dir, data_file_name, levels=3):
    """
    Nested dict of data file paths, keyed by the last `levels` folder names, e.g.
    levels=3 -> {'axial_10': {'radial_1': {'0th': Path(.../0th/openmc_out.csv)}}}
    Directories without the data file are simply left out.
    """
    data_files = {}
    for sub_dir in list_files_recursive(parent_dir, data_file_name):
        keys = sub_dir.parts[-levels:]
        node = data_files
        for key in keys[:-1]:
            node = node.setdefault(key, {})
        node[keys[-1]] = sub_dir / data_file_name
    return data_files


# ------------------------------------------------------------ dict utilities

def map_leaves(tree, func):
    """Same nested structure as `tree`, with every leaf replaced by func(leaf)."""
    if isinstance(tree, dict):
        return {key: map_leaves(value, func) for key, value in tree.items()}
    return func(tree)


def swap_dict_levels(data, level=0):
    """
    Swap dict level `level` with the one below it.
    level=0: {a: {b: v}} -> {b: {a: v}}
    level=1: {x: {a: {b: v}}} -> {x: {b: {a: v}}}
    """
    if level > 0:
        return {key: swap_dict_levels(value, level - 1) for key, value in data.items()}
    swapped = {}
    for parent, children in data.items():
        for child, value in children.items():
            swapped.setdefault(child, {})[parent] = value
    return swapped


# ------------------------------------------------- csv (openmc_out, solid0)

def read_csv(data_files):
    """Same structure as data_files, each path replaced by a DataFrame."""
    return map_leaves(data_files, pd.read_csv)


def get_qoi(data_frames, qoi, x='time'):
    """Same structure as data_frames, each DataFrame cut down to its [x, qoi] columns."""
    return map_leaves(data_frames, lambda df: df[[x, qoi]])


def query_csv(parent_dir, data_file_name, qoi, levels=3):
    """One call: {axial: {radial: {refinement: DataFrame[time, qoi]}}}."""
    return get_qoi(read_csv(discover_test_cases(parent_dir, data_file_name, levels)), qoi)


# -------------------------------------------------------------- properties.h5

def find_model_xml(case_dir):
    """model.xml of a case: in the case dir itself or one level up."""
    for d in (case_dir, case_dir.parent):
        if (d / 'model.xml').exists():
            return d / 'model.xml'
    raise FileNotFoundError(f'no model.xml in or above {case_dir}')


def cell_kind(cell):
    """'fuel', 'clad' or None from the CSG cell name."""
    if cell.name == 'Pin Zr Clad':
        return 'clad'
    if cell.name.startswith('UO2 Fuel Ring'):
        return 'fuel'
    return None


def read_properties(h5_file, kind):
    """
    Temperatures of every `kind` ('fuel' | 'clad') distribcell instance in properties.h5.
    returns DataFrame with columns T, pin, z (cm), cell (cell id)
    """
    h5_file = Path(h5_file)
    geom = openmc.Model.from_model_xml(str(find_model_xml(h5_file.parent))).geometry
    geom.determine_paths()
    lat = next(iter(geom.get_all_lattices().values()))
    out = {'T': [], 'pin': [], 'z': [], 'cell': []}
    with h5py.File(h5_file) as f:
        for cell in geom.get_all_cells().values():
            if cell_kind(cell) != kind:
                continue
            T = f[f'geometry/cells/cell {cell.id}/temperature'][:]
            if len(T) != len(cell.paths):  # uncoupled cell, single uniform temperature
                continue
            idx = np.array([[int(g) for g in LAT.search(p).groups()] for p in cell.paths])
            out['T'].append(T)
            out['pin'].append(idx[:, 1] * lat.shape[0] + idx[:, 0])
            out['z'].append(lat.lower_left[2] + (idx[:, 2] + 0.5) * lat.pitch[2])
            out['cell'].append(np.full(len(T), cell.id))
    return pd.DataFrame({key: np.concatenate(value) for key, value in out.items()})


def query_properties(parent_dir, kind, levels=3):
    """One call: {axial: {radial: {refinement: read_properties(...)}}}."""
    files = discover_test_cases(parent_dir, 'properties.h5', levels)
    return map_leaves(files, lambda h5: read_properties(h5, kind))


def hottest_pin(props):
    """Pin index holding the peak temperature."""
    return props['pin'].iloc[props['T'].argmax()]


def pin_axial_profile(props, pin):
    """DataFrame[z, T] for one pin, hottest ring at each axial layer."""
    return props[props['pin'] == pin].groupby('z', as_index=False)['T'].max()


def mesh_half_height(mesh_file, z):
    """Half axial height (cm) of the Exodus mesh element containing each z (cm)."""
    with netcdf_file(mesh_file, 'r', mmap=False) as f:
        v = f.variables
        zn = v['coordz'][:] if 'coordz' in v else v['coord'][2]
    zn = np.unique(np.round(zn * M_TO_CM, 6))
    i = np.clip(np.searchsorted(zn, z) - 1, 0, len(zn) - 2)
    return (zn[i + 1] - zn[i]) / 2
