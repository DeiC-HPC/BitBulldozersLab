#!/bin/bash
module load CrayEnv cotainr

cotainr build mpi4py_libfabric2000_pip.sif --base-image=base_images/opensource_base_image_libcxi_libfabric2000_mpich423.sif --conda-env mpi4py_mpich4_pip.yml --accept-licenses
cotainr build mpi4py_libfabric1220_pip.sif --base-image=base_images/opensource_base_image_libcxi_libfabric1220_mpich423.sif --conda-env mpi4py_mpich4_pip.yml --accept-licenses

cotainr build mpi4py_libfabric2000_conda.sif --base-image=base_images/opensource_base_image_libcxi_libfabric2000_mpich423.sif --conda-env mpi4py_mpich4.yml --accept-licenses
cotainr build mpi4py_libfabric1220_conda.sif --base-image=base_images/opensource_base_image_libcxi_libfabric1220_mpich423.sif --conda-env mpi4py_mpich4.yml --accept-licenses

cotainr build mpi4py_libfabric2000_extmpich.sif --base-image=base_images/opensource_base_image_libcxi_libfabric2000_mpich423.sif --conda-env mpi4py_mpich4_ext.yml --accept-licenses
cotainr build mpi4py_libfabric1220_extmpich.sif --base-image=base_images/opensource_base_image_libcxi_libfabric1220_mpich423.sif --conda-env mpi4py_mpich4_ext.yml --accept-licenses

cotainr build cupy_mpi4py_libfabric2000.sif --base-image=base_images/opensource_base_image_libcxi_libfabric2000_mpich423.sif --conda-env cupy_mpi4py.yml --accept-licenses
cotainr build cupy_mpi4py_libfabric1220.sif --base-image=base_images/opensource_base_image_libcxi_libfabric1220_mpich423.sif --conda-env cupy_mpi4py.yml --accept-licenses

