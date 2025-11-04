#!/bin/bash
module load PrgEnv-amd rocm

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PWD} -DCMAKE_CXX_COMPILER=CC \
    && cd build \
    && make \
    && cd ..
