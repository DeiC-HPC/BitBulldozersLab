# LUMI Python Profiling GPAW example
In the repository we have a minimal single-node example `h.py` of GPAW utilizing GPUs and GPU aware MPI.
The example was made for LUMI using GPAW version 25.7.0, which is installed using EasyBuild and the [Software Library recipe](https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/g/GPAW/GPAW-25.7.0-cpeGNU-25.03-rocm/). Thus the full software environment is `module load EasyBuild-user LUMI cpeGNU partition/G GPAW/25.7.0-cpeGNU-25.03-rocm`
The default parameters corresponds to a slurm allocation with 2 MPI processes and 1-8 GPUs.

The example can be adapted for a CPU-only run or a higher MPI process count. For the CPU-only run toggle the gpu boolean to `gpu=False`. For a higher MPI process count, the number of processes must be equal to the product of `domain`, `band` and `kpt` entries in the `parallel` dictionary where `kpt` can only take values 1 or 2.



