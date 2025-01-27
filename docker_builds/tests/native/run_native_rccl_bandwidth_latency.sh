#!/usr/bin/env bash
#
# A LUMI SLURM batch script for the LUMI PyTorch multi GPU torchrun example from
# https://github.com/DeiC-HPC/cotainr
#
#SBATCH --job-name=native_bandwidth_and_latency_tests
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --partition=dev-g
#SBATCH --time=00:02:00
#SBATCH --account=project_465001699

export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

# Tell RCCL to use Slingshot interfaces and GPU RDMA
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export NCCL_NET_GDR_LEVEL=PHB
export MPICH_GPU_SUPPORT_ENABLED=1
export NCCL_DEBUG=INFO
export NCCL_DEBUG_SUBSYS=INIT,COLL

srun --output=native_rccl_bandwidth.txt --exclusive /project/project_465001699/julius/osu/build_osu/libexec/osu-micro-benchmarks/xccl/pt2pt/osu_xccl_bw -d rocm D D
srun --output=native_rccl_latency.txt --exclusive /project/project_465001699/julius/osu/build_osu/libexec/osu-micro-benchmarks/xccl/pt2pt/osu_xccl_latency -d rocm D D