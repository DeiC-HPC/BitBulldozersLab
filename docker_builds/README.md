Exploring the different options for building a docker image without proprietary libraries. 
This is based on the LUMI docker build files found here:

https://github.com/sfantao/lumi-containers/tree/lumi-sep2024


The main aim is to be able to build docker base images without needing a system similar to LUMI.  

### TODO
- GROMACS or similar? https://www.gromacs.org/tutorial_webinar.html
- Speed tests for pytorch
- OSU GPU Aware MPI somehow
- TODO: MPICH with slurm?
- TODO: OSU use mpicc instead of rocm clang

# Containers 

## Base image

- replace nothing

## Libfabric replacement only

Goal: 
- Build container with libfabric, MPI etc. 
- And **ONLY** replace libfabric.
- RCCL tests are included and compiled with MPICH
- OSU tests --> CPU Only

The Libfabric base works, at least to the point where the single GPU and multi GPU PyTorch examples work, as well as the RCCL test without MPICH.
TODO: Test new image that also includes MPICH

## Libfabric & Mpich replacement (i.e. complete replacement?)

Goal: 
- Build container with libfabric, MPI etc. 
- Replace libfabric and MPICH.
- RCCL tests are included and compiled with MPICH
- OSU tests --> CPU Only

TODO: Test 

# Results

## Base image

## Note:
- https://github.com/apptainer/apptainer/issues/282 
  - There is an issue on Apptainer that would auto find and mount the host MPI libraries into a container. However, no work has been done on this since 2022 and the issue is still open.
- Finding the correct MPI libraries to bindmount into a container. Checkout https://github.com/E4S-Project/e4s-cl
  - The e4s-cl seems like an interesting tool. It can be installed via Spack. 
  - Its essentially a launcher for MPI workloads with containers. It can probably be used with Apptainer and it seems to be helpful for getting all required MPI libraries? 
  - https://e4s-project.github.io/e4s-cl.html 
  - Demo looks super easy
  - 