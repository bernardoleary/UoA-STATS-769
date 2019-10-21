#!/bin/bash
#SBATCH --job-name      RparallelJob
#SBATCH --account       uoa02826
#SBATCH --time          00:10:00
#SBATCH --mem           1G
#SBATCH --output        parallel.out
#SBATCH --cpus-per-task 3

module load R/3.5.0-gimkl-2017a

srun Rscript /nesi/project/uoa02826/parallel.R
