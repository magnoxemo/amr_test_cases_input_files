#!/bin/bash
#SBATCH --partition=pre
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --mem-per-cpu=0
#SBATCH --time=0-24:00:00
#SBATCH --job-name=gt_mid_conv_study
#SBATCH --error=gt_mid_conv_study.%J.err
#SBATCH --output=gt_mid_conv_study.%J.out

N_THREADS=1
source ../../run_case.sh
