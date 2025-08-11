#!/bin/bash

echo "Running: apt python3-mpi4py, apt OpenMPI"
spack load wi4mpi
./run-openmpi.sh
spack unload -a

echo "Running: venv, pip OpenMPI"
source venv-openmpi/bin/activate
spack load wi4mpi
./run-openmpi.sh
deactivate
spack unload -a

echo "Running: venv, pip MPICH"
source venv-mpich/bin/activate
spack load wi4mpi
./run-mpich.sh
deactivate
spack unload -a

echo "Running: conda env, conda OpenMPI"
source /home/myuser/conda/bin/activate openmpi
spack load wi4mpi
./run-openmpi.sh
conda deactivate
spack unload -a

echo "Running: conda env, conda MPICH"
source /home/myuser/conda/bin/activate mpich
spack load wi4mpi
./run-mpich.sh
conda deactivate
spack unload -a

echo "Running: conda env external, conda OpenMPI"
source /home/myuser/conda/bin/activate openmpi-ext
spack load openmpi
spack load wi4mpi
./run-openmpi.sh
conda deactivate
spack unload -a

echo "Running: conda env external, conda MPICH"
source /home/myuser/conda/bin/activate mpich-ext
spack load mpich
spack load wi4mpi
./run-mpich.sh
conda deactivate
spack unload -a

# echo "Loading py-mpi4py and wi4mpi from Spack"
# spack load py-mpi4py
# spack load wi4mpi
# ./run-openmpi.sh
# spack unload -a
