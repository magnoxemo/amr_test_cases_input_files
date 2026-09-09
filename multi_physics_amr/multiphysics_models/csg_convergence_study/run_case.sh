# Shared SLURM/apptainer driver for every csg_convergence_study case.
#
# Not a standalone job script (no #SBATCH pragmas, no shebang) - each case
# family's multiphysics_amr.sh sources this after setting N_THREADS, then gets
# symlinked into every one of that family's case directories. Must be sourced
# with CWD already set to the case directory being solved (one level below a
# case-family root such as 3x3/, 17x17/, 3x3_guide_tube_middle/), which is
# expected to hold mesh_neutronics.i (real, case-specific) and mesh_hc.i and
# openmc.i (symlinked back to the case-family root), so that the two
# mesh-only passes below regenerate mesh_neutronics_in.e and mesh_hc_in.e
# locally and the coupled run picks them up from the same directory.

: "${N_THREADS:=16}"

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
  cd ${input_path} && \
  ${CARDINAL} -i mesh_neutronics.i --mesh-only --n-threads=${N_THREADS} && \
  ${CARDINAL} -i mesh_hc.i --mesh-only --n-threads=${N_THREADS} && \
  ${CARDINAL} -i openmc.i --n-threads=${N_THREADS}"
