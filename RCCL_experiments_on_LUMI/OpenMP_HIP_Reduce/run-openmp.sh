#!/bin/bash
#SBATCH --account=project_465001699
#SBATCH --time=00:00:20
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --partition=dev-g
#SBATCH --gpus-per-node=2

module load PrgEnv-amd rocm

export OMP_NUM_THREADS=2
srun ./build/bin/rccl-openmp
