#!/bin/bash
#SBATCH --partition=pre
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=0
#SBATCH --time=0-23:00:00
#SBATCH --job-name=convergence_study
#SBATCH --error=convergence_study.%J.err
#SBATCH --output=convergence_study.%J.out

module load openmpi
export UCX_POSIX_USE_PROC_LINK=n

let threads=${SLURM_CPUS_PER_TASK}*2

export cross_sections=/scratch/eahammed/cross_sections/
export image_path=/scratch/eahammed/software/cardinal_dev/cardinal.sif

export bind_path=${PWD}/../../
export input_path=${PWD}

CARDINAL=/opt/cardinal-build/cardinal/cardinal-opt


srun apptainer exec \
  --bind ${bind_path}:${bind_path} \
  --bind ${cross_sections}:${cross_sections} \
  ${image_path} bash -c "export OPENMC_CROSS_SECTIONS=${cross_sections}/endfb-viii.0-hdf5/cross_sections.xml && \
  cd ${input_path} && ${CARDINAL} -i openmc.i --n-threads=${threads}"