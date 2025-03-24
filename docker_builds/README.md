# Docker build pipeline for 4 different container approaches on LUMI

- **Keywords:** MPI, MPICH, libfabric, libcxi, container, open source, RCCL, docker, apptainer, OSU
- **Date:** 2025-03-07

# Description

In this section of the repository we explore the different options for building a docker image without proprietary libraries. 
This is based on the LUMI docker build files found here:

https://github.com/sfantao/lumi-containers/tree/lumi-sep2024

The main aim is to be able to build docker base images without needing a system similar to LUMI.  
Currently there are open source images that can be used but the interconnects don't work properly. 

# Summary
This repository compares four different container approaches to a native approach for the OSU benchmark suit. 
1) a container only approach.
2) a container approach with full bind mounts from LUMI.
3) a container approach where we replace only libfabric + lower level libraries (libcxi)
4) a fully open source container

For approaches 2) to 4) we achieve similar performance to a native approach. 

# Issues
- no AWS-OFI-RCCL2 for Libfabric 2.0 containers
- Small message sizes in the fully open source container perform worse than native. 


# Instructions to reproduce:

## Requirements:
- Docker 
- Python packages:
  - docker for python (pip install docker)
  - rich (pip install rich)

## Step-by-Step:

1) navigate to docker_builds folder
2) `sudo python3 build_docker.py` builds **3** different docker containers (**WARNING: Takes up to 5 hours on my laptop**) named:
   - `lumi_images:base_image_libfabric1152_mpich314`
   - `lumi_images:base_image_libfabric1152_mpich423`
   - `lumi_images:base_image_libcxi_libfabric1220_mpich423`
3) Each container has to be converted to an apptainer container via `sudo apptainer build $TARGET $SOURCE`
   - where $TARGET and $SOURCE have to be:
     - `base_image_mpich314_libfabric1152.sif` & `docker-daemon:lumi_images:base_image_libfabric1152_mpich314`
     - `base_image_mpich314_libfabric1152.sif` & `docker-daemon:lumi_images:base_image_libfabric1152_mpich423`
     - `base_image_mpich314_libfabric1152.sif` & `docker-daemon:lumi_images:base_image_libcxi_libfabric1220_mpich423` 
4) Each of the sif files has to be copied over to lumi via your preferred method e.g. `scp base_image_mpich314_libfabric1152.sif /project/project_XXXXXX/`
5) Copy all the .sh scripts in the 'tests' folder. (Optional: native folder)
6) Optional: Build native osu benchmark suit. See instructions [here](#native)
7) `sbatch run_XXXXXX.sh TargetImage` (i.e. `sbatch run_base_bandwidth_and_latency_tests.sh base_image_mpich314_libfabric1152.sif`)
8) Look at the resulting txt files (i.e. `base_bandwidth_host_host.txt`). 

# Note:
- https://github.com/apptainer/apptainer/issues/282 
  - There is an issue on Apptainer that would auto find and mount the host MPI libraries into a container. However, no work has been done on this since 2022 and the issue is still open.
- Finding the correct MPI libraries to bindmount into a container. Checkout https://github.com/E4S-Project/e4s-cl
  - The e4s-cl seems like an interesting tool. It can be installed via Spack. 
  - Its essentially a launcher for MPI workloads with containers. It can probably be used with Apptainer and it seems to be helpful for getting all required MPI libraries? 
  - https://e4s-project.github.io/e4s-cl.html 
  - Demo looks super easy

# TODO List && Research Questions

Questions we aim to answer with this BitBulldozer

- [X] Basic container:
  - [X] bandwidth
  - [X] latency
  - [X] RCCL
- [X] Native:
  - [X] bandwidth
  - [X] latency
  - [X] RCCL
- [X] Lumi bind mount container:
  - [X] bandwidth
  - [X] latency
  - [X] GTL linking:
    - [X] is there a latency difference?
    - [X] Is there a bandwidth difference?
    - [X] Does GTL linking impact NCCL?
- [X] Libfarbic hybrid:
  - [X] bandwidth? 
  - [X] latency?
  - [X] Linking GTL with libfabric Hybrid setup?
    - [X] is there a latency difference?
    - [X] Is there a bandwidth difference?
- [X] Full Open Source
  - [X] bandwidth? 
  - [X] latency?
  - [X] Linking GTL with libfabric Hybrid setup?
    - [X] is there a latency difference?
    - [X] Is there a bandwidth difference?


***
***

# Compatability:

|                                      | pure container | Full bind mount | libfabric-hybrid | Opensource | Built by default |
|--------------------------------------|----------------|-----------------|------------------|------------|------------------|
| libfabric 1152 & mpich 314           |        Y       | Y               | (Y)              | (Y)        | **Y**            |
| libfabric 1152 & mpich 343           |       (Y)      | Y               | N                | ??         | N                |
| libfabric 1211 & mpich 343           |       (Y)      | (Y)             | N                | ??         | N                |
| libfabric 1220 & mpich 343           |       (Y)      | (Y)             | N                | N          | N                |
| libfabric 1152 & mpich 423           |       (Y)      | Y               | Y                | N          | **Y**            |
| libfabric 1211 & mpich 423           |       (Y)      | (Y)             | N                | (Y)        | N                |
| libfabric 1220 & mpich 423           |       (Y)      | (Y)             | N                | (Y)        | N                |
| libcxi &  libfabric 1152 & mpich 343 |       NA       | ?               | N                | N          | N                |
| libcxi &  libfabric 1152 & mpich 423 |       NA       | ?               | Y                | N          | N                |
| libcxi &  libfabric 1211 & mpich 423 |       NA       | ?               | N                | Y          | N                |
| libcxi &  libfabric 1220 & mpich 423 |       NA       | ?               | N                | Y          | **Y**            |
| libcxi &  libfabric 2000 & mpich 423 |       NA       | ?               | ?                | Y          | N                |

legend:
- Y ==> works at a proper speed
- (Y) ==> Runs but something is slow
- N ==> Errors out
- ? ==> Not tested

pure container:
- libfabric 1152 & mpich 314 --> fast (~2GBs), rccl works but is slower (1.5GBs)
- libfabric 1152 & mpich 343 --> slow (~400MBs), so slow rccl doesnt work????
- libfabric 1211 & mpich 343 -->  slow (~400MBs), device also super slow, rccl so slow doesnt work????
- libfabric 1220 & mpich 343 -->  slow (~400MBs)
- libfabric 1152 & mpich 423 --> fast (~4GBs), devices are 1/4th speed but works, rccl so slow doesnt work????
- libfabric 1211 & mpich 423 --> fast (~4GBs), devices are 1/4th speed but works, rccl so slow doesnt work????
- libfabric 1220 & mpich 423 --> fast (~4GBs), devices are 1/4th speed but works, rccl so slow doesnt work????

Full bind mount
- libfabric 1152 & mpich 314 --> 22GBs, rccl 13GBs
- libfabric 1152 & mpich 343 --> 22GBs, rccl 13GBs
- libfabric 1211 & mpich 343 --> 22GBs, rccl 5GBs
- libfabric 1220 & mpich 343 --> 22GBs, rccl 5GBs
- libfabric 1152 & mpich 423 --> 22GBs, rccl 13GBs
- libfabric 1211 & mpich 423 --> 22GBs, rccl 3GBs
- libfabric 1220 & mpich 423 --> 22GBs, rccl 3GBs
- libcxi & libfabric 1152 & mpich 343 --> Works (~22GBs), 
- libcxi & libfabric 1152 & mpich 423 -->  Works (~22GBs)
- libcxi & libfabric 1211 & mpich 423 -->  Works (~22GBs)
- libcxi & libfabric 1220 & mpich 423 --> Works (~22GBs)

libfabric-hybrid:
- libfabric 1152 & mpich 314 --> Works; fallback to TCP/IP --> not compiled with channel 4
- libfabric 1152 & mpich 343 --> FAILS; This MPICH doesnt play well with libcxi??? (open_fabric:No data available)
- libfabric 1211 & mpich 343 --> FAILS; MPICH expects higher fabric version
- libfabric 1220 & mpich 343 --> FAILS; MPICH expects higher fabric version
- libfabric 1152 & mpich 423 --> 22GBs; GPU comms work; RCCL much slower (3GBs)
- libfabric 1211 & mpich 423 --> FAILS; MPICH expects higher fabric version
- libfabric 1220 & mpich 423 --> FAILS; MPICH expects higher fabric version
- libcxi & libfabric 1152 & mpich 343 --> FAILS; This MPICH doesnt play well with libcxi (open_fabric:No data available)
- libcxi & libfabric 1152 & mpich 423 --> 22GBs; GPU comms work; RCCL much slower (3GBs)
- libcxi & libfabric 1211 & mpich 423 --> FAILS; MPICH expects higher fabric version
- libcxi & libfabric 1220 & mpich 423 --> FAILS; MPICH expects higher fabric version

Opensource:
Notes:
- libfabric 1152 & MPICH 314 -->  WORKS. TCP/IP.
- libfabric 1220 & MPICH 343 --> DOESNT WORK; leads to incompatability with libcxi.
- libfabric 1211 & MPICH 423 -->  WORKS
- libfabric 1220 & MPICH 423 --> WORKS
- libfabric 1152 & MPICH 423 --> DOESNT WORK; libfabric --enable-cxi --> not available
- libcxi & libfabric 1152 & mpich 343 --> FAILS; (open_fabric:No data available)
- libcxi & libfabric 1152 & mpich 423 --> FAILS; (open_fabric:No data available)
- libcxi & libfabric 1211 & mpich 423 --> 22GBs; GPU comms work; RCCL at 13GBs
- libcxi & libfabric 1220 & mpich 423 --> 22GBs; GPU comms work; RCCL at 13GBs
- libcxi & libfabric 2000 & mpich 423 --> 22GBs; GPU comms work; RCCL at 3GBs (**AWS-OFI-RCCL** missing)


# Definition of basic, lumi bind etc.
## Basic
We take the container as is, with MPICH, libfabric etc. 
Nothing gets bind mounted and the communication should run via TCP IP.

The versions used for each library can be reviewed in [Dockerfile.define_versions](common_docker_defs/Dockerfile.define_versions).

This is based on the `base_image_mpich314_libfabric1152.sif` image.

***

## Native

In order to build the native OSU benchmarks you have to run the following:

```
module load LUMI/24.03
module load craype-x86-trento
module load PrgEnv-amd
module load craype-accel-amd-gfx90a
module load rocm
module load EasyBuild-user
export MPICH_GPU_SUPPORT_ENABLED=1
eb aws-ofi-rccl-17d41cb-cpeGNU-24.03.eb -r
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/users/$USER/EasyBuild/SW/LUMI-24.03/L/aws-ofi-rccl/17d41cb-cpeGNU-24.03/lib/:/users/$USER/EasyBuild/SW/LUMI-24.03/L/aws-ofi-rccl/17d41cb-cpeGNU-24.03/lib64/
cd /project/project_XXXXXXXXX/
curl -LO  https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.5.tar.gz
tar -xf osu-*.tar.gz 
rm -rf osu-*.tar.gz 
cd osu-*/ 
CC=cc CXX=CC ./configure --enable-rocm --with-rocm=/opt/rocm-6.0.3 --enable-rcclomb --with-rccl=/opt/rocm-6.0.3 --prefix=/project/project_465001699/osu/build_osu
make install
```

**NOTE:** 
For native bandwidth tests with GPUs, the GTL needs to be linked in, and you need to set 'export MPICH_GPU_SUPPORT_ENABLED=1'.
GTL should be automatically linked when 'module load craype-accel-amd-gfx90a'. 
Otherwise, you get errors. You can check if the GTL is linked with 'ldd' and the library is 'libmpi_gtl_hsa.so.0 => /opt/cray/pe/lib64/libmpi_gtl_hsa.so.0'.
- 'export NCCL_IGNORE_CPU_AFFINITY=1' Leads to almost 4x improvement.

***
## Lumi Bind
Takes Basic container and replace libfabric, MPICH, Rocm and a bunch of other files. The details are in: 
[run_lumi_bind_bandwidth_and_latency_tests.sh](tests/lumi_bind/run_lumi_bind_bandwidth_and_latency_tests.sh)

This is based on the `base_image_mpich314_libfabric1152.sif` image.

The Lumi Full Bind mount is special as it needs to preload the `libhsa-runtime64.so.1` before executing device to device communication. 
Therefore, the container includes the  [run_script.sh](additional_docker_files/run_script.sh) file. This runs the `LD_PRELOAD` command before the actual OSU benchmark. 

### Additional information:

- including 'opt/rocm-6.0.3/lib' in LD_LIBRARY_PATH needed for 'libhsa-runtime64.so.1' 
- LD_LIBRARY_PATH use '/opt/cray/pe/mpich/8.1.29/ofi/amd/5.0/lib-abi-mpich' instead of '/opt/cray/pe/mpich/8.1.29/ofi/gnu/12.3/lib-abi-mpich'
- LD_LIBRARY_PATH needs to include '/opt/rocm-6.0.3/llvm/lib' for 'amd/5.0/lib-abi-mpich'

Additional bind mounts needed over normal singularity bind mounts:
- '/usr/share/libdrm/amdgpu.ids,'
- '/opt/rocm-6.0.3'

I found the correct lib-abi-mpich to include by loading the following:

module load LUMI/24.03
module load craype-x86-trento
module load PrgEnv-amd
module load craype-accel-amd-gfx90a
module load rocm

And then checking e.g. 'which mpicc' and ldd on new/missing '.so' files.

For RCCL I had to explicitly add the aws-ofi-rccl in the container to the LD_LIBRARY_PATH.
Debugging can be turned on by uncommenting lines 99 and 100 in [run_lumi_bind_rccl_bandwidth_and_latency_tests.sh](tests/lumi_bind/run_lumi_bind_rccl_bandwidth_and_latency_tests.sh)


***
## Libfabric Hybrid
Take a container with libfabric and MPICH and replace libfabric as well as include cxi.
The details are in:
[run_libfabric_hybrid_bandwidth_and_latency_tests.sh](tests/libfabric_hybrid/run_libfabric_hybrid_bandwidth_and_latency_tests.sh)

This is based on the `base_image_libfabric1152_mpich423.sif` image.
The versions of the libraries matter a lot for this way of running containers on LUMI. 

The GTL library is not required for this container as we can use the device communication from MPICH 4.2.2.
However, we do need to enable this with `MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1`

***
## Opensource:
Container with libfabric, MPICH and libcxi. No bind mounts needed.
This is based on the `base_image_libcxi_libfabric1220_mpich423.sif` image.

The GTL library is not required for this container as we can use the device communication from MPICH 4.2.2.
However, we do need to enable this with `MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1`

***
***

# Results

## Basic container

Run with: base_image_mpich314_libfabric1152.sif

- TCP/IP sockets are used for RCCL comms
- MPICH_RELEASE=3.4.3 and LIBFABRIC_RELEASE=1.22.0 lead to very poor performance on normal MPICH comms. About 7x slower. 
- MPICH version > 4 seems to lead to better results again (but did not check libfabric version)


### Bandwidth:

-libfabric 1152 & mpich 314 

| # OSU MPI Bandwidth Test v7.5 |                  |                |                |                  |         |
|-------------------------------|------------------|----------------|----------------|------------------|---------|
| # Size                        | Bandwidth (MB/s) |                |                |                  |         |
| # Datatype: MPI_CHAR.         | Host to Host     | Host to Device | Device to Host | Device to Device | RCCL    |
| 1                             | 0.19             | 0.16           | 0.16           | 0.19             | 0.01    |
| 2                             | 0.39             | 0.32           | 0.31           | 0.39             | 0.03    |
| 4                             | 0.80             | 0.63           | 0.59           | 0.79             | 0.03    |
| 8                             | 1.55             | 1.27           | 1.21           | 1.56             | 0.09    |
| 16                            | 2.64             | 2.54           | 2.48           | 3.45             | 0.26    |
| 32                            | 6.33             | 4.97           | 4.83           | 7.19             | 0.37    |
| 64                            | 10.19            | 9.88           | 9.75           | 14.04            | 0.54    |
| 128                           | 27.45            | 20.62          | 19.24          | 28.55            | 0.74    |
| 256                           | 56.17            | 40.97          | 39.46          | 57.35            | 2.04    |
| 512                           | 105.89           | 80.91          | 78.66          | 120.58           | 5.70    |
| 1024                          | 140.84           | 132.24         | 135.94         | 159.75           | 10.90   |
| 2048                          | 267.35           | 262.16         | 276.54         | 308.61           | 17.17   |
| 4096                          | 514.24           | 506.30         | 524.98         | 570.16           | 47.53   |
| 8192                          | 873.23           | 915.94         | 956.35         | 1002.99          | 52.75   |
| 16384                         | 1448.54          | 1543.63        | 1442.83        | 1502.48          | 193.72  |
| 32768                         | 1962.12          | 1983.85        | 2117.09        | 2222.13          | 265.04  |
| 65536                         | 2226.37          | 2344.62        | 2318.93        | 2342.70          | 343.87  |
| 131072                        | 1899.65          | 2000.53        | 2031.70        | 2156.27          | 645.69  |
| 262144                        | 2024.29          | 2081.90        | 2181.80        | 2262.11          | 939.98  |
| 524288                        | 2061.48          | 2111.57        | 2302.39        | 2309.45          | 957.91  |
| 1048576                       | 2089.20          | 2157.20        | 2364.52        | 2349.78          | 1258.26 |
| 2097152                       | 2116.42          | 2186.92        | 2390.04        | 2370.15          | 1448.73 |
| 4194304                       | 2131.71          | 2213.48        | 2375.16        | 2385.65          | 1527.58 |


### Latency

| # OSU MPI Latency Test v7.5 |                 |                |                |                  |         |
|-----------------------------|-----------------|----------------|----------------|------------------|---------|
| # Datatype: MPI_CHAR.       | Avg Latency(us) |                |                |                  |         |
| # Size                      | Host to Host    | Host to Device | Device to Host | Device to Device | RCCL    |
| 1                           | 12.07           | 12.10          | 12.33          | 12.01            | 218.90  |
| 2                           | 12.01           | 12.18          | 12.22          | 11.97            | 309.68  |
| 4                           | 12.03           | 12.07          | 12.19          | 11.94            | 297.32  |
| 8                           | 12.03           | 12.16          | 12.15          | 11.70            | 419.79  |
| 16                          | 12.01           | 12.18          | 12.30          | 11.92            | 236.56  |
| 32                          | 12.06           | 12.23          | 12.18          | 11.79            | 610.82  |
| 64                          | 12.08           | 12.27          | 12.17          | 11.81            | 392.20  |
| 128                         | 11.74           | 12.20          | 12.26          | 11.96            | 204.78  |
| 256                         | 12.39           | 13.50          | 13.52          | 13.15            | 644.13  |
| 512                         | 12.85           | 13.48          | 13.79          | 13.03            | 315.94  |
| 1024                        | 15.49           | 16.20          | 16.46          | 15.81            | 353.61  |
| 2048                        | 15.54           | 16.80          | 16.60          | 15.86            | 177.82  |
| 4096                        | 16.86           | 18.47          | 18.14          | 17.51            | 216.90  |
| 8192                        | 18.22           | 19.55          | 19.49          | 19.13            | 136.85  |
| 16384                       | 22.46           | 25.00          | 24.45          | 24.82            | 175.24  |
| 32768                       | 31.39           | 34.17          | 34.46          | 33.92            | 645.20  |
| 65536                       | 45.50           | 49.83          | 48.83          | 51.61            | 317.63  |
| 131072                      | 90.17           | 100.02         | 97.30          | 98.25            | 490.97  |
| 262144                      | 153.56          | 170.88         | 166.17         | 165.62           | 727.92  |
| 524288                      | 256.07          | 287.13         | 290.85         | 294.70           | 2651.56 |
| 1048576                     | 455.27          | 522.12         | 528.16         | 524.18           | 2566.16 |
| 2097152                     | 869.01          | 1002.17        | 983.97         | 990.19           | 3609.97 |
| 4194304                     | 1731.68         | 1928.96        | 1935.67        | 1962.79          | 5349.97 |


***
## Native

- The debug information clearly show that RCCL is using AWS Libfabric and CXI provider. (uncomment lines 33 and 34 in [run_native_rccl_bandwidth_latency.sh](tests/native/run_native_rccl_bandwidth_latency.sh))

### Bandwidth

- RCCL results are better than before adding optimisation flags but still far from the MPI speeds. Maybe possible to improve with additional flags. Could also be that the benchmark isn't well suited to take advantage of the hardware.
- weird drop at 8192 for RCCL

| # OSU MPI Bandwidth Test v7.5 |              |                |                |                  |          |
|-------------------------------|--------------|----------------|----------------|------------------|----------|
| # Datatype: MPI_CHAR.         | Bandwidth    |                |                |                  |          |
| # Size                        | Host to Host | Host to Device | Device to Host | Device to Device | RCCL     |
| 1                             | 1.80         | 1.57           | 1.57           | 1.53             | 0.10     |
| 2                             | 3.62         | 3.17           | 3.17           | 3.11             | 0.21     |
| 4                             | 7.24         | 6.47           | 6.38           | 6.33             | 0.40     |
| 8                             | 14.44        | 12.96          | 12.73          | 12.66            | 0.83     |
| 16                            | 28.95        | 25.92          | 25.52          | 25.33            | 1.68     |
| 32                            | 57.72        | 51.91          | 50.76          | 50.67            | 3.35     |
| 64                            | 114.33       | 103.75         | 101.52         | 100.14           | 6.39     |
| 128                           | 231.01       | 205.23         | 202.08         | 201.29           | 12.71    |
| 256                           | 456.99       | 395.30         | 398.36         | 399.23           | 26.20    |
| 512                           | 914.56       | 770.62         | 796.72         | 798.18           | 51.97    |
| 1024                          | 1825.57      | 1573.39        | 1593.33        | 1595.32          | 102.81   |
| 2048                          | 3646.99      | 3062.32        | 3177.55        | 3186.73          | 200.84   |
| 4096                          | 7260.73      | 6255.99        | 6343.68        | 6341.36          | 390.54   |
| 8192                          | 13722.94     | 13195.32       | 12609.02       | 12624.95         | 53.69    |
| 16384                         | 17347.99     | 18591.01       | 20249.11       | 20232.51         | 513.95   |
| 32768                         | 18859.19     | 18970.21       | 19528.19       | 19402.73         | 2063.77  |
| 65536                         | 20834.00     | 21338.66       | 20903.44       | 22365.23         | 3111.74  |
| 131072                        | 21770.94     | 22755.22       | 21902.37       | 23186.11         | 5075.89  |
| 262144                        | 22188.02     | 23369.86       | 22252.94       | 23590.67         | 6956.27  |
| 524288                        | 22383.49     | 23689.55       | 22410.27       | 23794.20         | 8437.05  |
| 1048576                       | 22498.72     | 23853.41       | 22499.65       | 23879.56         | 11580.92 |
| 2097152                       | 22555.40     | 23922.00       | 22541.25       | 23926.79         | 12690.55 |
| 4194304                       | 22584.56     | 23958.53       | 22561.99       | 23950.99         | 13347.54 |

### Latency

| # OSU MPI Latency Test v7.5 |                 |                |                |                  |        |
|-----------------------------|-----------------|----------------|----------------|------------------|--------|
| # Datatype: MPI_CHAR.       | Avg Latency(us) |                |                |                  |        |
| # Size                      | Host to Host    | Host to Device | Device to Host | Device to Device | RCCL   |
| 1                           | 2.30            | 2.44           | 2.42           | 2.54             | 27.08  |
| 2                           | 2.33            | 2.46           | 2.45           | 2.55             | 27.19  |
| 4                           | 2.33            | 2.46           | 2.44           | 2.55             | 27.12  |
| 8                           | 2.32            | 2.46           | 2.43           | 2.56             | 27.11  |
| 16                          | 2.32            | 2.46           | 2.44           | 2.56             | 26.88  |
| 32                          | 2.32            | 2.45           | 2.43           | 2.55             | 26.59  |
| 64                          | 2.33            | 2.44           | 2.45           | 2.56             | 26.58  |
| 128                         | 2.87            | 2.98           | 2.98           | 3.10             | 27.18  |
| 256                         | 2.92            | 3.17           | 3.16           | 3.31             | 26.97  |
| 512                         | 2.95            | 3.26           | 3.25           | 3.43             | 27.17  |
| 1024                        | 3.01            | 3.37           | 3.36           | 3.60             | 27.29  |
| 2048                        | 3.15            | 3.50           | 3.50           | 3.89             | 27.93  |
| 4096                        | 3.26            | 3.66           | 3.65           | 3.93             | 27.96  |
| 8192                        | 3.65            | 3.91           | 3.89           | 4.16             | 28.81  |
| 16384                       | 4.30            | 4.54           | 4.56           | 4.69             | 29.60  |
| 32768                       | 7.68            | 8.06           | 8.01           | 8.37             | 34.27  |
| 65536                       | 9.11            | 9.41           | 9.40           | 9.70             | 39.36  |
| 131072                      | 12.01           | 12.21          | 12.23          | 12.46            | 46.08  |
| 262144                      | 17.79           | 17.80          | 17.77          | 17.80            | 57.84  |
| 524288                      | 29.40           | 29.00          | 28.97          | 28.62            | 82.84  |
| 1048576                     | 52.58           | 51.36          | 51.36          | 50.21            | 116.52 |
| 2097152                     | 98.89           | 96.27          | 96.26          | 93.66            | 194.00 |
| 4194304                     | 191.63          | 186.07         | 186.10         | 180.60           | 379.41 |

***
## Lumi bind mount container

Run with: base_image_libfabric1152_mpich314.sif

The bandwidth and latency numbers of the normal OSU benchmarks seem to be on par with the native ones.
The latency seems to be better for direct GPU to GPU communication for larger messages. 
This is probably a side effect of setting 'MPICH_OFI_NIC_POLICY' to GPU as this selects the NIC closest to the selected GPU.

The containerized version of RCCL also performs similarly to the native RCCL tests with the same bandwidth dip at 8kB.


### Bandwidth

| # OSU MPI Bandwidth Test v7.5 |                  |                |                |                  |          |
|-------------------------------|------------------|----------------|----------------|------------------|----------|
| # Datatype: MPI_CHAR.         | Bandwidth (MB/s) |                |                |                  |          |
| # Size                        | Host to Host     | Host to Device | Device to Host | Device to Device | RCCL     |
| 1                             | 1.68             | 1.64           | 1.47           | 1.44             | 0.11     |
| 2                             | 3.38             | 3.31           | 2.95           | 2.97             | 0.22     |
| 4                             | 6.80             | 6.59           | 5.91           | 5.97             | 0.44     |
| 8                             | 13.59            | 13.20          | 11.82          | 11.91            | 0.90     |
| 16                            | 27.16            | 26.42          | 23.51          | 23.92            | 1.84     |
| 32                            | 54.48            | 52.84          | 47.31          | 47.81            | 3.67     |
| 64                            | 108.85           | 105.88         | 94.49          | 95.44            | 7.02     |
| 128                           | 215.47           | 211.17         | 188.02         | 189.51           | 14.21    |
| 256                           | 461.03           | 418.67         | 399.61         | 400.12           | 29.32    |
| 512                           | 921.09           | 832.11         | 797.99         | 793.63           | 58.09    |
| 1024                          | 1840.29          | 1662.37        | 1597.51        | 1600.26          | 114.49   |
| 2048                          | 3681.29          | 3379.10        | 3188.70        | 3208.08          | 229.57   |
| 4096                          | 7335.22          | 6791.69        | 6375.28        | 6395.59          | 441.05   |
| 8192                          | 14016.36         | 13598.54       | 12210.54       | 12756.46         | 56.36    |
| 16384                         | 17675.59         | 17659.45       | 20218.03       | 20312.42         | 1367.58  |
| 32768                         | 19068.58         | 19088.49       | 19624.61       | 21185.37         | 2198.70  |
| 65536                         | 20939.79         | 21503.02       | 20949.05       | 22616.00         | 3325.54  |
| 131072                        | 21788.14         | 22758.98       | 21932.66       | 23223.52         | 5316.33  |
| 262144                        | 22184.73         | 23372.18       | 22255.27       | 23612.02         | 7181.00  |
| 524288                        | 22378.91         | 23671.90       | 22409.76       | 23810.25         | 8797.02  |
| 1048576                       | 22484.72         | 23833.44       | 22496.70       | 23894.34         | 11730.21 |
| 2097152                       | 22539.26         | 23917.27       | 22537.48       | 23937.09         | 12815.44 |
| 4194304                       | 22564.82         | 23955.67       | 22557.66       | 23961.87         | 13446.30 |

### Latency

| # OSU MPI Latency Test v7.5 |                 |                |                |                  |        |
|-----------------------------|-----------------|----------------|----------------|------------------|--------|
| # Datatype: MPI_CHAR.       | Avg Latency(us) |                |                |                  |        |
| # Size                      | Host to Host    | Host to Device | Device to Host | Device to Device | RCCL   |
| 1                           | 2.35            | 2.40           | 2.41           | 2.45             | 25.81  |
| 2                           | 2.36            | 2.42           | 2.41           | 2.47             | 25.93  |
| 4                           | 2.36            | 2.42           | 2.40           | 2.48             | 25.84  |
| 8                           | 2.37            | 2.43           | 2.41           | 2.48             | 25.85  |
| 16                          | 2.37            | 2.43           | 2.41           | 2.48             | 25.58  |
| 32                          | 2.37            | 2.42           | 2.40           | 2.48             | 25.33  |
| 64                          | 2.36            | 2.43           | 2.40           | 2.48             | 25.29  |
| 128                         | 2.89            | 2.95           | 2.93           | 3.01             | 25.98  |
| 256                         | 2.91            | 3.03           | 3.00           | 3.13             | 25.63  |
| 512                         | 2.92            | 3.10           | 3.09           | 3.24             | 26.31  |
| 1024                        | 2.98            | 3.19           | 3.19           | 3.37             | 26.67  |
| 2048                        | 3.13            | 3.36           | 3.36           | 3.57             | 27.30  |
| 4096                        | 3.25            | 3.51           | 3.51           | 3.81             | 27.73  |
| 8192                        | 3.62            | 3.74           | 3.73           | 3.85             | 28.44  |
| 16384                       | 4.25            | 4.39           | 4.35           | 4.43             | 29.33  |
| 32768                       | 7.64            | 7.81           | 7.79           | 7.93             | 34.12  |
| 65536                       | 9.07            | 9.17           | 9.19           | 9.29             | 39.07  |
| 131072                      | 11.97           | 11.99          | 12.00          | 12.07            | 45.44  |
| 262144                      | 17.75           | 17.56          | 17.57          | 17.43            | 57.38  |
| 524288                      | 29.34           | 28.77          | 28.77          | 28.29            | 81.90  |
| 1048576                     | 52.51           | 51.21          | 51.20          | 49.99            | 115.63 |
| 2097152                     | 98.86           | 96.13          | 96.11          | 93.45            | 191.97 |
| 4194304                     | 191.56          | 185.88         | 185.93         | 180.41           | 375.22 |

***
## Libfabric Hybrid

Run with: base_image_libcxi_libfabric1152_mpich423.sif
Couldn't easily improve the RCCL performance. 

Bandwidth and latency are very similar to the native performance. 
However, RCCL performs poorly and probably defaults back to TCP/IP?
I have not investigated this more thoroughly.

### Bandwidth
| # OSU MPI Bandwidth Test v7.5 |                  |                |                |                  |         |
|-------------------------------|------------------|----------------|----------------|------------------|---------|
| # Datatype: MPI_CHAR.         | Bandwidth (MB/s) |                |                |                  |         |
| # Size                        | Host to Host     | Host to Device | Device to Host | Device to Device | RCCL    |
| 1                             | 1.46             | 1.50           | 1.44           | 1.60             | 0.06    |
| 2                             | 2.92             | 3.00           | 2.87           | 3.23             | 0.12    |
| 4                             | 5.85             | 6.03           | 5.77           | 6.46             | 0.24    |
| 8                             | 11.69            | 12.02          | 11.76          | 12.85            | 0.45    |
| 16                            | 23.34            | 24.12          | 23.38          | 25.77            | 0.90    |
| 32                            | 46.84            | 48.41          | 46.16          | 51.45            | 1.79    |
| 64                            | 92.95            | 96.54          | 91.40          | 100.70           | 3.56    |
| 128                           | 185.61           | 191.30         | 183.28         | 203.18           | 7.25    |
| 256                           | 372.24           | 388.13         | 377.87         | 421.00           | 14.69   |
| 512                           | 744.75           | 775.55         | 777.23         | 839.35           | 28.99   |
| 1024                          | 1489.49          | 1548.60        | 1568.60        | 1678.88          | 62.06   |
| 2048                          | 2972.87          | 3092.74        | 3148.62        | 3340.58          | 120.61  |
| 4096                          | 5954.43          | 6180.79        | 6199.71        | 6676.67          | 232.53  |
| 8192                          | 10668.55         | 10890.77       | 11099.43       | 11811.57         | 460.55  |
| 16384                         | 16264.44         | 16271.64       | 17470.63       | 17558.54         | 729.28  |
| 32768                         | 18773.82         | 18692.92       | 19493.77       | 19321.62         | 1210.57 |
| 65536                         | 20719.38         | 20870.85       | 20933.73       | 22331.02         | 1565.11 |
| 131072                        | 21719.50         | 22635.96       | 21905.46       | 23180.27         | 1953.21 |
| 262144                        | 22197.89         | 23286.78       | 22279.12       | 23591.02         | 2096.12 |
| 524288                        | 22431.40         | 23624.57       | 22462.10       | 23791.44         | 2178.35 |
| 1048576                       | 22548.07         | 23812.49       | 22552.23       | 23879.81         | 2661.74 |
| 2097152                       | 22604.26         | 23905.83       | 22599.39       | 23925.42         | 3056.16 |
| 4194304                       | 22635.83         | 23954.69       | 22621.55       | 23952.45         | 3195.51 |


### Latency

| OSU MPI Latency Test v7.5 |                  |                |                |                  |         |
|---------------------------|------------------|----------------|----------------|------------------|---------|
| # Datatype: MPI_CHAR.     | Bandwidth (MB/s) |                |                |                  |         |
| # Size                    | Host to Host     | Host to Device | Device to Host | Device to Device | RCCL    |
| 1                         | 2.53             | 2.66           | 2.71           | 2.80             | 48.70   |
| 2                         | 2.54             | 2.66           | 2.73           | 2.80             | 48.77   |
| 4                         | 2.53             | 2.66           | 2.77           | 2.80             | 48.69   |
| 8                         | 2.54             | 2.66           | 2.70           | 2.80             | 44.42   |
| 16                        | 2.54             | 2.67           | 2.86           | 2.80             | 44.43   |
| 32                        | 2.54             | 2.66           | 2.86           | 2.80             | 44.16   |
| 64                        | 2.53             | 2.66           | 2.87           | 2.80             | 44.14   |
| 128                       | 3.08             | 3.10           | 3.11           | 3.12             | 44.26   |
| 256                       | 3.15             | 3.24           | 3.26           | 3.34             | 45.51   |
| 512                       | 3.18             | 3.33           | 3.38           | 3.48             | 45.70   |
| 1024                      | 3.24             | 3.39           | 3.40           | 3.54             | 45.36   |
| 2048                      | 3.39             | 3.54           | 3.54           | 3.71             | 45.88   |
| 4096                      | 3.49             | 3.63           | 3.63           | 3.77             | 47.25   |
| 8192                      | 6.40             | 6.80           | 6.82           | 7.25             | 48.51   |
| 16384                     | 7.09             | 7.32           | 7.34           | 7.59             | 63.65   |
| 32768                     | 7.92             | 8.15           | 8.16           | 8.41             | 84.54   |
| 65536                     | 9.63             | 9.52           | 9.54           | 9.72             | 117.92  |
| 131072                    | 12.23            | 12.64          | 12.35          | 12.48            | 181.51  |
| 262144                    | 18.01            | 17.93          | 17.92          | 17.84            | 302.70  |
| 524288                    | 29.56            | 29.12          | 29.12          | 28.65            | 503.78  |
| 1048576                   | 52.68            | 51.79          | 51.49          | 50.54            | 871.89  |
| 2097152                   | 98.90            | 96.37          | 96.61          | 93.88            | 1233.06 |
| 4194304                   | 191.37           | 186.08         | 186.03         | 180.63           | 1929.10 |


***
## Opensource

Run with: base_image_libcxi_libfabric1220_mpich423.sif
Bandwidth and latency is very close to the native performance for large message sizes but worse for small message sizes. 


### Bandwidth

| OSU MPI Bandwidth Test v7.5  |                  |                |                |                  |          |
|------------------------------|------------------|----------------|----------------|------------------|----------|
| # Datatype: MPI_CHAR.        | Bandwidth (MB/s) |                |                |                  |          |
| # Size                       | Host to Host     | Host to Device | Device to Host | Device to Device | RCCL     |
| 1                            | 1.43             | 1.00           | 0.07           | 0.07             | 0.03     |
| 2                            | 2.87             | 2.00           | 0.14           | 0.13             | 0.06     |
| 4                            | 5.71             | 4.01           | 0.27           | 0.27             | 0.11     |
| 8                            | 11.49            | 8.03           | 0.54           | 0.53             | 0.23     |
| 16                           | 22.93            | 16.05          | 1.08           | 1.07             | 0.46     |
| 32                           | 45.98            | 32.11          | 2.17           | 2.14             | 0.92     |
| 64                           | 91.90            | 64.18          | 4.34           | 4.27             | 1.82     |
| 128                          | 182.15           | 125.44         | 8.66           | 8.54             | 3.67     |
| 256                          | 360.05           | 260.59         | 378.86         | 271.91           | 25.40    |
| 512                          | 718.93           | 520.68         | 759.26         | 546.39           | 50.63    |
| 1024                         | 1434.79          | 1038.22        | 1515.67        | 1089.61          | 100.69   |
| 2048                         | 2862.04          | 2072.63        | 3032.47        | 2179.13          | 194.02   |
| 4096                         | 5727.93          | 4123.96        | 6072.05        | 4344.39          | 374.53   |
| 8192                         | 10455.09         | 7625.62        | 11016.58       | 8018.92          | 587.49   |
| 16384                        | 16230.03         | 12800.60       | 17493.16       | 13642.25         | 1139.32  |
| 32768                        | 18746.15         | 16580.44       | 19476.02       | 16534.75         | 2017.60  |
| 65536                        | 20741.79         | 19185.60       | 20928.97       | 20513.81         | 3071.11  |
| 131072                       | 21737.47         | 21627.87       | 21889.16       | 22108.55         | 4980.09  |
| 262144                       | 22184.69         | 22757.22       | 22274.00       | 23007.91         | 6890.97  |
| 524288                       | 22417.82         | 23355.85       | 22448.77       | 23530.24         | 8496.92  |
| 1048576                      | 22536.05         | 23683.30       | 22552.47       | 23742.97         | 11489.69 |
| 2097152                      | 22596.78         | 23837.40       | 22597.25       | 23855.86         | 12618.10 |
| 4194304                      | 22626.56         | 23917.46       | 22620.44       | 23914.85         | 13262.35 |


### Latency

During the running of the latency tests I got the following message multiple times:
- `srun: Job 9813899 step creation temporarily disabled, retrying (Requested nodes are busy)`

Could be the reason for high latency for small messages?




| OSU MPI Latency Test v7.5 |                  |                |                |                  |        |
|---------------------------|------------------|----------------|----------------|------------------|--------|
| # Datatype: MPI_CHAR.     | Bandwidth (MB/s) |                |                |                  |        |
| # Size                    | Host to Host     | Host to Device | Device to Host | Device to Device | RCCL   |
| 1                         | 2.59             | 11.23          | 11.97          | 21.05            | 48.60  |
| 2                         | 2.59             | 11.15          | 12.01          | 21.01            | 48.73  |
| 4                         | 2.59             | 11.20          | 11.74          | 21.02            | 48.59  |
| 8                         | 2.58             | 11.15          | 12.37          | 21.00            | 48.57  |
| 16                        | 2.58             | 11.14          | 11.74          | 21.00            | 48.26  |
| 32                        | 2.59             | 11.15          | 12.03          | 21.01            | 48.02  |
| 64                        | 2.63             | 11.16          | 11.83          | 21.03            | 48.08  |
| 128                       | 3.12             | 11.59          | 11.54          | 21.54            | 48.60  |
| 256                       | 3.19             | 3.34           | 3.37           | 3.52             | 27.58  |
| 512                       | 3.22             | 3.43           | 3.40           | 3.58             | 27.73  |
| 1024                      | 3.29             | 3.43           | 3.48           | 3.59             | 27.87  |
| 2048                      | 3.46             | 3.59           | 3.61           | 3.73             | 28.46  |
| 4096                      | 3.55             | 3.66           | 3.67           | 3.81             | 28.35  |
| 8192                      | 6.49             | 6.90           | 6.88           | 7.32             | 31.00  |
| 16384                     | 7.14             | 7.37           | 7.37           | 7.62             | 31.42  |
| 32768                     | 7.97             | 8.21           | 8.27           | 8.44             | 33.68  |
| 65536                     | 9.68             | 9.57           | 9.61           | 9.79             | 38.63  |
| 131072                    | 12.39            | 12.48          | 12.39          | 12.51            | 45.31  |
| 262144                    | 18.20            | 18.08          | 17.95          | 17.88            | 57.09  |
| 524288                    | 29.81            | 29.17          | 29.27          | 28.73            | 81.68  |
| 1048576                   | 52.89            | 51.86          | 51.55          | 50.26            | 116.05 |
| 2097152                   | 99.13            | 96.48          | 96.74          | 94.21            | 193.36 |
| 4194304                   | 191.76           | 186.25         | 186.09         | 180.67           | 377.31 |


***
***

# Future Work
- GROMACS or similar? https://www.gromacs.org/tutorial_webinar.html
- Speed tests for pytorch
  - real world Pytorch examples would be good
- MPICH with slurm for more options? --> No. MPICH comes with Hydra which supports slurm
- Can we do better than 25GB/s? 
  - Maybe through some slurm configs to select NICs?
- are the pure RCCL tests necessary?
- Do we need to do internode testing?