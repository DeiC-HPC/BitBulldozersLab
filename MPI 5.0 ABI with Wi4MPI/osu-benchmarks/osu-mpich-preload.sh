#!/bin/bash

spack unload -a

spack load mpich

echo "Running native MPICH"
mpirun -np 4 osu-micro-benchmarks-5.9-mpich/mpi/startup/osu_init > results/mpich-native-init.txt
mpirun -np 2 osu-micro-benchmarks-5.9-mpich/mpi/pt2pt/osu_bibw > results/mpich-native-bw.txt
mpirun -np 4 osu-micro-benchmarks-5.9-mpich/mpi/collective/osu_allreduce > results/mpich-native-allred.txt

spack unload mpich
spack load wi4mpi

echo "Running Wi4MPI preload with MPICH runtime and compiled with OpenMPI"
mpirun -F openmpi -T MPICH -np 4 osu-micro-benchmarks-5.9-openmpi/mpi/startup/osu_init > results/mpich-preload-init.txt
mpirun -F openmpi -T MPICH -np 2 osu-micro-benchmarks-5.9-openmpi/mpi/pt2pt/osu_bibw > results/mpich-preload-bw.txt
mpirun -F openmpi -T MPICH -np 4 osu-micro-benchmarks-5.9-openmpi/mpi/collective/osu_allreduce > results/mpich-preload-allred.txt
