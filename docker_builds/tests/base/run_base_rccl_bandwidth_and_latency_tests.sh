#!/usr/bin/env bash
#
# A LUMI SLURM batch script for the LUMI PyTorch multi GPU torchrun example from
# https://github.com/DeiC-HPC/cotainr
#
#SBATCH --job-name=base_rccl_bandwidth_and_latency_tests
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --partition=dev-g
#SBATCH --time=00:05:00
#SBATCH --account=project_465001699

export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

# Tell RCCL to use Slingshot interfaces and GPU RDMA
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export NCCL_NET_GDR_LEVEL=PHB

srun --output=base_rccl_bandwidth.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ base_with_mpich_libfabric.sif /opt/osu/libexec/osu-micro-benchmarks/xccl/pt2pt/osu_xccl_bw -d rocm D D
srun --output=base_rccl_latency.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ base_with_mpich_libfabric.sif /opt/osu/libexec/osu-micro-benchmarks/xccl/pt2pt/osu_xccl_latency -d rocm D D
