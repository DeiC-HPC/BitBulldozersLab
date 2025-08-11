#!/usr/bin/env bash
#
#
#SBATCH --job-name=opensource_container
#SBATCH --nodes=32
#SBATCH --ntasks-per-node=8
#SBATCH --gpus-per-node=8
#SBATCH --partition=dev-g
#SBATCH --time=00:02:00
#SBATCH --account=project_465001699
#SBATCH --exclusive

export SINGULARITYENV_MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1
export SINGULARITYENV_MPICH_OFI_NIC_POLICY=GPU

#disable for single node
export SINGULARITYENV_FI_PROVIDER=cxi

# Tell RCCL to use Slingshot interfaces and GPU RDMA. Additional optimisations
export SINGULARITYENV_NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export SINGULARITYENV_NCCL_CROSS_NIC=1
export SINGULARITYENV_NCCL_IGNORE_CPU_AFFINITY=1 #4x improvement in bandwidth!

# AMD says this is crucial for ROCm < 6.4.0 but I dont see a difference https://github.com/ROCm/rccl-tests?tab=readme-ov-file#performance
export SINGULARITYENV_HSA_NO_SCRATCH_RECLAIM=1
export SINGULARITYENV_HSA_ENABLE_SDMA=0

# PHB is recommended by HPE. '3' was used by https://arxiv.org/abs/2408.14090 and is not better or worse.
# However, 3 leads to better performance on large message sizes when 'export NCCL_NCHANNELS_PER_PEER=32' is used.
export SINGULARITYENV_NCCL_NET_GDR_LEVEL=PHB

# Leads to about 3GB/s improvements for large message sizes (tested 4194304) but much worse for smaller message sizes.
# Better to turn off at least for intra node?
export SINGULARITYENV_NCCL_NCHANNELS_PER_PEER=32


srun --output=opensource_rccl_bandwidth.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /rccl-tests/build/all_reduce_perf -b 8 -e 2G -f 2 -g 1
