#!/bin/bash -e
#
# This script runs the OSU benchmarks with Numpy buffers
# using a open source cotainr container including a generic MPICH.
#
#SBATCH --job-name=numpy_osu
#SBATCH --nodes=3
#SBATCH --partition=small
#SBATCH --time=00:15:00
#SBATCH --account=project_465001699
#SBATCH --exclusive

addon="nohmem-lumic"
export SINGULARITYENV_MPIR_CVAR_ENABLE_GPU=0

#Debug
# export SINGULARITYENV_MPICH_OFI_VERBOSE=1
# export SINGULARITYENV_MPICH_OFI_NIC_VERBOSE=1

#super handy to see some more MPI debug info
# export SINGULARITYENV_MPIR_CVAR_DEBUG_SUMMARY=1
# export SINGULARITYENV_FI_LOG_LEVEL=debug

PROJECT_DIR="/scratch/project_465001699/joachimsode/summer/BitBulldozersLab/mpi4py and cupy container using Cotainr"
OSU_PY_BENCHMARK_DIR="$PROJECT_DIR/osu-micro-benchmarks-7.5.1/python"
CONTAINERS=("mpi4py_libfabric1220_extmpich.sif" \
	    "mpi4py_libfabric2000_extmpich.sif" \
	    "mpi4py_libfabric1220_pip.sif" \
	    "mpi4py_libfabric2000_pip.sif" \
	    "mpi4py_libfabric1220_conda.sif" \
	    "mpi4py_libfabric2000_conda.sif")

RESULTS_DIR="$PROJECT_DIR/results"

SFLAGS="--nodes=1 --ntasks=2 --exclusive --mpi=pmi2"
MFLAGS="--nodes=2 --ntasks=2 --tasks-per-node=1 --exclusive --mpi=pmi2"
AFLAGS="--nodes=3 --ntasks=3 --tasks-per-node=1 --exclusive --mpi=pmi2"

buffer="numpy"

for container in ${CONTAINERS[@]}; do
    # srun singularity exec "$PROJECT_DIR/containers/$container" rocm-smi

    # Single node runs
    srun $SFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-bw-single-$container-$buffer-$addon.txt" \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=bw --buffer=$buffer
    srun $SFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-latency-single-$container-$buffer-$addon.txt" \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=latency --buffer=$buffer
    srun $SFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-allgather-single-$container-$buffer-$addon.txt" \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=allgather --buffer=$buffer
    
    # Multi node runs
    srun $MFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-bw-multi-$container-$buffer-$addon.txt" \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=bw --buffer=$buffer
    srun $MFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-latency-multi-$container-$buffer-$addon.txt" \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=latency --buffer=$buffer
    srun $AFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-allgather-multi-$container-$buffer-$addon.txt" \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=allgather --buffer=$buffer
done
