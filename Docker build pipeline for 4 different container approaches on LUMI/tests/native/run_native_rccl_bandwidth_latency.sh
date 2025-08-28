#!/usr/bin/env bash
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

# Tell RCCL to use Slingshot interfaces and GPU RDMA. Additional optimisations
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export NCCL_CROSS_NIC=1
export NCCL_IGNORE_CPU_AFFINITY=1 #4x improvement in bandwidth!

# PHB is recommended by HPE. '3' was used by https://arxiv.org/abs/2408.14090 and is not better or worse.
# However, 3 leads to better performance on large message sizes when 'export NCCL_NCHANNELS_PER_PEER=32' is used.
export NCCL_NET_GDR_LEVEL=PHB
# Leads to about 3GB/s improvements for large message sizes (tested 4194304) but much worse for smaller message sizes.
# Better to turn off at least for intra node?
# export NCCL_NCHANNELS_PER_PEER=32


# debug RCCL, prints loads of messages
#export NCCL_DEBUG=INFO
#export NCCL_DEBUG_SUBSYS=INIT,COLL

# various cxi, libfabric environment settings
export CXI_FORK_SAFE=1
export CXI_FORK_SAFE_HP=1
export FI_CXI_DISABLE_CQ_HUGETLB=1
# Maybe already set?
#export FI_CXI_ATS=0
#export FI_MR_CACHE_MONITOR=userfaultfd
#export FI_CXI_DISABLE_HOST_REGISTER=1
#export FI_CXI_RDZV_PROTO=alt_read
#export FI_CXI_RX_MATCH_MODE=software


srun --output=native_rccl_bandwidth.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/xccl/pt2pt/osu_xccl_bw -d rocm D D
srun --output=native_rccl_latency.txt --exclusive /project/project_465001699/$USER/osu/build_osu/libexec/osu-micro-benchmarks/xccl/pt2pt/osu_xccl_latency -d rocm D D