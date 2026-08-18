#!/bin/bash
#SBATCH --partition=pre
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --mem-per-cpu=0
#SBATCH --time=0-24:00:00
#SBATCH --job-name=base_case_uniform
#SBATCH --error=base_case_uniform.%J.err
#SBATCH --output=base_case_uniform.%J.out

module load openmpi
export UCX_POSIX_USE_PROC_LINK=n

export cross_sections=/scratch/eahammed/cross_sections/
export image_path=/scratch/eahammed/software/cardinal_dev/cardinal.sif

export bind_path=${PWD}/../../
export input_path=${PWD}

CARDINAL=/opt/cardinal-build/cardinal/cardinal-opt


srun apptainer exec \
  --bind ${bind_path}:${bind_path} \
  --bind ${cross_sections}:${cross_sections} \
  ${image_path} bash -c "export OPENMC_CROSS_SECTIONS=${cross_sections}/endfb-viii.0-hdf5/cross_sections.xml && \
  cd ${input_path} && ${CARDINAL} -i openmc_mesh.i --mesh-only --n-threads=16 && \
  ${CARDINAL} -i openmc.i --n-threads=16"