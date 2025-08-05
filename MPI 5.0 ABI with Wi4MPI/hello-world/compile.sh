spack unload -a
spack load openmpi
which mpicc
mpicc hello-preload.c -o hello-preload-openmpi

spack unload -a
spack load mpich
which mpicc
mpicc hello-preload.c -o hello-preload-mpich

spack unload -a
spack load wi4mpi
which mpicc
mpicc hello-preload.c -o hello-preload-wi4mpi
mpicc hello-interface.c -o hello-interface-wi4mpi

chmod +x hello-preload-openmpi hello-preload-mpich hello-preload-wi4mpi hello-interface-wi4mpi
