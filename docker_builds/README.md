Exploring the different options for building a docker image without proprietary libraries. 
This is based on the LUMI docker build files found here:

https://github.com/sfantao/lumi-containers/tree/lumi-sep2024
Especially the 


The main aim is to be able to build docker base images without needing a system similar to LUMI.  

### TODO
- tests for MPI (OSU)
- GROMACS or similar? https://www.gromacs.org/tutorial_webinar.html
- Speed tests for pytorch

### Questions:
- Can we just have MPI in the container and bind mount libfabric? 
  - Or what is the "complete" MPI replacement??


## Libfabric replacement only

Goal: 
- Build container with libfabric, MPI etc. 
- And **ONLY** replace libfabric.

The Libfabric base works, at least to the point where the single GPU and multi GPU PyTorch examples work, as well as the RCCL test without MPICH. 
- RCCL tests are included but cannot run as they need to be compiled with MPICH. 
- TODO: OSU tests??
- TODO: Include MPICH or OpenMPI. Only replace libfabric

## Libfabric & Mpich replacement (i.e. complete replacement?)

Goal: 
- Build container with libfabric, MPI etc. 
- Replace libfabric and MPICH.