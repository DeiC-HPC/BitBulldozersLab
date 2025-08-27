#!/bin/bash

spack unload -a

spack load openmpi

echo "Running native OpenMPI"
mpirun -np 4 osu-micro-benchmarks-5.9-openmpi/mpi/startup/osu_init > results/ompi-native-init.txt
mpirun -np 2 osu-micro-benchmarks-5.9-openmpi/mpi/pt2pt/osu_bibw > results/ompi-native-bw.txt
mpirun -np 4 osu-micro-benchmarks-5.9-openmpi/mpi/collective/osu_allreduce > results/ompi-native-allred.txt

spack unload openmpi
spack load wi4mpi

echo "Running Wi4MPI preload with OpenMPI runtime and compiled with MPICH"
mpirun -F mpich -T openmpi -np 4 osu-micro-benchmarks-5.9-mpich/mpi/startup/osu_init > results/ompi-preload-init.txt
mpirun -F mpich -T openmpi -np 2 osu-micro-benchmarks-5.9-mpich/mpi/pt2pt/osu_bibw > results/ompi-preload-bw.txt
mpirun -F mpich -T openmpi -np 4 osu-micro-benchmarks-5.9-mpich/mpi/collective/osu_allreduce > results/ompi-preload-allred.txt
