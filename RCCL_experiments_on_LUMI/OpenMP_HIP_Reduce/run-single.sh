#!/bin/bash
#SBATCH --account=project_465001699
#SBATCH --time=00:00:20
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --partition=dev-g
#SBATCH --gpus-per-node=1

module load PrgEnv-amd rocm
srun ./build/bin/rccl-hip
