#!/usr/bin/env bash
#
#
#SBATCH --job-name=guix_bandwidth_host_host
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --partition=debug
#SBATCH --time=00:01:00
#SBATCH --account=project_46xxxxxxx

srun --output=guix_bandwidth_host_host.txt --exclusive --mpi=pmi2 singularity exec osu_benchmarks_rocm_libfabric.gz.squashfs /opt/mpi/pt2pt/osu_bw H H
