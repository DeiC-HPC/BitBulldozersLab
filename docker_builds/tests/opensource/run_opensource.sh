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

export SINGULARITYENV_MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1
export SINGULARITYENV_MPICH_OFI_NIC_POLICY=GPU
export SINGULARITYENV_FI_PROVIDER=cxi

#Debug
#export SINGULARITYENV_MPICH_OFI_VERBOSE=1
#export SINGULARITYENV_MPICH_OFI_NIC_VERBOSE=1

#super handy to see some more MPI debug info
#export SINGULARITYENV_MPIR_CVAR_DEBUG_SUMMARY=1
#export SINGULARITYENV_FI_LOG_LEVEL=debug

srun --output=opensource_bandwidth_host_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H H
srun --output=opensource_bandwidth_host_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H D
srun --output=opensource_bandwidth_device_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D H
srun --output=opensource_bandwidth_devive_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D D

srun --output=opensource_latency_host_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H H
srun --output=opensource_latency_host_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H D
srun --output=opensource_latency_device_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D H
srun --output=opensource_latency_devive_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D D