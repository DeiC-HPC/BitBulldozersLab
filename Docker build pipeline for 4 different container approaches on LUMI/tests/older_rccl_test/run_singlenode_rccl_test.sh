#!/usr/bin/env bash
#
#SBATCH --job-name=singlenode_rccl_test
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --gpus-per-task=8
#SBATCH --output="output_%x_%j.txt"
#SBATCH --partition=dev-g
#SBATCH --time=00:01:00
#SBATCH --account=project_465001699

export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

#source bind_mount_libfabric.sh

export MPICH_GPU_SUPPORT_ENABLED=1

srun singularity exec -B /project/project_465001699/ base_with_mpich_libfabric.sif /opt/rccltests/all_reduce_perf -b 64M -e 512M -f 2 -g 8
