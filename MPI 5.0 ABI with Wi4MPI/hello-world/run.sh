spack unload -a
spack load mpich
spack load wi4mpi
echo 'Running MPI ABI'
echo 'Running MPICH compiled binary run with OpenMPI'
mpirun -F mpich -T openmpi -n 4 ./hello-preload-mpich > results/preload-mpich.txt

spack unload -a
spack load openmpi
spack load wi4mpi
echo 'Running OpenMPI compiled binary run with MPICH'
mpirun -F openmpi -T mpich -np 4 ./hello-preload-openmpi > results/preload-openmpi.txt

spack unload -a
spack load wi4mpi
echo 'Running Wi4MPI interface compiled binary run with OpenMPI'
mpirun -T openmpi -np 4 ./hello-interface-wi4mpi > results/interface-openmpi.txt
echo 'Running Wi4MPI interface compiled binary run with MPICH'
mpirun -T mpich -np 4 ./hello-interface-wi4mpi > results/interface-mpich.txt

echo 'Done'
