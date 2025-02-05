# Guix

Guix as package manager for HPC has significant community support https://hpc.guix.info/ which is supported by 4 research french institutes and is deployed on several medium and large scale HPC facilities. It seems to be an extremely interesting and active project for reproducible environments in HPC without compromising performance. It is [stronly recommended](https://doi.org/10.1016/j.cosrev.2024.100655) as a superior solution to traditional package managers (apt-get, pip, conda) as well as container technology (Apptainer/singularity).

However, It does not look like the most user-friendly project as it builds on the fairly advanced GNU Guix project and cannot be installed in userspace. here we describe the user experience in installing Guix on a laptop as well as building a OpenMPI container on said laptop that reach 24GB/s bandwidth on LUMI.

# Guix on a laptop
We install the guix package manager on this Debian derivative (Linux Mint), through the ordinary `apt` package manager 
```
$ sudo apt install guix
```
see [here](https://guix.gnu.org/manual/en/html_node/Binary-Installation.html) for alternative methods. Then we add the HPC community channel to the Guix package manager in a user specific config file
```
$ mkdir ~/.config/guix
$ touch ~/.config/guix/channels.scm
```
where the content of `channels.scm` is [added](https://guix.gnu.org/manual/en/html_node/Specifying-Additional-Channels.html)
```
;; Add variant packages to those Guix provides.
(append
  (list (channel
          (name 'guix-hpc)
          (url "https://gitlab.inria.fr/guix-hpc/guix-hpc.git")
          (branch "master")))
  %default-channels)
```
We are now ready to download code from the newest packages that are in the standard guix channel as well as the guix-hpc channel. This takes a significant amount of time.
```
$ guix pull
```
Once it completes, we are ready to build the application container with the OSU benchmark following this [blog post](https://hpc.guix.info/blog/2024/11/targeting-the-crayhpe-slingshot-interconnect/). 

# LUMI OpenMPI benchmark with guix
First we find the desired benchmark using the search function
```
$ guix search osu benchmark
name: osu-micro-benchmarks
version: 7.4
outputs:
+ out: everything
systems: x86_64-linux
dependencies: openmpi@4.1.6
location: guix-hpc/packages/benchmark.scm:122:2
homepage: https://mvapich.cse.ohio-state.edu/benchmarks/
license: Modified BSD
synopsis: Benchmarking suite from the MVAPICH project  
description: Microbenchmarks suite to evaluate MPI and PGAS (OpenSHMEM, UPC, and UPC++) libraries for CPUs and GPUs.
relevance: 22

name: osu-micro-benchmarks-rocm
version: 7.4.rocm6.2.2
...
```
and find that a recipe for the desired benchmark `osu-micro-benchmarks` in the guix-hpc channel can be readily installed. Note, we also find other relevant packages such as the osu benchmark with rocm from the amd channel. This also takes a significant amount of time and CPU resources the first time, and should be done while the laptop is not needed for other work,
```
$ guix pack -RR -S /etc=etc -S /bin=libexec/osu-micro-benchmarks osu-micro-benchmarks
...
/gnu/store/...-osu-micro-benchmarks-tarball-pack.tar.gz
```
where `-RR` makes it so that the reproducible package can be extracted anywhere in the filesystem, and `-S` creates convenient symlinks into the container. Once the build is done it can be moved to the destination cluster (in this case LUMI)
```
scp /gnu/store/...-osu-micro-benchmarks-tarball-pack.tar.gz <username>@lumi.csc.fi:/project/project_46xxxxxxx/guix-mpi-benchmark/osu-micro-benchmarks-tarball-pack.tar.gz
```
We then extract the archive and run it using the run-script `run.sh` in this repository
```
tar xf osu-micro-benchmarks-tarball-pack.tar.gz
sbatch run.sh
```
We wait for the job to finish
```
$ cat slurm-1234567.out

# OSU MPI Bandwidth Test v7.4
# Datatype: MPI_CHAR.
# Size      Bandwidth (MB/s)
1                       2.61
2                       5.05
4                       9.76
8                      20.83
16                     40.88
32                     80.42
64                    163.22
128                   331.06
256                   619.35
512                  1245.41
1024                 2486.30
2048                 4948.07
4096                 9604.93
8192                16548.43
16384               19886.32
32768               21860.50
65536               22973.41
131072              23512.99
262144              23801.05
524288              23932.28
1048576             24000.58
2097152             24032.06
4194304             24047.72
```

# Additional insights
## Modifying packages
The default osu benchmark is built against OpenMPI version 4.1.6, suppose we want to build against a newer version, we can find the available versions
```
$ guix search openmpi
name: openmpi
version: 5.0.6
[...]

name: openmpi
version: 4.1.6
[...]
```
where we see OpenMPI version 5.0.6 is already built. We can use this version by appying a package transformation as write
```
$ guix pack -RR -S /etc=etc -S /bin=libexec/osu-micro-benchmarks osu-micro-benchmarks --with-input=openmpi=openmpi@5.0.6
```
we note this will complete very fast as the previous packages are all cached, and only the new openmpi version needs to be built.

## Containerization
The packages contain a lot of files, and this can be an issue in large scale HPC facilities using Lustre filesystem. We can get around this by building instead a squashfs image of the container
```
$ guix pack -RR -S /etc=etc -S /opt=libexec/osu-micro-benchmarks -S /bin=bin -f squashfs bash osu-micro-benchmarks
```
Note, `bash` is a required package for `singularity`. To Lustre, this squashfs is one big file, thus getting around the issue of many-small-files. This can then be run on the HPC facility using `singularity run` or `singularity exec`.

Note, symlinks to directories outside the root of the image, such as those in /gnu/store, are not automatically included. To include symlinks successfully, you need to ensure that the target directories exist within the root of the image.
If you need to start singularity in shell mode the 'bin' folder needs to be symlinked. 

We can launch the singularity container with:

```
$ sbatch run_singularity_osu.sh
```

We can also run the OSU RCCL tests with:

```
$ sbatch run_singularity_osu_rccl.sh
```

However, the bandwidth is poor (~1GB/s).
