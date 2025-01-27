Exploring the different options for building a docker image without proprietary libraries. 
This is based on the LUMI docker build files found here:

https://github.com/sfantao/lumi-containers/tree/lumi-sep2024

The main aim is to be able to build docker base images without needing a system similar to LUMI.  
We have a basic image which works on LUMi. However, the interconnects are not properly used. 

# Note:
- https://github.com/apptainer/apptainer/issues/282 
  - There is an issue on Apptainer that would auto find and mount the host MPI libraries into a container. However, no work has been done on this since 2022 and the issue is still open.
- Finding the correct MPI libraries to bindmount into a container. Checkout https://github.com/E4S-Project/e4s-cl
  - The e4s-cl seems like an interesting tool. It can be installed via Spack. 
  - Its essentially a launcher for MPI workloads with containers. It can probably be used with Apptainer and it seems to be helpful for getting all required MPI libraries? 
  - https://e4s-project.github.io/e4s-cl.html 
  - Demo looks super easy
- For the RCCL tests (osu_xccl_bw) you need '-d rocm D D'. 

# step-by-step
1. Basic Container
2. Native Runs
3. Lumi bind mount container
4. Libfabric Hybrid container
5. Link GTL into lumi bind mount
6. Link GTL into libfabric hybrid container

# TODO List && Research Questions

Questions we aim to answer with this BitBulldozer

- [X] Basic container:
  - [X] bandwidth
  - [X] latency
  - [X] RCCL
  - [ ] Is libfabric actually used in the basic container via TCP IP?
  - [ ] GTL linking:
    - [ ] Can we post link the GTL into the basic MPICH? 
- [X] Native:
  - [ ] bandwidth
  - [ ] latency
  - [ ] RCCL
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
- [X] Basic device-device NCCL bandwidth tests

#### NCCL latency test
- [X] Basic device-device NCCL latency tests

#### Debug:
- [ ] Is libfabric used at all?

***
***
### Native:
#### Bandwidth tests
- [X] Host-Host OSU Bandwidth test
- [X] Device-Host
- [X] Host-Device
- [X] Device-Device

#### Latency tests
- [X] Host-Host OSU Bandwidth test
- [X] Device-Host
- [X] Host-Device
- [X] Device-Device

#### NCCL bandwidth test
- [ ] Device-device NCCL bandwidth tests

#### NCCL latency test
- [ ] Device-device NCCL latency tests

***
***
### Lumi bind mount:
#### Bandwidth tests
- [X] host-host OSU bandwidth test
- [NA] device-host OSU bandwidth test
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

## Native
- module load LUMI/24.03
- module load craype-x86-trento
- module load PrgEnv-amd
- module load craype-accel-amd-gfx90a
- module load rocm
- module load EasyBuild-user
- eb aws-ofi-rccl-17d41cb-cpeGNU-24.03.eb -r
- CC=cc CXX=CC ./configure --enable-rocm --with-rocm=/opt/rocm-6.0.3 --enable-rcclomb --with-rccl=/opt/rocm-6.0.3 --prefix=/project/project_465001699/julius/osu/build_osu
- make install

**NOTE:** 
For native bandwidth tests with GPUs, the GTL needs to be linked in and you need to set 'export MPICH_GPU_SUPPORT_ENABLED=1'.
Otherwise you get errors. 


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

| # OSU MPI Bandwidth Test v7.5 |                  |                |                |                  |         |
|-------------------------------|------------------|----------------|----------------|------------------|---------|
| # Size                        | Bandwidth (MB/s) |                |                |                  |         |
| # Datatype: MPI_CHAR.         | Host to Host     | Host to Device | Device to Host | Device to Device | RCCL    |
| 1                             | 0.18             | 0.17           | 0.17           | 0.19             | 0.01    |
| 2                             | 0.36             | 0.35           | 0.35           | 0.39             | 0.03    |
| 4                             | 0.73             | 0.70           | 0.70           | 0.77             | 0.03    |
| 8                             | 1.45             | 1.41           | 1.40           | 1.53             | 0.09    |
| 16                            | 2.90             | 2.82           | 2.77           | 3.09             | 0.26    |
| 32                            | 5.80             | 5.63           | 5.60           | 6.19             | 0.37    |
| 64                            | 11.52            | 11.12          | 11.13          | 12.34            | 0.54    |
| 128                           | 23.10            | 22.30          | 22.26          | 24.51            | 0.74    |
| 256                           | 41.53            | 38.42          | 38.48          | 46.00            | 2.04    |
| 512                           | 81.40            | 76.13          | 77.59          | 91.26            | 5.70    |
| 1024                          | 162.18           | 150.12         | 160.22         | 180.07           | 10.90   |
| 2048                          | 170.40           | 151.91         | 162.70         | 193.40           | 17.17   |
| 4096                          | 276.87           | 280.85         | 269.58         | 290.04           | 47.53   |
| 8192                          | 314.43           | 318.35         | 296.91         | 333.52           | 52.75   |
| 16384                         | 354.44           | 346.47         | 328.21         | 361.73           | 193.72  |
| 32768                         | 382.66           | 362.71         | 356.73         | 391.50           | 265.04  |
| 65536                         | 380.86           | 366.00         | 354.78         | 381.19           | 343.87  |
| 131072                        | 386.05           | 377.53         | 363.19         | 398.58           | 645.69  |
| 262144                        | 388.65           | 381.71         | 375.69         | 396.36           | 939.98  |
| 524288                        | 390.54           | 379.17         | 386.95         | 396.57           | 957.91  |
| 1048576                       | 390.32           | 379.67         | 387.71         | 398.08           | 1258.26 |
| 2097152                       | 381.37           | 380.68         | 386.68         | 398.60           | 1448.73 |
| 4194304                       | 389.20           | 374.46         | 388.07         | 397.83           | 1527.58 |


### Latency
- Host to device has a very high latency?

| # OSU MPI Latency Test v7.5 |                 |                |                |                  |         |
|-----------------------------|-----------------|----------------|----------------|------------------|---------|
| # Datatype: MPI_CHAR.       | Avg Latency(us) |                |                |                  |         |
| # Size                      | Host to Host    | Host to Device | Device to Host | Device to Device | RCCL    |
| 1                           | 16.31           | 15.16          | 16.30          | 15.67            | 218.90  |
| 2                           | 16.33           | 15.05          | 16.30          | 15.65            | 309.68  |
| 4                           | 16.31           | 15.18          | 16.30          | 15.67            | 297.32  |
| 8                           | 16.33           | 15.14          | 16.40          | 15.66            | 419.79  |
| 16                          | 16.33           | 15.18          | 16.31          | 15.67            | 236.56  |
| 32                          | 16.33           | 15.16          | 16.14          | 15.68            | 610.82  |
| 64                          | 16.39           | 15.21          | 16.19          | 15.65            | 392.20  |
| 128                         | 16.43           | 15.16          | 16.26          | 15.70            | 204.78  |
| 256                         | 18.25           | 17.25          | 18.40          | 17.93            | 644.13  |
| 512                         | 18.26           | 17.16          | 18.25          | 17.86            | 315.94  |
| 1024                        | 18.42           | 17.47          | 18.18          | 17.95            | 353.61  |
| 2048                        | 26.12           | 25.37          | 26.08          | 25.11            | 177.82  |
| 4096                        | 28.22           | 27.30          | 28.38          | 27.82            | 216.90  |
| 8192                        | 38.35           | 37.35          | 39.58          | 38.99            | 136.85  |
| 16384                       | 60.01           | 57.00          | 63.36          | 63.28            | 175.24  |
| 32768                       | 99.29           | 92.15          | 100.77         | 101.13           | 645.20  |
| 65536                       | 164.36          | 158.42         | 182.50         | 182.29           | 317.63  |
| 131072                      | 294.38          | 291.48         | 343.89         | 339.74           | 490.97  |
| 262144                      | 776.39          | 736.25         | 839.23         | 819.19           | 727.92  |
| 524288                      | 1601.35         | 1589.33        | 1770.13        | 1721.75          | 2651.56 |
| 1048576                     | 2796.96         | 2854.39        | 3319.93        | 3287.44          | 2566.16 |
| 2097152                     | 5593.95         | 5466.32        | 6464.68        | 6442.70          | 3609.97 |
| 4194304                     | 11063.38        | 10848.60       | 12942.70       | 12732.32         | 5349.97 |

***
## Native

### Bandwidth

| # OSU MPI Bandwidth Test v7.5 |              |                |                |                  |         |
|-------------------------------|--------------|----------------|----------------|------------------|---------|
| # Datatype: MPI_CHAR.         | Bandwidth    |                |                |                  |         |
| # Size                        | Host to Host | Host to Device | Device to Host | Device to Device | RCCL    |
| 1                             | 1.80         | 1.57           | 1.57           | 1.53             | 0.01    |
| 2                             | 3.62         | 3.17           | 3.17           | 3.11             | 0.03    |
| 4                             | 7.24         | 6.47           | 6.38           | 6.33             | 0.06    |
| 8                             | 14.44        | 12.96          | 12.73          | 12.66            | 0.12    |
| 16                            | 28.95        | 25.92          | 25.52          | 25.33            | 0.24    |
| 32                            | 57.72        | 51.91          | 50.76          | 50.67            | 0.54    |
| 64                            | 114.33       | 103.75         | 101.52         | 100.14           | 0.94    |
| 128                           | 231.01       | 205.23         | 202.08         | 201.29           | 1.84    |
| 256                           | 456.99       | 395.30         | 398.36         | 399.23           | 3.91    |
| 512                           | 914.56       | 770.62         | 796.72         | 798.18           | 6.27    |
| 1024                          | 1825.57      | 1573.39        | 1593.33        | 1595.32          | 14.65   |
| 2048                          | 3646.99      | 3062.32        | 3177.55        | 3186.73          | 22.27   |
| 4096                          | 7260.73      | 6255.99        | 6343.68        | 6341.36          | 54.60   |
| 8192                          | 13722.94     | 13195.32       | 12609.02       | 12624.95         | 99.28   |
| 16384                         | 17347.99     | 18591.01       | 20249.11       | 20232.51         | 152.33  |
| 32768                         | 18859.19     | 18970.21       | 19528.19       | 19402.73         | 224.01  |
| 65536                         | 20834.00     | 21338.66       | 20903.44       | 22365.23         | 377.62  |
| 131072                        | 21770.94     | 22755.22       | 21902.37       | 23186.11         | 668.51  |
| 262144                        | 22188.02     | 23369.86       | 22252.94       | 23590.67         | 1056.00 |
| 524288                        | 22383.49     | 23689.55       | 22410.27       | 23794.20         | 1259.40 |
| 1048576                       | 22498.72     | 23853.41       | 22499.65       | 23879.56         | 1462.45 |
| 2097152                       | 22555.40     | 23922.00       | 22541.25       | 23926.79         | 1639.80 |
| 4194304                       | 22584.56     | 23958.53       | 22561.99       | 23950.99         | 1701.20 |


### Latency


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



