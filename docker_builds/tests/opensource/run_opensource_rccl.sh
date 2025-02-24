#!/usr/bin/env bash
#
#
#SBATCH --job-name=opensource_container
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --partition=dev-g
#SBATCH --time=00:05:00
#SBATCH --account=project_465001699
#SBATCH --exclusive

export SINGULARITY_BIND=\
'/opt/cray/pe/mpich/8.1.29/gtl/lib/libmpi_gtl_hsa.so,'\
'/usr/share/libdrm/amdgpu.ids,'\

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_OFI_NIC_POLICY=GPU

export SINGULARITYENV_MPICH_GPU_SUPPORT_ENABLED=1
export SINGULARITYENV_MPICH_OFI_NIC_POLICY=GPU
export SINGULARITYENV_MPICH_OFI_USE_PROVIDER=cxi
export SINGULARITYENV_FI_PROVIDER=cxi

#export SINGULARITYENV_MPICH_OFI_VERBOSE=1
#export SINGULARITYENV_MPICH_OFI_NIC_VERBOSE=1
#export SINGULARITYENV_FI_LOG_LEVEL=debug

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


srun --output=opensource_rccl_bandwidth.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/xccl/pt2pt/osu_xccl_bw -d rocm D D
#srun --output=opensource_bandwidth_devive_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D D