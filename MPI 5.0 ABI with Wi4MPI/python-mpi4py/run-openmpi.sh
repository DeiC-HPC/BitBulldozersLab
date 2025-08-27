#!/bin/bash

echo "Running with OpenMPI compiled environment using:"
which mpirun
which python3

echo "-T self"
mpirun -n 4 -T openmpi python3 init.py
mpirun -n 4 -T openmpi python3 ring.py
mpirun -n 2 -T openmpi python3 bandwidth.py

echo "-T other"
mpirun -n 4 -T mpich python3 init.py
mpirun -n 4 -T mpich python3 ring.py
mpirun -n 2 -T mpich python3 bandwidth.py

echo "-F self -T other"
mpirun -n 4 -F openmpi -T mpich python3 init.py
mpirun -n 4 -F openmpi -T mpich python3 ring.py
mpirun -n 2 -F openmpi -T mpich python3 bandwidth.py

echo "-F self -T self"
mpirun -n 4 -F openmpi -T openmpi python3 init.py
mpirun -n 4 -F openmpi -T openmpi python3 ring.py
mpirun -n 2 -F openmpi -T openmpi python3 bandwidth.py
