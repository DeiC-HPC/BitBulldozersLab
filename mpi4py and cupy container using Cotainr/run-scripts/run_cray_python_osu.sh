#!/bin/bash -e
#
# A LUMI SLURM batch script for the LUMI mpi4py MPICH example from
# https://github.com/DeiC-HPC/cotainr
# This script runs the OSU benchmarks with Numpy buffers
# using the LUMI cray-python module
#
#SBATCH --job-name=mpi4py-cray-python-osu-debug
#SBATCH --nodes=3
#SBATCH --output="output_%x_%j.txt"
#SBATCH --partition=small
#SBATCH --exclusive
#SBATCH --time=00:10:00
#SBATCH --account=project_465001699

module load cray-python

export MPICH_SINGLE_HOST_ENABLED=0
export MPICH_ENV_DISPLAY=1


#Debug
export MPICH_OFI_VERBOSE=1
export MPICH_OFI_NIC_VERBOSE=1

#super handy to see some more MPI debug info
export MPIR_CVAR_DEBUG_SUMMARY=1
export FI_LOG_LEVEL=debug


PROJECT_DIR=$(pwd)
OSU_PY_BENCHMARK_DIR="$PROJECT_DIR/osu-micro-benchmarks-7.5.1/python"
RESULTS_DIR="$PROJECT_DIR/results"

# Single node runs
srun --nodes=1 --ntasks=2 --network=single_node_vni --output="$RESULTS_DIR/$SLURM_JOB_NAME-bw-single.txt" \
    python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=bw --buffer=numpy
srun --nodes=1 --ntasks=2 --network=single_node_vni --output="$RESULTS_DIR/$SLURM_JOB_NAME-latency-single.txt" \
    python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=latency --buffer=numpy
srun --nodes=1 --ntasks=3 --network=single_node_vni --output="$RESULTS_DIR/$SLURM_JOB_NAME-allgather-single.txt" \
    python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=allgather --buffer=numpy

# Multi node runs
srun --nodes=2 --ntasks=2 --tasks-per-node=1 --output="$RESULTS_DIR/$SLURM_JOB_NAME-bw-multi.txt" \
    python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=bw --buffer=numpy
srun --nodes=2 --ntasks=2 --tasks-per-node=1 --output="$RESULTS_DIR/$SLURM_JOB_NAME-latency-multi.txt" \
    python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=latency --buffer=numpy
srun --nodes=3 --ntasks=3 --tasks-per-node=1 --output="$RESULTS_DIR/$SLURM_JOB_NAME-allgather-multi.txt" \
    python3 "$OSU_PY_BENCHMARK_DIR/run.py" --benchmark=allgather --buffer=numpy
