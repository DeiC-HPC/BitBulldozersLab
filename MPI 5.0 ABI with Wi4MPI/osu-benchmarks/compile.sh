wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.9.tar.gz

spack unload -a
spack load openmpi
which mpicc
tar xf osu-micro-benchmarks-5.9.tar.gz && mv osu-micro-benchmarks-5.9 osu-micro-benchmarks-5.9-openmpi
cd osu-micro-benchmarks-5.9-openmpi
./configure CC=mpicc CXX=mpicxx
make -j
cd ..

spack unload -a
spack load mpich
which mpicc
tar xf osu-micro-benchmarks-5.9.tar.gz && mv osu-micro-benchmarks-5.9 osu-micro-benchmarks-5.9-mpich
cd osu-micro-benchmarks-5.9-mpich
./configure CC=mpicc CXX=mpicxx
make -j
cd ..

spack unload -a
spack load wi4mpi
which mpicc
tar xf osu-micro-benchmarks-5.9.tar.gz && mv osu-micro-benchmarks-5.9 osu-micro-benchmarks-5.9-wi4mpi
cd osu-micro-benchmarks-5.9-wi4mpi
./configure CC=mpicc CXX=mpicxx
make -j
cd ..
