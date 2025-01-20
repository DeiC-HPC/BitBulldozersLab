Exploring the different options for building a docker image without proprietary libraries. 
This is based on the LUMI docker build files found here:

https://github.com/sfantao/lumi-containers/tree/lumi-sep2024

The main aim is to be able to build docker base images without needing a system similar to LUMI.  
We have a basic image which works on LUMi. However, the interconnects are not properly used. 

# step-by-step
1. Basic Container
2. Lumi bind mount container
3. Libfabric Hybrid container
4. Link GTL into lumi bind mount
5. Link GTL into libfabric hybrid container

# TODO List && Research Questions

Questions we aim to answer with this BitBulldozer

- [X] Basic container:
  - [X] bandwidth? 
  - [X] latency?
  - [ ] RCCL
  - [ ] Is libfabric actually used in the basic container via TCP IP?
  - [ ] GTL linking:
    - [ ] Can we post link the GTL into the basic MPICH? 
- [X] Lumi bind mount container:
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
- [X] Basic host-host OSU bandwidth test
- [X] Basic device-host OSU bandwidth test
- [X] Basic host-device OSU bandwidth test
- [X] Basic device-device OSU bandwidth test

#### Latency tests
- [X] Basic host-host OSU Latency test
- [X] Basic device-host OSU Latency test
- [X] Basic host-device OSU Latency test
- [X] Basic device-device OSU Latency test

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
  - real world Pytorch examples would be good
- MPICH with slurm for more options?
- Can we do better than 25GB/s? 
  - Maybe through some slurm configs to select NICs?
- are the pure RCCL tests necessary?
- Do we need to do internode testing?

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

### Bandwidth:

| # OSU MPI Bandwidth Test v7.5 |                  |                |                |                  |
|-------------------------------|------------------|----------------|----------------|------------------|
| # Size                        | Bandwidth (MB/s) |                |                |                  |
| # Datatype: MPI_CHAR.         | Host to Host     | Host to Device | Device to Host | Device to Device |
| 1                             | 0.18             | 0.17           | 0.17           | 0.19             |
| 2                             | 0.36             | 0.35           | 0.35           | 0.39             |
| 4                             | 0.73             | 0.70           | 0.70           | 0.77             |
| 8                             | 1.45             | 1.41           | 1.40           | 1.53             |
| 16                            | 2.90             | 2.82           | 2.77           | 3.09             |
| 32                            | 5.80             | 5.63           | 5.60           | 6.19             |
| 64                            | 11.52            | 11.12          | 11.13          | 12.34            |
| 128                           | 23.10            | 22.30          | 22.26          | 24.51            |
| 256                           | 41.53            | 38.42          | 38.48          | 46.00            |
| 512                           | 81.40            | 76.13          | 77.59          | 91.26            |
| 1024                          | 162.18           | 150.12         | 160.22         | 180.07           |
| 2048                          | 170.40           | 151.91         | 162.70         | 193.40           |
| 4096                          | 276.87           | 280.85         | 269.58         | 290.04           |
| 8192                          | 314.43           | 318.35         | 296.91         | 333.52           |
| 16384                         | 354.44           | 346.47         | 328.21         | 361.73           |
| 32768                         | 382.66           | 362.71         | 356.73         | 391.50           |
| 65536                         | 380.86           | 366.00         | 354.78         | 381.19           |
| 131072                        | 386.05           | 377.53         | 363.19         | 398.58           |
| 262144                        | 388.65           | 381.71         | 375.69         | 396.36           |
| 524288                        | 390.54           | 379.17         | 386.95         | 396.57           |
| 1048576                       | 390.32           | 379.67         | 387.71         | 398.08           |
| 2097152                       | 381.37           | 380.68         | 386.68         | 398.60           |
| 4194304                       | 389.20           | 374.46         | 388.07         | 397.83           |

### Latency
- Host to device has a very high latency?

| # OSU MPI Latency Test v7.5 |                 |                |                |                  |
|-----------------------------|-----------------|----------------|----------------|------------------|
| # Datatype: MPI_CHAR.       | Avg Latency(us) |                |                |                  |
| # Size                      | Host to Host    | Host to Device | Device to Host | Device to Device |
| 1                           | 16.31           | 15.16          | 16.30          | 15.67            |
| 2                           | 16.33           | 15.05          | 16.30          | 15.65            |
| 4                           | 16.31           | 15.18          | 16.30          | 15.67            |
| 8                           | 16.33           | 15.14          | 16.40          | 15.66            |
| 16                          | 16.33           | 15.18          | 16.31          | 15.67            |
| 32                          | 16.33           | 15.16          | 16.14          | 15.68            |
| 64                          | 16.39           | 15.21          | 16.19          | 15.65            |
| 128                         | 16.43           | 15.16          | 16.26          | 15.70            |
| 256                         | 18.25           | 17.25          | 18.40          | 17.93            |
| 512                         | 18.26           | 17.16          | 18.25          | 17.86            |
| 1024                        | 18.42           | 17.47          | 18.18          | 17.95            |
| 2048                        | 26.12           | 25.37          | 26.08          | 25.11            |
| 4096                        | 28.22           | 27.30          | 28.38          | 27.82            |
| 8192                        | 38.35           | 37.35          | 39.58          | 38.99            |
| 16384                       | 60.01           | 57.00          | 63.36          | 63.28            |
| 32768                       | 99.29           | 92.15          | 100.77         | 101.13           |
| 65536                       | 164.36          | 158.42         | 182.50         | 182.29           |
| 131072                      | 294.38          | 291.48         | 343.89         | 339.74           |
| 262144                      | 776.39          | 736.25         | 839.23         | 819.19           |
| 524288                      | 1601.35         | 1589.33        | 1770.13        | 1721.75          |
| 1048576                     | 2796.96         | 2854.39        | 3319.93        | 3287.44          |
| 2097152                     | 5593.95         | 5466.32        | 6464.68        | 6442.70          |
| 4194304                     | 11063.38        | 10848.60       | 12942.70       | 12732.32         |

### RCCL


***
## Lumi bind mount container



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