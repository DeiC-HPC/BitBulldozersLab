#!/usr/bin/env bash
#
#
#SBATCH --job-name=guix_bandwidth_rccl
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --partition=dev-g
#SBATCH --time=00:01:00
#SBATCH --account=project_46xxxxxxx

# Tell RCCL to use Slingshot interfaces and GPU RDMA. Additional optimisations
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export NCCL_CROSS_NIC=1
export NCCL_IGNORE_CPU_AFFINITY=1
export NCCL_NET_GDR_LEVEL=PHB
export CXI_FORK_SAFE=1
export CXI_FORK_SAFE_HP=1

srun --output=guix_bandwidth_rccl.txt --exclusive --mpi=pmi2 singularity exec osu_benchmarks_rocm_libfabric.gz.squashfs /opt/xccl/pt2pt/osu_xccl_bw
