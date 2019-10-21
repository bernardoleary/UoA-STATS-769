#!/bin/bash
#SBATCH --job-name  RserialJob
#SBATCH --account   uoa02826
#SBATCH --time      00:10:00
#SBATCH --mem       1G
#SBATCH --output    serial.out

module load R/3.5.0-gimkl-2017a

srun Rscript /nesi/project/uoa02826/serial.R
