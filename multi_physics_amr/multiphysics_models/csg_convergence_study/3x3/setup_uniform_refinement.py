#!/usr/bin/env python3
# Build the uniform refinement tree:
#   axial_<A>/radial_<R>/{0th,1st,2nd,3rd}
# The base neutronics mesh in radial_<R> has the same number of axial layers (A)
# and fuel radial rings (R) as the CSG model (model.xml copied from decoupled_sweep),
# and its pin radii / pitch are read from that model.xml.
# Each refinement level uniformly refines the neutronics mesh only.
#
# Usage: python3 setup_uniform_refinement.py [-a 10 20 40 80] [-r 1 2 3 4] [-l 0 1 2 3]

import shutil
import xml.etree.ElementTree as ET
from argparse import ArgumentParser
from pathlib import Path

HERE = Path(__file__).resolve().parent
CSG_SOURCE = HERE.parent.parent / 'decoupled_sweep' / '3x3'
ACTIVE_CORE_HEIGHT = 3.8556  # m, common.i
CSG_GEOMETRY = {k.strip(): float(v.split('#')[0])
                for k, v in (line.split(':=') for line in (HERE / 'csg_geometry.i').read_text().splitlines()
                             if ':=' in line and not line.lstrip().startswith('#'))}

ap = ArgumentParser()
ap.add_argument('-a', dest='axials', type=int, nargs='+', default=[10, 20, 40, 80])
ap.add_argument('-r', dest='radials', type=int, nargs='+', default=[1, 2, 3, 4])
ap.add_argument('-l', dest='levels', type=int, nargs='+', default=[0, 1, 2, 3])
args = ap.parse_args()

LEVEL_NAMES = {0: '0th', 1: '1st', 2: '2nd', 3: '3rd'}

# Particle scaling: particles proportional to neutronics element count.
# Base mesh (9 pins, 8 sectors per side) has 288*(R+5) elements per axial layer;
# each uniform refinement multiplies it by 8. The largest case in the whole study gets MAX_PARTICLES.
MAX_PARTICLES = 150000
MIN_PARTICLES = 10000
BATCHES = 20000


def n_elements(axial, radial, level):
    return 288 * axial * (radial + 5) * 8**level


N_MAX = n_elements(max(args.axials), max(args.radials), max(args.levels))


def particles(axial, radial, level):
    p = MAX_PARTICLES * n_elements(axial, radial, level) / N_MAX
    return int(max(MIN_PARTICLES, min(MAX_PARTICLES, round(p, -3))))


def csg_geometry(model_xml, a, r):
    """Pin radii and pitch (m) of the CSG model, so the 0th neutronics mesh matches it exactly."""
    geom = ET.parse(model_xml).getroot().find('geometry')
    surfaces = {s.get('id'): s for s in geom.findall('surface')}
    cells = {c.get('name'): c for c in geom.findall('cell')}

    def outer_radius(cell_name):
        # the only negative-sense surface of a pin cell is its outer cylinder
        (sid,) = [t[1:] for t in cells[cell_name].get('region').split() if t.startswith('-')]
        assert surfaces[sid].get('type') == 'z-cylinder', (model_xml, cell_name)
        return float(surfaces[sid].get('coeffs').split()[2]) * 1e-2

    lattice = geom.find('lattice')
    px, py, pz = (float(v) * 1e-2 for v in lattice.find('pitch').text.split())
    nx, ny, nz = (int(v) for v in lattice.find('dimension').text.split())
    assert px == py and (nx, ny, nz) == (3, 3, a), model_xml
    assert abs(pz * a - ACTIVE_CORE_HEIGHT) < 1e-9, model_xml
    assert f'UO2 Fuel Ring {r + 1}' not in cells, model_xml

    geometry = dict(pitch=px,
                    fuel_rings=[outer_radius(f'UO2 Fuel Ring {i}') for i in range(1, r + 1)],
                    clad_inner=outer_radius('Pin Gap'),
                    clad_outer=outer_radius('Pin Zr Clad'))

    # the heat conduction mesh and subchannel take the pin geometry from csg_geometry.i
    for key, value in (('pin_pitch', geometry['pitch']),
                       ('fuel_outer_radius', geometry['fuel_rings'][-1]),
                       ('cladding_inner_radius', geometry['clad_inner']),
                       ('cladding_outer_radius', geometry['clad_outer'])):
        assert abs(CSG_GEOMETRY[key] - value) < 1e-12, (model_xml, key, CSG_GEOMETRY[key], value)
    return geometry


def write(path, text):
    path.write_text(text.lstrip('\n'))


def radial_files(case, a, r):
    shutil.copy(CSG_SOURCE / str(a) / f'radial_{r}' / 'model.xml', case / 'model.xml')
    csg = csg_geometry(case / 'model.xml', a, r)
    radii = ' '.join(f'{v:.10g}' for v in csg['fuel_rings'] + [csg['clad_inner'], csg['clad_outer']])
    write(case / 'mesh_neutronics.i', f"""
!include  ../../mesh_neutronics.i

num_neutronics_axial_layers:={a}
fuel_pin_rings={r}

[Mesh]
  [fuel_pin]
    # model.xml fuel rings, gap and clad radii (m); pitch comes from ../../csg_geometry.i
    ring_radii := '{radii}'
    ring_intervals := '{' '.join(['1'] * (r + 2))}'
    ring_block_ids := '{' '.join(['1'] * r)} 2 3'
  []
  [extrude]
    num_layers := '${{num_neutronics_axial_layers}}'
  []
  final_generator=rename
[]
""")
    write(case / 'mesh_hc.i', """
!include ../../mesh_hc.i
""")
    write(case / 'openmc.i', """
!include ../../openmc.i

[Mesh]
  [file_mesh]
    type = FileMeshGenerator
    file = mesh_neutronics_in.e
  []
  length_unit = 'm'
[]
""")
    write(case / 'solid.i', """
!include ../../solid.i

[Mesh]
  [load]
    type = FileMeshGenerator
    file = mesh_hc_in.e
  []
  length_unit = 'm'
[]
""")
    write(case / 'sub_channel.i', """
!include ../../sub_channel.i

[ICs]
  [q_prime_IC]
    power := ${assembly_th_power}
    filename := '../power_profile.txt'
  []
[]
""")


def level_files(run, a, r, level):
    name = LEVEL_NAMES[level]
    write(run / 'mesh_neutronics.i', f"""
!include  ../mesh_neutronics.i

[Mesh]
  [refine_mesh]
    type = RefineBlockGenerator
    block = 'fuel gap clad water'
    input = rename
    refinement = {level}
  []
  final_generator := refine_mesh
[]
""")
    write(run / 'mesh_hc.i', """
!include ../mesh_hc.i

[Mesh]
  [refine_mesh]
    type = RefineBlockGenerator
    block = 'fuel clad gap'
    input = rename
    refinement = 0
  []
  final_generator := refine_mesh
[]
""")
    write(run / 'openmc.i', f"""
!include ../openmc.i

[Mesh]
  [file_mesh]
    file := mesh_neutronics_in.e
  []
[]

[Problem]
  xml_directory := ../model.xml
  particles := {particles(a, r, level)}
  batches := {BATCHES}
[]

# file parameters resolve relative to the input that sets them, so point the
# sub-apps at this level's inputs (and hence this level's mesh_hc_in.e)
[MultiApps]
  [solid]
    input_files := solid.i
  []
  [sub_channel]
    input_files := sub_channel.i
  []
[]
""")
    write(run / 'solid.i', """
!include ../solid.i

[Mesh]
  [load]
    file := mesh_hc_in.e
  []
[]
""")
    write(run / 'sub_channel.i', """
!include ../sub_channel.i
""")
    job = f'3x3_a{a}_r{r}_{name}'
    write(run / 'multiphysics_amr.sh', f"""
#!/bin/bash
#SBATCH --partition=pre
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --mem-per-cpu=0
#SBATCH --time=0-24:00:00
#SBATCH --job-name={job}
#SBATCH --error={job}.%J.err
#SBATCH --output={job}.%J.out

# Usage: sbatch multiphysics_amr.sh [recover]
#   (no arg)  -> fresh run: regenerate meshes, start Cardinal from scratch
#   recover   -> skip mesh regeneration, resume Cardinal from the latest checkpoint
RECOVER=${{1:-0}}

N_THREADS=16

module load openmpi
export UCX_POSIX_USE_PROC_LINK=n

export cross_sections=/scratch/eahammed/cross_sections/
export image_path=/scratch/eahammed/software/cardinal_dev/cardinal.sif

export bind_path="/scratch/eahammed/amr_test_cases_input_files/multi_physics_amr/"
export input_path=${{PWD}}

CARDINAL=/opt/cardinal-build/cardinal/cardinal-opt

if [[ "${{RECOVER}}" == "recover" ]]; then
  RUN_CMD="${{CARDINAL}} -i openmc.i --n-threads=${{N_THREADS}} --recover"
else
  RUN_CMD="${{CARDINAL}} -i mesh_neutronics.i --mesh-only --n-threads=${{N_THREADS}} && \\
  ${{CARDINAL}} -i mesh_hc.i --mesh-only --n-threads=${{N_THREADS}} && \\
  ${{CARDINAL}} -i openmc.i --n-threads=${{N_THREADS}}"
fi

srun apptainer exec \\
  --bind ${{bind_path}}:${{bind_path}} \\
  --bind ${{cross_sections}}:${{cross_sections}} \\
  ${{image_path}} bash -c "export OPENMC_CROSS_SECTIONS=${{cross_sections}}/endfb-viii.0-hdf5/cross_sections.xml && \\
  cd ${{input_path}} && \\
  ${{RUN_CMD}}"
""")
    (run / 'multiphysics_amr.sh').chmod(0o755)


print(f'{"case":<28}{"elements":>12}{"particles":>12}{"batches":>10}')
for a in args.axials:
    for r in args.radials:
        case = HERE / f'axial_{a}' / f'radial_{r}'
        case.mkdir(parents=True, exist_ok=True)
        radial_files(case, a, r)
        for level in args.levels:
            run = case / LEVEL_NAMES[level]
            run.mkdir(exist_ok=True)
            level_files(run, a, r, level)
            print(f'{str(run.relative_to(HERE)):<28}{n_elements(a, r, level):>12}'
                  f'{particles(a, r, level):>12}{BATCHES:>10}')
