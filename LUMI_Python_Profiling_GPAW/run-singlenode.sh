#!/bin/bash
#SBATCH --account=project_XXXXXXXXX
#SBATCH --partition=standard-g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=7
#SBATCH --gpus-per-node=8
#SBATCH --time=00:05:00

export MPICH_GPU_SUPPORT_ENABLED=1
export CUPY_CACHE_IN_MEMORY=1

# kpt * band = ntasks-per-node * nodes
srun python MnO2.py --kpt 2 --band 4 --gpu
