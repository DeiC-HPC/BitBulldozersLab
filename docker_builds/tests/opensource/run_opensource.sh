#!/usr/bin/env bash
#
#
#SBATCH --job-name=opensource_container
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --partition=debug
#SBATCH --time=00:01:00
#SBATCH --account=project_465001699

export SINGULARITYENV_MPICH_OFI_USE_PROVIDER="cxi"
export SINGULARITYENV_MPIR_CVAR_OFI_USE_PROVIDER="cxi"
export SINGULARITYENV_MPICH_OFI_VERBOSE=1
export SINGULARITYENV_MPICH_OFI_NIC_VERBOSE=1
export SINGULARITYENV_FI_LOG_LEVEL=3
export SINGULARITYENV_FI_PROVIDER_PATH="/usr/lib64/libcxi.so.1"
export SINGULARITYENV_SHMEM_OFI_PROVIDER_DISPLAY=1
export SINGULARITYENV_FI_HMEM_DISABLE=1
export SINGULARITYENV_FI_HMEM_DISABLE_P2P=1

srun --output=opensource_bandwidth_host_host.txt --exclusive --mpi=pmi2 singularity exec base_mpich3.4.3_libfabric1.21.1_cxi_opensource.sif /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H H