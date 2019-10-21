#!/bin/bash
#SBATCH --job-name TestJob
#SBATCH --account  uoa02826
#SBATCH --time     00:10:00
#SBATCH --output   test.out

srun echo "running on : $(hostname)"

