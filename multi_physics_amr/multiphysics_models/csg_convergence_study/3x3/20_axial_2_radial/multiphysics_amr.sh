#!/bin/bash
#SBATCH --partition=pre
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --mem-per-cpu=0
#SBATCH --time=0-24:00:00
#SBATCH --job-name=20_axial_2_radial
#SBATCH --error=20_axial_2_radial.%J.err
#SBATCH --output=20_axial_2_radial.%J.out

N_THREADS=16

module load openmpi
export UCX_POSIX_USE_PROC_LINK=n

export cross_sections=/scratch/eahammed/cross_sections/
export image_path=/scratch/eahammed/software/cardinal_dev/cardinal.sif

export bind_path="/scratch/eahammed/amr_test_cases_input_files/multi_physics_amr/"
export input_path=${PWD}

CARDINAL=/opt/cardinal-build/cardinal/cardinal-opt

srun apptainer exec \
  --bind ${bind_path}:${bind_path} \
  --bind ${cross_sections}:${cross_sections} \
  ${image_path} bash -c "export OPENMC_CROSS_SECTIONS=${cross_sections}/endfb-viii.0-hdf5/cross_sections.xml && \
  cd ${input_path} && \
  ${CARDINAL} -i mesh_neutronics.i --mesh-only --n-threads=${N_THREADS} && \
  ${CARDINAL} -i mesh_hc.i --mesh-only --n-threads=${N_THREADS} && \
  ${CARDINAL} -i openmc.i --n-threads=${N_THREADS}"
