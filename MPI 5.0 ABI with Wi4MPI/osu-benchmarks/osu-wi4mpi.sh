#!/bin/bash

spack unload -a
spack load wi4mpi

echo "Running Wi4MPI MPI ABI interface with MPICH runtime binaries"
mpirun -T mpich -np 4 osu-micro-benchmarks-5.9-wi4mpi/mpi/startup/osu_init >> results/mpich-interface-init.txt
mpirun -T mpich -np 2 osu-micro-benchmarks-5.9-wi4mpi/mpi/pt2pt/osu_bibw >> results/mpich-interface-bw.txt
mpirun -T mpich -np 4 osu-micro-benchmarks-5.9-wi4mpi/mpi/collective/osu_allreduce >> results/mpich-interface-allred.txt

echo "Running Wi4MPI MPI ABI interface with OpenMPI runtime binaries"
mpirun -T openmpi -np 4 osu-micro-benchmarks-5.9-wi4mpi/mpi/startup/osu_init >> results/ompi-interface-init.txt
mpirun -T openmpi -np 2 osu-micro-benchmarks-5.9-wi4mpi/mpi/pt2pt/osu_bibw >> results/ompi-interface-bw.txt
mpirun -T openmpi -np 4 osu-micro-benchmarks-5.9-wi4mpi/mpi/collective/osu_allreduce >> results/ompi-interface-allred.txt
