#!/bin/bash -e
#
# This script runs the OSU benchmarks with Numpy buffers
# using a open source cotainr container including a generic MPICH.
#
#SBATCH --job-name=numpy_osu
#SBATCH --nodes=2
#SBATCH --gpus-per-node=1
#SBATCH --partition=standard-g
#SBATCH --time=00:10:00
#SBATCH --account=project_465001699
#SBATCH --exclusive

#export SINGULARITYENV_MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1
#export SINGULARITYENV_FI_HMEM_ROCR_USE_DMABUF=0  # Not supported without /boot/config-5.14.21-150500.55.49_13.0.56-cray_shasta_c bindmount
hmem=""

# export SINGULARITYENV_MPICH_OFI_NIC_POLICY=GPU
# export SINGULARITYENV_FI_PROVIDER=cxi

# #Debug
# export SINGULARITYENV_MPICH_OFI_VERBOSE=1
# export SINGULARITYENV_MPICH_OFI_NIC_VERBOSE=1

# #super handy to see some more MPI debug info
# export SINGULARITYENV_MPIR_CVAR_DEBUG_SUMMARY=1
# export SINGULARITYENV_FI_LOG_LEVEL=debug

PROJECT_DIR="/scratch/project_465001699/joachimsode/summer/BitBulldozersLab/mpi4py and cupy container using Cotainr"
OSU_PY_BENCHMARK_DIR="$PROJECT_DIR/osu-micro-benchmarks-7.5.1/python"
CONTAINERS=("mpi4py_libfabric1220_pip.sif" \
	    "mpi4py_libfabric2000_pip.sif" \
	    "mpi4py_libfabric1220_extmpich.sif" \
	    "mpi4py_libfabric2000_extmpich.sif" \
	    "mpi4py_libfabric1220_conda.sif" \
	    "mpi4py_libfabric2000_conda.sif")

RESULTS_DIR="$PROJECT_DIR/results"

SFLAGS="--nodes=1 --ntasks=2"
MFLAGS="--nodes=2 --ntasks=2 --tasks-per-node=1"

buffer="numpy"

for container in ${CONTAINERS[@]}; do
    # srun singularity exec "$PROJECT_DIR/containers/$container" rocm-smi

    # Single node runs
    srun $SFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-bw-single-$container-$buffer$hmem.txt" --exclusive --mpi=pmi2 \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=bw --buffer=$buffer
    srun $SFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-latency-single-$container-$buffer$hmem.txt" --exclusive --mpi=pmi2 \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=latency --buffer=$buffer
    srun $SFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-allgather-single-$container-$buffer$hmem.txt" --exclusive --mpi=pmi2 \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=allgather --buffer=$buffer
    
    # Multi node runs
    srun $MFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-bw-multi-$container-$buffer$hmem.txt" --exclusive --mpi=pmi2 \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=bw --buffer=$buffer
    srun $MFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-latency-multi-$container-$buffer$hmem.txt" --exclusive --mpi=pmi2 \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=latency --buffer=$buffer
    srun $MFLAGS \
	--output="$RESULTS_DIR/$SLURM_JOBID-allgather-multi-$container-$buffer$hmem.txt" --exclusive --mpi=pmi2 \
	singularity exec -B "$PROJECT_DIR" "$PROJECT_DIR/containers/$container" \
	python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=allgather --buffer=$buffer
done
