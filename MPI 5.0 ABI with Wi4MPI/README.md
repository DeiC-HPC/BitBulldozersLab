# MPI 5.0 ABI with Wi4MPI

- **Keywords:** MPI, ABI, Wi4MPI, MPICH, OpenMPI, osu, Docker
- **Date**: 2025-08-06
## Description
This BitBulldozersLab is experimentation into the new MPI 5.0 Application Binary Interface (ABI) that is supposed to be a common interface between MPICH-based and OpenMPI-based MPI Implementations, (and any new paradigms as well). This will provide distinct quality of life improvement for developers of MPI accelerated programs as well as software distribution package managers. A developer, prior to the ABI, would have to compile their software in two versions. And with slightly different object definitions and features this can create many subtle challenges. For software distributors they would have to pre-compile and provide two copies of each software as well. For example, in the Ubuntu apt package manager you generally find some packages with OpenMPI and others with MPICH, which can create a mess. Another example is in the Python ecosystem the primary MPI interface is mpi4py, and currently everybody has to manually compile it on their own system to ensure good MPI performance. But ideally you want to be able to provide one set of binaries that can be used with whatever MPI implementation the user has installed, and this is the goal of the ABI. This ABI is not yet supported by OpenMPI and MPICH, and so this BitBulldozersLab utilizes the Wi4MPI interface layer, which was used in developing the ABI according to MPI developer Jeff Hammond. 

This BitBulldozer contains the following:
- A Dockerfile to generate a semi-reproducible environment (no locked versions)
- Bash scripts to compile, run and clean-up the hello-world example
- Bash scripts to compile, run and clean-up the OSU benchmarks (The c interface)
- Jupyter notebook analyzing the performance differences on a laptop
- Python mpi4py experiments and discussions
## Reproduction
First we build the docker image using 
`docker build -t wi4mpi .`
which can be used interactively to run the experiments
`docker run -it wi4mpi`

The hello-world and OSU benchmarks can readily be reproduced in the respective folder running `./compile.sh && ./run.sh && /clean.sh`

The Jupyter Notebook can be run using `uv run jupyter notebook`

The Python environment for the mpi4py tests can be reproduced using the `./reproduce.sh` script. Additionally the matrix has run-scripts `run-openmpi.sh` for OpenMPI runtime and `run-mpich.sh` for MPICH runtime and `run.sh` for full setting up most of the environments. Some environments need to be manually configured by changing the Wi4MPI configuration file in `$WI4MPI_ROOT/etc/wi4mpi.cfg`. This configuration lets Wi4MPI choose the actual MPI backend to use. By default this is configured to the Spack installed OpenMPI and MPICH.

## Discussion
The hello-world results show that the basic functionality of getting processor names, ranks and sizes are successful across MPI implementation, however we also see issues with the MPI function `MPI_Get_library_version` which result in a bad termination of the application when running preload mode from OpenMPI compiled binaries with MPICH runtime binaries. In fact, in the interface mode we see that we are asked to remove the `MPI_Get_library_version` call altogether. This is not a critical issue however we might expect similar smaller incompatibilities.

The OSU benchmarks illustrate both expected and surprising behavior. In the bi-directional bandwidth tests, we find that the interface layer adds some additional overhead leading to reduced bandwidth. This is particularly pronounced at small message sizes and expected for a constant overhead latency. For all-reduce we find the similar expected trend for OpenMPI only, where latency is slightly higher for the interface. Furthermore this latency seems to scale proportionately with message size. The all-reduce behavior of MPICH surprising, we find significantly better performance at small message sizes when using both OpenMPI-compiled- and Wi4MPI-compiled binaries with runtime MPICH runtime. However, for intermediate and large message sizes the differences quickly disappear and they all become roughly equal.

There are different ways of providing the MPI backend to the python package mpi4py:
- `apt install python3-mpi4py` (OpenMPI)
- `pip install openmpi==5.0.8`
- `pip install mpich==4.2.3`
- `conda install openmpi=5.0.8`
- `conda install mpich=4.2.3`
- `conda install openmpi=5.0.8=external_*`
- `conda install mpich=4.2.3=external_*`

The script `python-mpi4py/run.sh` will run this matrix, which at the time of writing results in the following table. Note that Wi4MPI should actually control the MPI runtime in all the cases. So even though we `conda install openmpi`, wi4mpi will catch mpi calls, process and pass to the chosen Spack controlled MPI implementation specificied by `-T`. 
In this table the most important is the column labelled `-F self -T other` which is the preload mode of wi4mpi where the binary compiled with one MPI library is correctly translated and ran with the other MPI library. We find that only the `apt` and `conda` installations work properly with preload mode. We also test for interface mode, even though no environment is compiled against Wi4MPI. Consequentially the `-T other` column all clearly fail with helpful errors such as `Your environment has OMPI_COMM_WORLD_SIZE=4 set, but mpi4py was built with MPICH.` indicating compatibility issues.

| Python<br>environment | mpi4py <br>backend impl | `-T self` | `-F self`<br>`-T other` | `-F self` <br>`-T self` | `-T other` |
| --------------------- | ----------------------- | :-------: | :---------------------: | :---------------------: | :--------: |
| apt Python3-mpi4py    | apt OpenMPI             |     x     |            o            |            o            |     x      |
| venv                  | pip OpenMPI             |     o     |            /            |            o            |     x      |
| venv                  | pip MPICH               |     o     |            x            |            /            |     x      |
| conda env             | conda OpenMPI           |     o     |            o            |            o            |     x      |
| conda env             | conda MPICH             |     o     |            o            |            o            |     x      |
| conda env external    | conda OpenMPI           |     x     |            x            |            o            |     x      |
| conda env external    | conda MPICH             |     x     |            x            |            o            |     x      |
o = Init, ring and bandwidth successful
/ = only Init successful, ring and bandwidth failed
x = All failed

Another way to run mpi4py is to not install any python MPI implementation and rely on another mechanism such as LD_LIBRARY_PATH to ensure the correct MPI implementation is used at runtime. This is usually used to select external optimized MPI implementations on HPC clusters. Here, we first illustrate that `LD_LIBRARY_PATH` works correctly for the Spack MPICH and OpenMPI's mpirun. If we do not set `LD_LIBRARY_PATH` here, all ranks report they are rank 0, and MPICH report that the base mpi4py library seems to be built with OpenMPI.

When we attempt to use Wi4MPI to choose the MPI implementation, we find that only initialization works in preload mode. Additionally we have to abuse wi4mpi to select OpenMPI as both the From and To, to successfully work. The interface mode clearly does not work.

| Python env  | mpirun  | Init.py | ring.py | bandwidth.py |           Notes            |
| ----------- | ------- | :-----: | :-----: | :----------: | :------------------------: |
| venv-mpi4py | MPICH   |    o    |    o    |      o       | LD\_LIBRARY\_PATH Required |
| venv-mpi4py | OpenMPI |    o    |    o    |      o       | LD\_LIBRARY\_PATH Required |
| venv-mpi4py | Wi4MPI  |    o    |    o    |      o       |   -F openmpi -T openmpi    |
| venv-mpi4py | Wi4MPI  |    o    |    x    |      x       |    -F openmpi -T mpich     |
| venv-mpi4py | Wi4MPI  |    o    |    x    |      x       |     -F mpich -T mpich      |
| venv-mpi4py | Wi4MPI  |    o    |    x    |      x       |    -F mpich -T openmpi     |
| venv-mpi4py | Wi4MPI  |    x    |    x    |      x       |         -T openmpi         |
| venv-mpi4py | Wi4MPI  |    x    |    x    |      x       |          -T mpich          |
It is an issue that mpi4py is somewhat implicitly built with a preference to OpenMPI. If we look into the `mpi.cfg` config of mpi4py, we see that it can already be compiled against the [mpi-abi-stubs](https://github.com/mpi-forum/mpi-abi-stubs) that the MPI 5.0 ABI is based on. However, in the CI tests, we see that it is currently only tested with [mpich](https://github.com/mpi4py/mpi4py-testing/actions/workflows/abi.yml). This is because it requires `libmpi_abi.so` to work which only MPICH currently have.  We have also attempted an alternative approach (not shown in this BitBulldozers) where we compile mpi4py against Wi4MPI, however this does not work out straight away.
## Issues
With `conda install mpich=4.3.*` i get several regression failures, even though the Spack installed MPICH is version 4.3.0

## Summary
- The C implementation of Wi4MPI works very well, although with a few missing methods.
- Benchmark Wi4MPI with OSU benchmarks illustrate surprising performance increases when running a OpenMPI compiled binary compared with native MPICH.
- Combining wi4mpi and mpi4py is not trivial due to the variety of ways the MPI library is chosen. The apt and regular conda packages are found to be the most compatible.
- The fully integrated ABI into mpi4py seems to be the pipeline.
