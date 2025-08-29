#!/bin/bash

echo "Downloading OSU Benchmark"
wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.5.1.tar.gz
tar xf osu-micro-benchmarks-7.5.1.tar.gz && rm osu-micro-benchmarks-7.5.1.tar.gz

echo "Submitting build job (roughly 80 minutes on 1 core)"
sbatch containers/build_container.sh


