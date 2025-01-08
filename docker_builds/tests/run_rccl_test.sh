#!/usr/bin/env bash
#
# A LUMI SLURM batch script for the LUMI PyTorch multi GPU torchrun example from
# https://github.com/DeiC-HPC/cotainr
#
#SBATCH --job-name=multigpu_torchrun_example
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --gpus-per-task=8
#SBATCH --output="output_%x_%j.txt"
#SBATCH --partition=dev-g
#SBATCH --time=00:05:00
#SBATCH --account=project_465000227

export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

source bind_mount_libfabric.sh

srun singularity exec -B /project/project_465000227/ lumi_pytorch_rocm_demo.sif /opt/rccltests/all_reduce_perf -b 8 -e 128M -f 2 -g 8
