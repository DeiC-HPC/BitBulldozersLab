#!/bin/bash -e
#
# This script runs Cupy benchmarks
# using a open source cotainr container including a generic MPICH.
#
#SBATCH --job-name=cupy_open_source
#SBATCH --nodes=1
#SBATCH --gpus-per-node=2
#SBATCH --partition=dev-g
#SBATCH --time=00:05:00
#SBATCH --account=project_465001699
#SBATCH --exclusive

PROJECT_DIR="/pfs/lustrep4/scratch/project_465001699/joachimsode/summer/BitBulldozersLab/mpi4py and cupy container using Cotainr"
CONTAINERS=("cupy_mpi4py_libfabric2000.sif" \
	    "cupy_mpi4py_libfabric1220.sif")
RESULTS_DIR="$PROJECT_DIR/results"

for container in ${CONTAINERS[@]}; do
    # srun singularity exec "$PROJECT_DIR/containers/$CONTAINER" rocm-smi

    srun --output="$RESULTS_DIR/$SLURM_JOBID-cupy.txt" --mpi=pmi2 \
	 singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$CONTAINER" \
	 python3 "$PROJECT_DIR/cupy-benchmark.py" --gpus=$SLURM_GPUS_PER_NODE --benchmark=host_to_device --measure=bandwidth

    srun --output="$RESULTS_DIR/$SLURM_JOBID-cupy.txt" --mpi=pmi2 \
	 singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$CONTAINER" \
	 python3 "$PROJECT_DIR/cupy-benchmark.py" --gpus=$SLURM_GPUS_PER_NODE --benchmark=device_to_device --measure=bandwidth

done
