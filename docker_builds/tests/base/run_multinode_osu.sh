#!/usr/bin/env bash
#
# A LUMI SLURM batch script for the LUMI PyTorch multi GPU torchrun example from
# https://github.com/DeiC-HPC/cotainr
#
#SBATCH --job-name=multinode_osu_ptp
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --output="output_%x_%j.txt"
#SBATCH --partition=dev-g
#SBATCH --time=00:02:00
#SBATCH --account=project_465001699

# Note: MPICH_GPU_SUPPORT_ENABLED doesnt seem to make a difference in the base MPI option

export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

#source bind_mount_libfabric.sh

export MPICH_GPU_SUPPORT_ENABLED=1

srun --mpi=pmi2 singularity exec -B /project/project_465001699/ base_with_mpich_libfabric.sif /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw

