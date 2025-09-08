#!/usr/bin/env bash
#
#
#SBATCH --job-name=base_bandwidth_and_latency_tests
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --partition=dev-g
#SBATCH --time=00:10:00
#SBATCH --account=project_465001699

export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

srun --output=base_bandwidth_host_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H H
srun --output=base_bandwidth_host_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H D
srun --output=base_bandwidth_device_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D H
srun --output=base_bandwidth_device_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D D

srun --output=base_latency_host_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H H
srun --output=base_latency_host_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H D
srun --output=base_latency_device_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D H
srun --output=base_latency_device_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D D

