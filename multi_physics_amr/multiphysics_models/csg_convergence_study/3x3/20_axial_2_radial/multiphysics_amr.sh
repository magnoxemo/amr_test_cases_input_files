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
source ../../run_case.sh
