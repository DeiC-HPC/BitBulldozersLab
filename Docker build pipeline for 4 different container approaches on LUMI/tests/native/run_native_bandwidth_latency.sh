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

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_OFI_NIC_POLICY=GPU

# Try debug regular MPICH and libfabric
#export MPICH_OFI_CXI_COUNTER_VERBOSE=3
#export MPICH_OFI_CXI_COUNTER_REPORT=3
#export MPICH_OFI_NIC_VERBOSE=1
#export MPICH_OFI_VERBOSE=1
#export UCX_LOG_LEVEL=verbose
#export MPICH_MEMORY_REPORT=1
#export NCCL_DEBUG=INFO
#export NCCL_DEBUG_SUBSYS=INIT,COLL

srun --output=native_bandwidth_host_host.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H H
srun --output=native_bandwidth_device_host.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D H
srun --output=native_bandwidth_host_device.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H D
srun --output=native_bandwidth_device_device.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D D

srun --output=native_latency_host_host.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H H
srun --output=native_latency_device_host.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D H
srun --output=native_latency_host_device.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H D
srun --output=native_latency_device_device.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D D