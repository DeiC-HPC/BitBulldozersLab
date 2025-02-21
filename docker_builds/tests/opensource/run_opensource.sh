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
'/opt/cray/pe/lib64/,'\
'/usr/share/libdrm/amdgpu.ids,'\

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_OFI_NIC_POLICY=GPU

export SINGULARITYENV_MPICH_GPU_SUPPORT_ENABLED=1
export SINGULARITYENV_MPICH_OFI_NIC_POLICY=GPU
export SINGULARITYENV_MPICH_OFI_USE_PROVIDER=cxi
export SINGULARITYENV_FI_PROVIDER=cxi

srun --output=opensource_bandwidth_host_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H H
srun --output=opensource_bandwidth_devive_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D D