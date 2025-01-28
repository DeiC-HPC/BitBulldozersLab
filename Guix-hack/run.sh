#!/bin/bash
#SBATCH --account=project_46xxxxxxx
#SBATCH --time=00:4:00
#SBATCH --partition=debug
#SBATCH --exclusive
#SBATCH --nodes=2

export LD_LIBRARY_PATH=""

srun -N2 --mpi=pmi2 ./bin/mpi/pt2pt/osu_bw
