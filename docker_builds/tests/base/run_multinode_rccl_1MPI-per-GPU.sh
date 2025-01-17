#!/usr/bin/env bash
#
# A LUMI SLURM batch script for the LUMI PyTorch multi GPU torchrun example from
# https://github.com/DeiC-HPC/cotainr
#
#SBATCH --job-name=multinode_rccl_test_1MPI-per-GPU_pmi2
#SBATCH --nodes=2
#SBATCH --tasks-per-node=8
#SBATCH --gpus-per-node=8
#SBATCH --output="output_%x_%j.txt"
#SBATCH --partition=dev-g
#SBATCH --time=00:02:00
#SBATCH --account=project_465001699


export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

#source bind_mount_libfabric.sh

cat << EOF > select_gpu
#!/bin/bash

export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
exec \$*
EOF

chmod +x ./select_gpu

CPU_BIND="map_cpu:49,57,17,25,1,9,33,41"

# Note: MPICH_GPU_SUPPORT_ENABLED doesnt seem to make a difference in the base MPI option
export MPICH_GPU_SUPPORT_ENABLED=1

# Todo: PMI2 leads to errors. Eventhough this is apparently required when using the container MPI??  --mpi=pmi2

srun --cpu-bind=${CPU_BIND} ./select_gpu singularity exec -B /project/project_465001699/ base_with_mpich_libfabric.sif /opt/rccltests/all_reduce_perf -b 64M -e 512M -f 2 -g 1
rm -rf ./select_gpu
