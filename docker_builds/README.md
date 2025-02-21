Exploring the different options for building a docker image without proprietary libraries. 
This is based on the LUMI docker build files found here:

https://github.com/sfantao/lumi-containers/tree/lumi-sep2024

The main aim is to be able to build docker base images without needing a system similar to LUMI.  
We have a basic image which works on LUMi. However, the interconnects are not properly used. 

# Instructions to reproduce:

## Requirements:
- Docker 
- Python 
  - docker for python
  - rich

1) navigate to docker_builds folder
2) `sudo python3 build_docker.py` builds **3?** different docker containers named:
   - base_image_mpich314_libfabric1152
   - base_image_mpich343_libfabric1152
   - base_image_mpich422_libfabric1152
   - base_image_mpich422_libfabric1220_cxi_opensource
3) Each container has to be converted to an apptainer container via `sudo apptainer build $TARGET docker-daemon:lumi_images:$SOURCE`
   - where $SOURCE and $TARGET have to be:
     - base_image_mpich314_libfabric1152 & base_image_mpich314_libfabric1152.sif 
     - base_image_mpich314_libfabric1152 & base_image_mpich314_libfabric1152.sif 
     - base_image_mpich314_libfabric1152 & base_image_mpich314_libfabric1152.sif 
     - base_image_mpich314_libfabric1152 & base_image_mpich314_libfabric1152.sif
4) Each of the sif files has to be copied over to lumi via your preferred method e.g. `scp base_image_mpich314_libfabric1152.sif /project/project_XXXXXX/`
5) Copy all the .sh scripts in the 'tests' folder. (Optional: native folder)
6) Optional: Build native osu benchmark suit. See instructions HERE
7) sbatch run_xxxx.sh
8) Look at the resulting txt files. 

# Note:
- https://github.com/apptainer/apptainer/issues/282 
  - There is an issue on Apptainer that would auto find and mount the host MPI libraries into a container. However, no work has been done on this since 2022 and the issue is still open.
- Finding the correct MPI libraries to bindmount into a container. Checkout https://github.com/E4S-Project/e4s-cl
  - The e4s-cl seems like an interesting tool. It can be installed via Spack. 
  - Its essentially a launcher for MPI workloads with containers. It can probably be used with Apptainer and it seems to be helpful for getting all required MPI libraries? 
  - https://e4s-project.github.io/e4s-cl.html 
  - Demo looks super easy

# step-by-step
1. Basic Container - DONE
2. Native Runs - DONE
3. Lumi bind mount container - DONE
4. Libfabric Hybrid container
5. Link GTL into lumi bind mount - DONE
6. Link GTL into libfabric hybrid container
7. Full Open Source
8. Link GTL into full open source

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
- [ ] Libfarbic hybrid:
  - [ ] bandwidth? 
  - [ ] latency?
  - [ ] Linking GTL with libfabric Hybrid setup?
    - [ ] is there a latency difference?
    - [ ] Is there a bandwidth difference?
- [ ] Full Open Source
  - [ ] bandwidth? 
  - [ ] latency?
  - [ ] Linking GTL with libfabric Hybrid setup?
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
- [X] Device-device NCCL bandwidth tests

#### NCCL latency test
- [X] Device-device NCCL latency tests

***
***
### Lumi bind mount:
#### Bandwidth tests
- [X] host-host OSU bandwidth test
- [X] device-host OSU bandwidth test
- [X] host-devices OSU bandwidth test
- [X] device-device OSU bandwidth test

#### Latency tests
- [X] host-host OSU Latency test
- [X] device-host OSU Latency test
- [X] host-devices OSU Latency test
- [X] device-device OSU Latency test

#### NCCL bandwidth test
- [X] device-device NCCL bandwidth tests

#### NCCL latency test
- [X] device-device NCCL latency tests

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
***
### Full open source:

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


# Definition of basic, lumi bind etc.


# Compatability:
- base: mpich 3.4.3 & libfabric 1.15.2, mpich 3.1.4 & libfabric 1.15.2; TODO: mpich 4.2.2??
- lumi_bind: mpich 3.4.3 & libfabric 1.15.2, mpich 3.1.4 & libfabric 1.15.2 (No MPICH above v4 due to ABI compatability)
- libfabric_hybrid: TODO: mpich 4.2.2 & libfabric 1.15.2; mpich 4.2.2 & libfabric 1.21.1 WITHOUT CXI (No libfabric version 1.21.1 or 1.22.0 due to compatibility between mpich and libfabric. MPICH <4 seems to result in issues with CXI provider.) 
- opensource: libcxi & mpich 4.2.2 & libfabric 1.22.0; libcxi & mpich 4.2.2 & libfabric 1.21.1; TODO: libcxi & mpich 4.2.2 & libfabric 1.15.2


## Basic
We take the container as is, with MPICH, libfabric etc. 
Nothing gets bind mounted and the communication should run via TCP IP.

The versions used for each library can be reviewed in [Dockerfile.define_versions](common_docker_defs/Dockerfile.define_versions).

### Compatability:
- 

***

## Native
module load LUMI/24.03
module load craype-x86-trento
module load PrgEnv-amd
module load craype-accel-amd-gfx90a
module load rocm
module load EasyBuild-user
eb aws-ofi-rccl-17d41cb-cpeGNU-24.03.eb -r
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/users/$USER/EasyBuild/SW/LUMI-24.03/L/aws-ofi-rccl/17d41cb-cpeGNU-24.03/lib/:/users/$USER/EasyBuild/SW/LUMI-24.03/L/aws-ofi-rccl/17d41cb-cpeGNU-24.03/lib64/
- CC=cc CXX=CC ./configure --enable-rocm --with-rocm=/opt/rocm-6.0.3 --enable-rcclomb --with-rccl=/opt/rocm-6.0.3 --prefix=/project/project_465001699/julius/osu/build_osu
- make install

**NOTE:** 
For native bandwidth tests with GPUs, the GTL needs to be linked in, and you need to set 'export MPICH_GPU_SUPPORT_ENABLED=1'.
GTL should be automatically linked when 'module load craype-accel-amd-gfx90a'. 
Otherwise, you get errors. You can check if the GTL is linked with 'ldd' and the library is 'libmpi_gtl_hsa.so.0 => /opt/cray/pe/lib64/libmpi_gtl_hsa.so.0'.
- 'export NCCL_IGNORE_CPU_AFFINITY=1' Leads to almost 4x improvement.


***
## Lumi Bind
Take Basic container and replace libfabric, MPICH, Rocm and a bunch of other files. The details are in: 
[run_lumi_bind_bandwidth_and_latency_tests.sh](tests/lumi_bind/run_lumi_bind_bandwidth_and_latency_tests.sh)

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
Debugging can be turn on by uncommenting lines 99 and 100 in [run_lumi_bind_rccl_bandwidth_and_latency_tests.sh](tests/lumi_bind/run_lumi_bind_rccl_bandwidth_and_latency_tests.sh)

### Compatability:
- 

***
## Libfabric Hybrid
Take Basic container and replace and **ONLY** replace libfabric.

### Compatability:
- libcxi + libfabric 1.21.1 + MPICH 4.2.2 -->  DOESNT WORK (bind mounting lumi libfabric leads to ' version `FABRIC_1.7' not found' --> TRUE? Check without CXI!)
- libcxi + libfabric 1.22.0 + MPICH 4.2.2 --> DOESNT WORK
- libcxi + libfabric 1.22.0 + MPICH < 4 --> ??? DOESNT WORK; leads to incompatability with libcxi on the MPICH side.
- libfabric 1.22.0 + MPICH < 4 --> ???? DOESNT WORK; leads to incompatability with libcxi on the MPICH side.
- libfabric 1.22.0 + MPICH 4.2.2 --> ????
- libfabric 1.15.2 + MPICH 4.2.2 --> ???


***
## Opensource:

### Compatability:

Notes:
- libfabric 1.21.1 + MPICH 4.2.2 -->  WORKS
- libfabric 1.22.0 + MPICH 4.2.2 --> WORKS
- libfabric 1.15.2 + MPICH 4.2.2 --> DOESNT WORK; libfabric --enable-cxi --> not available
- libfabric 1.22.0 + MPICH < 4 --> DOESNT WORK; leads to incompatability with libcxi. 


***
***

# Results

## Basic container

- TCP/IP sockets are used for RCCL comms
- MPICH_RELEASE=3.4.3 and LIBFABRIC_RELEASE=1.22.0 lead to very poor performance on normal MPICH comms. About 7x slower. 
- MPICH version > 4 seems to lead to better results again (but did not check libfabric version)

- libfabric 1152 & mpich 314 --> fast, rccl works but much slower
- libfabric 1152 & mpich 343 --> slow, so slow rccl doesnt work????
- libfabric 1211 & mpich 343 --> slow, device also super slow, rccl so slow doesnt work????
- libfabric 1152 & mpich 422 --> fast, devices are 1/5th speed but works, rccl so slow doesnt work????
- libfabric 1211 & mpich 422 --> fast, devices are 1/5th speed but works, rccl so slow doesnt work????
- libfabric 1220 & mpich 422 --> fast, devices are 1/5th speed but works, rccl so slow doesnt work????


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

The bandwidth and latency numbers of the normal OSU benchmarks seem to be on par with the native ones.
The latency seems to be better for direct GPU to GPU communication for larger messages. 
This is probably a side effect of setting 'MPICH_OFI_NIC_POLICY' to GPU as this selects the NIC closest to the selected GPU.

The containerized version of RCCL also performs similarly to the native RCCL tests with the same bandwidth dip at 8kB.

- libfabric 1152 & mpich 314 --> 22GBs, rccl half speed
- libfabric 1152 & mpich 343 --> 22GBs, rccl half speed
- libfabric 1211 & mpich 343 --> 22GBs, rccl 5GBs
- libfabric 1220 & mpich 343 --> 22GBs, rccl 5GBs
- libfabric 1152 & mpich 422 --> 22GBs, rccl 13GBs
- libfabric 1211 & mpich 422 --> 22GBs, rccl 3GBs
- libfabric 1220 & mpich 422 --> 22GBs, rccl 3GBs
- libcxi & libfabric 1152 & mpich 343 --> 
- libcxi & libfabric 1152 & mpich 422 --> 
- libcxi & libfabric 1211 & mpich 422 -->
- libcxi & libfabric 1220 & mpich 422 --> 

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

- libfabric 1152 & mpich 314 --> Works; fallback to TCP/IP --> not compiled with channel 4
- libfabric 1152 & mpich 343 --> FAILS; This MPICH doesnt play well with libcxi??? (open_fabric:No data available)
- libfabric 1211 & mpich 343 --> FAILS; MPICH expects higher fabric version
- libfabric 1220 & mpich 343 --> FAILS; MPICH expects higher fabric version
- libfabric 1152 & mpich 422 --> 22GBs; **GPU comms very slow even with GTL?** Can be fixed?
- libfabric 1211 & mpich 422 --> FAILS; MPICH expects higher fabric version
- libfabric 1220 & mpich 422 --> FAILS; MPICH expects higher fabric version
- libcxi & libfabric 1152 & mpich 343 --> FAILS; This MPICH doesnt play well with libcxi (open_fabric:No data available)
- libcxi & libfabric 1152 & mpich 422 --> 22GBs; **GPU comms very slow even with GTL?** Can be fixed?
- libcxi & libfabric 1211 & mpich 422 --> FAILS; MPICH expects higher fabric version
- libcxi & libfabric 1220 & mpich 422 --> FAILS; MPICH expects higher fabric version


### Bandwidth

### Latency


***
## Opensource
- libcxi & libfabric 1152 & mpich 343 --> FAILS; (open_fabric:No data available)
- libcxi & libfabric 1152 & mpich 422 --> FAILS; (open_fabric:No data available)
- libcxi & libfabric 1211 & mpich 422 --> 22GBs; GPU SLOW even with LD_PRELOAD GTL
- libcxi & libfabric 1220 & mpich 422 --> 22GBs; GPU SLOW even with LD_PRELOAD GTL




### Bandwidth

### Latency

# Conclusion


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