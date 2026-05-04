# LUMI Python Profiling GPAW example
In the repository we have a example `MnO2.py` of GPAW utilizing GPUs and GPU aware MPI.
The example was made for LUMI using GPAW version 25.7.0, which is installed using EasyBuild and the [Software Library recipe](https://lumi-supercomputer.github.io/LUMI-EasyBuild-docs/g/GPAW/GPAW-25.7.0-cpeGNU-25.03-rocm/). Thus the full software environment is `module load EasyBuild-user LUMI cpeGNU partition/G GPAW/25.7.0-cpeGNU-25.03-rocm`.

The job can be executed and adjusted in `run-singlenode.sh` and `run-multinode.sh`. Either job takes roughly 90 seconds with the default parameters. Additionally, there is a boolean inside `MnO2.py` to make the example very small and run in a few seconds, however in this case the overhead will like dominate the profile.

The example can be adapted for a CPU-only run or a different MPI process count. For the CPU-only run remove the `--gpu` flag in the bash script. For a different MPI process count, the number of processes must be equal to the product of `band` and `kpt` flags provided in the bash script. 

