#!/bin/bash
#SBATCH --partition=pre
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --mem-per-cpu=0
#SBATCH --time=0-24:00:00
#SBATCH --job-name=3x3_20_axial_2_radial
#SBATCH --error=10_axial_1_radial.%J.err
#SBATCH --output=10_axial_1_radial.%J.out

# Usage: sbatch multiphysics_amr.sh [recover]
#   (no arg)  -> fresh run: regenerate meshes, start Cardinal from scratch
#   recover   -> skip mesh regeneration, resume Cardinal from the latest checkpoint
RECOVER=${1:-0}

N_THREADS=16

module load openmpi
export UCX_POSIX_USE_PROC_LINK=n

export cross_sections=/scratch/eahammed/cross_sections/
export image_path=/scratch/eahammed/software/cardinal_dev/cardinal.sif

export bind_path="/scratch/eahammed/amr_test_cases_input_files/multi_physics_amr/"
export input_path=${PWD}

CARDINAL=/opt/cardinal-build/cardinal/cardinal-opt

if [[ "${RECOVER}" == "recover" ]]; then
  RUN_CMD="${CARDINAL} -i openmc.i --n-threads=${N_THREADS} --recover"
else
  RUN_CMD="${CARDINAL} -i mesh_neutronics.i --mesh-only --n-threads=${N_THREADS} && \
  ${CARDINAL} -i mesh_hc.i --mesh-only --n-threads=${N_THREADS} && \
  ${CARDINAL} -i openmc.i --n-threads=${N_THREADS}"
fi

srun apptainer exec \
  --bind ${bind_path}:${bind_path} \
  --bind ${cross_sections}:${cross_sections} \
  ${image_path} bash -c "export OPENMC_CROSS_SECTIONS=${cross_sections}/endfb-viii.0-hdf5/cross_sections.xml && \
  cd ${input_path} && \
  ${RUN_CMD}"
