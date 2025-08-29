# CuPy + mpi4py open source container
- **Keywords:** Container, mpi4py, cupy, open source, MPI, MPICH, osu
- **Date:** 2025-07-24
## Description
This BitBullDozer is a continuation of the [LUMI-C OSU mpi4py benchmarks](https://github.com/DeiC-HPC/cotainr/tree/2025.7.1/examples/LUMI/conda_mpi4py_mpich) example, where we will accomplish the following steps:
- Build a mpi4py container based on the open source containers from the docker build [BitBullDozer](https://github.com/DeiC-HPC/BitBulldozersLab/tree/explore/docker_builds/Docker%20build%20pipeline%20for%204%20different%20container%20approaches%20on%20LUMI)
- Perform the OSU Benchmark and analyse the MPI performance of the mpi4py container
- Build a container with both cupy and mpi4py
- Perform the OSU Benchmark and analyse the MPI performance of the cupy + mpi4py container
- Perform intra-node GPU-to-GPU Benchmark and analyse performance of CuPy.
- Discussion of the settings, tunings, etc. needed for building a container for GPU-GPU MPI communication on LUMI.
- A Jupyter notebook presenting an analysis of the test and benchmark results
The builds and discussions are found in this README and the benchmark performance are shown in the `lumi-g_mpi4py_osu_results.ipynb`  and `lumi-c_mpi4py_osu_results.ipynb` notebooks.

## Reproduction
This BitBulldozersLab requires the two following **open source** base containers created in the docker build [BitBullDozer](https://github.com/DeiC-HPC/BitBulldozersLab/tree/explore/docker_builds/Docker%20build%20pipeline%20for%204%20different%20container%20approaches%20on%20LUMI)
- `base_image_libcxi_libfabric2000_mpich423.sif`
- `base_image_libcxi_libfabric1220_mpich423.sif`
In this BitBulldozer they are put in
- `containers/base_images/opensource_base_image_libcxi_libfabric2000_mpich423.sif`
- `containers/base_images/opensource_base_image_libcxi_libfabric1220_mpich423.sif`

With these containers in place, the complete environment containing test method containers and the OSU benchmark can be setup using the `reproduce-environment.sh` script (On Lumi only). This script calls `containers/build_container.sh` to build the 8 test method containers which takes approximately 80 minutes.

The benchmark tests can then be submitted via Slurm on LUMI using the run scripts found in `run-scripts/` which dumps the output results in `results/`. Note that some of the data requires cleaning before processing. This is done by running `sed -i '/source/d' results/*.txt` which deletes in-place all lines containing the string 'source' from the output files.

## Discussion
The CPU container using the external MPICH displays superior inter-node performance as it has been compiled in the container with cxi support, and thus displays numbers closer to slingshot performance. In terms of intra-node performance it is seen to be generally equal or slightly worse than the pip/conda pre-compiled binaries for some message sizes.

The libfabric 1.22.0 have slightly better performance than libfabric 2.0

When we compare the LUMI-C results of this BitBulldozer to those in the  [LUMI-C OSU mpi4py benchmarks](https://github.com/DeiC-HPC/cotainr/tree/2025.7.1/examples/LUMI/conda_mpi4py_mpich)  we find equal or slightly better multi-node performance and significantly worse single-node performance compared to bind-mounting, cray optimized mpi4py as well as the LUMI sif image. This is the case for all-gather, bandwidth as well as latency. The multi-node performance (in addition to debugging info) illustrates that we properly utilize the cxi communication layer to enable Slingshot. However, the discrepancy between the intra-node performance is quite different. The optimized Cray-MPICH has an optimization enabled by default which causes it to circumvent the libfabric layer entirely and probably uses shared memory features of the node. This behavior can be turned off using a cray-MPICH specific debug flag `MPICH_SINGLE_HOST_ENABLED=0` [3], which makes it comparable to the open source MPICH. This does not work straight away due to the Slurm configuration on LUMI, so we furthermore has to pass the slurm flag `--network=single_node_vni` provided to `srun` to get libfabric to properly utilize `cxi` in a single node job.
When we attempt a similar approach with the MPICH in the open source container the flag `--network=single_node_vni` is not sufficient to run `cxi`, and it is not currently clear what configuration is required. We attempted to use the `shm` shared memory provider, however this did not work straight away.

The OSU Python benchmarks can be changed to run inter-node GPU to GPU communication by changing the buffer flag to `--buffer=cupy` which will allocate cp.arange array on one node and transfer it to the other node in a bandwidth test. The performance increases close to 24GB/s, thus reaching the performance of the "bind-mount", "cray-python" and "lumi-sif" methods. This is understandable given the hardware layout of the LUMI-G node, where the NICs are attached to the GPUs in the node. In order to achieve this performance we require GPU-to-GPU RDMA . This is referred to as HMEM and can be activated in the job script through the flag "MPIR_CVAR_CH4_OFI_ENABLE_HMEM" (see [1] for flag descriptions).
The GPU intra-node bandwidth performance of the OSU Python benchmark is very fast, where we reach bandwidth speeds upwards of 140GB/s out of the 200GB/s hardware spec. These large further exaggerate the difference between libfabric 1.22 and 2.0 where 1.22 is clearly faster. 

## Issues
When using the `MPIR_CVAR_CH4_OFI_ENABLE_HMEM` flag, we do get an error in using "DMABUF" memory translation
`libfabric:65622:1753693496::core:core:rocr_is_dmabuf_supported():1134<info> DMABUF support: could not open kernel conf file /boot/config-5.14.21-150500.55.49_13.0.56-cray_shasta_c error`
This can be fixed by either bind-mounting this kernel file from /boot/ or we can disable dmabuf using `FI_HMEM_ROCR_USE_DMABUF=0`, however it affects performance very little.

In order to use CuPy we required the very newest version for compatibility with Cython 3.1 [4]

The docker to singularity conversion of the base container must be done with `--fix-perms` in order to properly build the containers in this BitBulldozersLab. [5]

The CuPy recipe requires environment variables in order to compile CuPy correctly, even though the variable are added to the conda environment file (.yml), they are not use and has to be defined manually as cotainr works currently.
# Summary

- CuPy + mpi4py open source container achieve:
	- Peak multi-node performance on both LUMI-C and LUMI-G (numpy and cupy buffer)
	- Suboptimal single-node performance on the LUMI-G and bad performance on LUMI-C (sockets)
- The Conda `mpich` package can only use Slingshot if it utilizes the `external_` MPICH installation
- Libfabric version 1.22 has better CPU-CPU multi-node performance then version 2.0
- Potentential optimization path is to enable the cxi provider in single-node jobs to match that of cray-mpich

# Links
- [1] Descriptions of MPICH flags: https://fossies.org/linux/mpich/README.envvar
- [2] Descriptions of libfabric cxi flags: https://github.com/ofiwg/libfabric/blob/867c15e520c027b7872783a80a59470bf482473c/man/fi_cxi.7.md?plain=1#L440
- [3] Cray-MPICH flags: https://cpe.ext.hpe.com/docs/24.03/mpt/mpich/intro_mpi.html#general-mpich-environment-variables
- [4] https://github.com/cupy/cupy/issues/9128
- [5] https://github.com/DeiC-HPC/cotainr/issues/52#issuecomment-1918652234 