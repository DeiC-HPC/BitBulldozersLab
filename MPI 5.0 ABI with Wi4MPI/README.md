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
- `conda install mpich=4.2.3=external_*
- Setting LD_LIBRARY_PATH

The script `python-mpi4py/run.sh` will run most of this matrix, which at the time of writing results in the following table. Notably we find that preload mode is working with the apt OpenMPI, the conda OpenMPI and the conda MPICH. Additionally, we find that interface mode is working for pip OpenMPI, pip MPICH, conda OpenMPI and conda MPICH. 

| Python<br>environment | mpi4py <br>backend impl | Wi4MPI <br>MPI config | `-T self` | `-F self`<br>`-T other` | `-F self` <br>`-T self` |
| --------------------- | ----------------------- | --------------------- | :-------: | :---------------------: | :---------------------: |
| apt Python3-mpi4py    | apt OpenMPI             | spack                 |     x     |            o            |            o            |
| venv                  | pip OpenMPI             | spack                 |     o     |            /            |            o            |
| venv                  | pip MPICH               | spack                 |     o     |            x            |            /            |
| conda env             | conda OpenMPI           | spack                 |     o     |            o            |            o            |
| conda env             | conda MPICH             | spack                 |     o     |            o            |            o            |
| conda env external    | conda OpenMPI           | spack                 |     x     |            x            |            o            |
| conda env external    | conda MPICH             | spack                 |     x     |            x            |            o            |
| venv OpenMPI LD       | spack LD_LIB_P          | spack                 |     x     |            /            |            o            |
| venv MPICH LD         | spack LD_LIB_P          | spack                 |     x     |            x            |            /            |
| venv WI4MPI LD open   | spack LD_LIB_P          | spack                 |     x     |            /            |            o            |
| venv WI4MPI LD mpich  | spack LD_LIB_P          | spack                 |     x     |            x            |            /            |

o = Init, ring and bandwidth successful
/ = only Init successful, ring and bandwidth failed
x = All failed

The Wi4MPI MPI Config setting lets Wi4MPI change between different MPI implementations. Here we experiment with using Python ecosystem MPI implementations. However, initial results showed greater incompatibility.

| Python<br>environment | mpi4py <br>backend impl | Wi4MPI <br>MPI config | `-T self` | `-F self`<br>`-T other` | `-F self` <br>`-T self` |
| --------------------- | ----------------------- | --------------------- | :-------: | :---------------------: | :---------------------: |
| venv                  | pip OpenMPI             | venv                  |    [1]    |                         |                         |
| venv                  | pip MPICH               | venv                  |    [1]    |                         |                         |
| conda env             | conda OpenMPI           | conda                 |     o     |            o            |                         |
| conda env             | conda MPICH             | conda                 |     o     |            /            |                         |
[1]: Error: could not find fortran target mpi library
Empty = Not tried

## Issues
With `conda install mpich=4.3.*` i get several regression failures, even though the Spack installed MPICH is version 4.3.0