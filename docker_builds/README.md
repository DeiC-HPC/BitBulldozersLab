Exploring the different options for building a docker image without proprietary libraries. 
This is based on the LUMI docker build files found here:

https://github.com/sfantao/lumi-containers/tree/lumi-sep2024


The main aim is to be able to build docker base images without needing a system similar to LUMI.  

# step-by-step
1. Basic Container
2. Lumi bind mount container
3. Libfabric Hybrid container
4. Link GTL into lumi bind mount
5. Link GTL into libfabric hybrid container

# TODO List && Questions

Questions we aim to answer with this BitBulldozer

- [ ] Basic container:
  - [ ] bandwidth? 
  - [ ] latency?
  - [ ] Is libfabric actually used in the basic container via TCP IP?
  - [ ] GTL linking:
    - [ ] Can we post link the GTL into the basic MPICH? 
- [ ] Lumi bind mount container:
  - [ ] bandwidth? 
  - [ ] latency?
  - [ ] GTL linking:
    - [ ] is there a latency difference?
    - [ ] Is there a bandwidth difference?
    - [ ] Does GTL linking impact NCCL?
- [ ] Libfarbic hybrid:
  - [ ] bandwidth? 
  - [ ] latency?
  - [ ] Linking GTL with libfabric Hybrid setup? 
    - [ ] post linking? LD_PRELOAD?
    - [ ] is there a latency difference?
    - [ ] Is there a bandwidth difference?


## Tests:

***
***
### Basic container:
#### Bandwidth tests
- [ ] Basic host-host OSU bandwidth test
- [ ] Basic device-host OSU bandwidth test
- [ ] Basic host-device OSU bandwidth test
- [ ] Basic device-device OSU bandwidth test

#### Latency tests
- [ ] Basic host-host OSU Latency test
- [ ] Basic device-host OSU Latency test
- [ ] Basic host-device OSU Latency test
- [ ] Basic device-device OSU Latency test

#### NCCL bandwidth test
- [ ] Basic device-device NCCL bandwidth tests

#### NCCL latency test
- [ ] Basic device-device NCCL latency tests

#### Debug:
- [ ] Is libfabric used at all?

***
***
### Lumi bind mount:
#### Bandwidth tests
- [X] host-host OSU bandwidth test
- [ ] device-host OSU bandwidth test
- [ ] host-devices OSU bandwidth test
- [ ] device-device OSU bandwidth test

#### Latency tests
- [ ] host-host OSU Latency test
- [ ] device-host OSU Latency test
- [ ] host-devices OSU Latency test
- [ ] device-device OSU Latency test

#### NCCL bandwidth test
- [ ] device-device NCCL bandwidth tests

#### NCCL latency test
- [ ] device-device NCCL latency tests

***
Link GTL

#### GTL Bandwidth test
- [ ] device-device OSU bandwidth test

#### GTL Latency test
- [ ] device-device OSU Latency test

#### GTL NCCL Bandwidth test
 - [ ] device-device NCCL bandwidth tests

#### GTL NCCL Bandwidth test
 - [ ] device-device NCCL latency tests

***
***
### Libfabric hybrid:
####  Bandwidth test
- [ ] host-host OSU bandwidth test
- [ ] device-host OSU bandwidth test
- [ ] host-devices OSU bandwidth test
- [ ] device-device OSU bandwidth test

#### Latency test
- [ ] host-host OSU Latency test
- [ ] device-host OSU Latency test
- [ ] host-devices OSU Latency test
- [ ] device-device OSU Latency test

#### NCCL bandwidth test
- [ ] device-device NCCL bandwidth tests

#### NCCL latency test
- [ ] device-device NCCL latency tests

***
Link GTL

#### GTL Bandwidth test
- [ ] device-device OSU bandwidth test

#### GTL Latency test
- [ ] device-device OSU Latency test

#### GTL NCCL Bandwidth test
 - [ ] device-device NCCL bandwidth tests

#### GTL NCCL Bandwidth test
 - [ ] device-device NCCL latency tests

***
***

# Backlog & Questions
- GROMACS or similar? https://www.gromacs.org/tutorial_webinar.html
- Speed tests for pytorch
- MPICH with slurm for more options?
- Can we do better than 25GB/s? 
  - Maybe through some slurm configs to select NICs?

***
***
# Container Image

We have one container for all three test cases (basic, lumi bind and libfabric hybrid)
The image includes:

- ROCm
- RCCL
- MPICH
- aws-ofi-rccl
- libfabric
- RCCL tests are included and compiled with MPICH
- OSU tests are included and compiled with MPICC. Automatically includes ROCm. And via flags also RCCL

***
***

# Definition of basic, lumi bind etc. 
## Basic
We take the container as is, with MPICH, libfabric etc. 
Nothing gets bind mounted and the communication should run via TCP IP.

The versions used for each library can be reviewed in 'common_docker_defs/Dockerfile.define_versions'.

***
## Lumi Bind
Take Basic container and replace libfabric and MPICH using the singularity bindings module on Lumi.

current setup:
- module load LUMI/24.03
- module load EasyBuild-user 
- eb singularity-bindings-24.03.eb -r
- module load singularity-bindings
- module load PrgEnv-cray (shouldnt be necessary)
- module load craype-accel-amd-gfx90a (shouldnt be necessary)
- module load rocm (shouldnt be necessary)

***
## Libfabric Hybrid
Take Basic container and replace and **ONLY** replace libfabric.


***
***

# Results

## Basic container

OSU test with container MPI - Host to Host:

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

***
## Lumi bin mount container
OSU test with container MPI - Device to Host/Host to Device:
- basically the same

| # OSU MPI Bandwidth Test v7.2 |                  |
|-------------------------------|------------------|
| # Size                        |                  |
| # Datatype: MPI_CHAR.         | Bandwidth (MB/s) |
| 1                             | 0.15             |
| 2                             | 0.32             |
| 4                             | 0.51             |
| 8                             | 1.02             |
| 16                            | 2.04             |
| 32                            | 4.07             |
| 64                            | 8.10             |
| 128                           | 16.32            |
| 256                           | 32.24            |
| 512                           | 65.03            |
| 1024                          | 123.97           |
| 2048                          | 249.06           |
| 4096                          | 484.88           |
| 8192                          | 903.43           |
| 16384                         | 1442.01          |
| 32768                         | 2091.72          |
| 65536                         | 2246.55          |
| 131072                        | 1945.72          |
| 262144                        | 2090.47          |
| 524288                        | 2184.74          |
| 1048576                       | 2226.57          |
| 2097152                       | 2262.37          |
| 4194304                       | 2258.53          |


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