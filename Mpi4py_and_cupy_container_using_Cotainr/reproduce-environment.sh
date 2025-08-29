#!/bin/bash

echo "Downloading OSU Benchmark"
wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.5.1.tar.gz
tar xf osu-micro-benchmarks-7.5.1.tar.gz && rm osu-micro-benchmarks-7.5.1.tar.gz

echo "Purging modules and building container"
module purge
module load CrayEnv cotainr
cd containers/
./build_container.sh
module purge
cd ..

