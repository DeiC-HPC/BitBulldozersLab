#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem=0
#SBATCH --partition=dev-g
#SBATCH --time=00:02:00
#SBATCH --account=project_462000002

srun singularity exec -B /project/project_462000002/joachimsode/BitBulldozersLab/pytorch-cotainr/import-test.py success.sif python import-test.py
