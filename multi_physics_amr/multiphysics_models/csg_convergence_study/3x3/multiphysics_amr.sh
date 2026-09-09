#!/bin/bash
#SBATCH --partition=pre
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --mem-per-cpu=0
#SBATCH --time=0-24:00:00
#SBATCH --job-name=3x3_conv_study
#SBATCH --error=3x3_conv_study.%J.err
#SBATCH --output=3x3_conv_study.%J.out

N_THREADS=16
source ../../run_case.sh
