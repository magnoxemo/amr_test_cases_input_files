#!/bin/bash
#SBATCH --partition=pre
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --mem-per-cpu=0
#SBATCH --time=0-24:00:00
#SBATCH --job-name=40_axial_3_radial
#SBATCH --error=40_axial_3_radial.%J.err
#SBATCH --output=40_axial_3_radial.%J.out

N_THREADS=16
source ../../run_case.sh
