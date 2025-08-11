#!/bin/bash

spack unload -a
spack load openmpi
spack load wi4mpi

which mpirun

export OMPI_ROOT=/home/joaso/spack/opt/spack/linux-skylake/openmpi-5.0.8-z7exczjdxjk3xleeupmilsinwn525gn2
export LD_LIBRARY_PATH=${WI4MPI_ROOT}/lib:${LD_LIBRARY_PATH}
export WI4MPI_TO=OMPI
# export WI4MPI_FROM=OMPI
export WI4MPI_RUN_MPI_C_LIB=${OMPI_ROOT}/lib/libmpi.so
export WI4MPI_RUN_MPI_F_LIB=${OMPI_ROOT}/lib/libmpi_mpifh.so
export WI4MPI_RUN_MPIIO_C_LIB=${WI4MPI_RUN_MPI_C_LIB}
export WI4MPI_RUN_MPIIO_F_LIB=${WI4MPI_RUN_MPI_F_LIB}
export WI4MPI_WRAPPER_LIB=${WI4MPI_ROOT}/lib_${WI4MPI_TO}/libwi4mpi_${WI4MPI_TO}.so

echo "-T self"
mpirun -n 4 python3 init.py
#mpirun -n 4 python3 ring.py
#mpirun -n 2 python3 bandwidth.py
