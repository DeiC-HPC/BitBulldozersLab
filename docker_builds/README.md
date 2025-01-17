Exploring the different options for building a docker image without proprietary libraries. 
This is based on the LUMI docker build files found here:

https://github.com/sfantao/lumi-containers/tree/lumi-sep2024


The main aim is to be able to build docker base images without needing a system similar to LUMI.  

### TODO
- GROMACS or similar? https://www.gromacs.org/tutorial_webinar.html
- Speed tests for pytorch
- OSU GPU Aware MPI somehow
- TODO: MPICH with slurm?
- "#export MPICH_GPU_SUPPORT_ENABLED=1" Not working. what modules to load?? or maybe what bind mounts?
  - current setup:
    - module load LUMI/24.03
    - module load EasyBuild-user 
    - eb singularity-bindings-24.03.eb -r
    - module load singularity-bindings
    - module load PrgEnv-cray 
    - module load craype-accel-amd-gfx90a 
    - module load rocm
  - Error:
    - MPIDI_CRAY_init: GPU_SUPPORT_ENABLED is requested, but GTL library is not linked (Other MPI error)
    - aborting job:
    - MPIDI_CRAY_init: GPU_SUPPORT_ENABLED is requested, but GTL library is not linked

# Containers 

## Base image

- replace nothing
- RCCL tests are included and compiled with MPICH
- OSU tests are included and compiled with MPICC which automatically seems to include ROCm.

- OSU benchmarks run. Both using the host and container MPI libraries works.

## Libfabric replacement only

Goal: 
- Build container with libfabric, MPI etc. 
- And **ONLY** replace libfabric.
- RCCL tests are included and compiled with MPICH
- OSU tests are included and compiled with MPICC which automatically seems to include ROCm.

The Libfabric base works, at least to the point where the single GPU and multi GPU PyTorch examples work, as well as the RCCL test without MPICH.


## Libfabric & Mpich replacement (i.e. complete replacement?)

Goal: 
- Build container with libfabric, MPI etc. 
- Replace libfabric and MPICH.
- RCCL tests are included and compiled with MPICH
- OSU tests --> CPU Only

# Results

## Base image

OSU test with container MPI:

| # OSU MPI Bandwidth Test v7.2 |                  |
|-------------------------------|------------------|
| # Size                        |                  |
| # Datatype: MPI_CHAR.         | Bandwidth (MB/s) |
| 1                             | 0.16             |
| 2                             | 0.31             |
| 4                             | 0.64             |
| 8                             | 1.27             |
| 16                            | 2.57             |
| 32                            | 5.13             |
| 64                            | 10.14            |
| 128                           | 20.40            |
| 256                           | 38.75            |
| 512                           | 77.28            |
| 1024                          | 146.53           |
| 2048                          | 282.54           |
| 4096                          | 531.06           |
| 8192                          | 940.30           |
| 16384                         | 1434.97          |
| 32768                         | 2045.56          |
| 65536                         | 2155.63          |
| 131072                        | 1929.44          |
| 262144                        | 2071.33          |
| 524288                        | 2142.00          |
| 1048576                       | 2170.57          |
| 2097152                       | 2195.92          |
| 4194304                       | 2198.81          |


OSU test with host MPI:

| # OSU MPI Bandwidth Test v7.2 |                  |
|-------------------------------|------------------|
| # Size                        |                  |
| # Datatype: MPI_CHAR.         | Bandwidth (MB/s) |
| 1                             | 1.97             |
| 2                             | 3.94             |
| 4                             | 7.84             |
| 8                             | 15.93            |
| 16                            | 31.93            |
| 32                            | 63.79            |
| 64                            | 126.61           |
| 128                           | 253.60           |
| 256                           | 469.50           |
| 512                           | 940.01           |
| 1024                          | 1874.68          |
| 2048                          | 3728.62          |
| 4096                          | 7383.41          |
| 8192                          | 13726.11         |
| 16384                         | 17080.87         |
| 32768                         | 18231.87         |
| 65536                         | 20083.24         |
| 131072                        | 21314.05         |
| 262144                        | 21698.40         |
| 524288                        | 21873.58         |
| 1048576                       | 22141.93         |
| 2097152                       | 22187.11         |
| 4194304                       | 22222.70         |



# Note:
- https://github.com/apptainer/apptainer/issues/282 
  - There is an issue on Apptainer that would auto find and mount the host MPI libraries into a container. However, no work has been done on this since 2022 and the issue is still open.
- Finding the correct MPI libraries to bindmount into a container. Checkout https://github.com/E4S-Project/e4s-cl
  - The e4s-cl seems like an interesting tool. It can be installed via Spack. 
  - Its essentially a launcher for MPI workloads with containers. It can probably be used with Apptainer and it seems to be helpful for getting all required MPI libraries? 
  - https://e4s-project.github.io/e4s-cl.html 
  - Demo looks super easy
  - 