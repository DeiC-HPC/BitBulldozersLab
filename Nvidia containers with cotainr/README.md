# Building Nvidia PyTorch containers using cotainr

- **Keywords:** Pytorch, Container, AI, Cotainr, Nvidia
- **Date:** 2025-07-17

# Requirements:
- Podman (v4.9.6-dev)
- apptainer (v1.4.1)
- [cotainr](https://github.com/DeiC-HPC/cotainr/tree/feature/enhance_conda_env_installation)

# Machine Specs:
- Nvidia RTX 4070
- Nvidia driver: 555.42.06
- CUDA version 12.5

# Nvidia Containers
Nvidia builds a lot of containers for different use cases and provides them via the Nvidia Container repository.
- https://catalog.ngc.nvidia.com/orgs/nvidia/containers

We ran the builds with the following Nvidia HPC container:

## HPC container: 
https://catalog.ngc.nvidia.com/orgs/nvidia/containers/nvhpc/tags
- `export NVIDIA_IMAGE=nvcr.io/nvidia/nvhpc:25.3-devel-cuda12.8-ubuntu24.04`
- `export NVIDIA_IMAGE_NAME=25.3-devel-cuda12.8-ubuntu24.04`

# Basic Container building instructions
Instructions to get a usable `.sif` base container without virtual env.
Start with:
1. `podman pull $NVIDIA_IMAGE` 
2. `podman image save --format oci-archive $NVIDIA_IMAGE > $NVIDIA_IMAGE_NAME.tar`
3. `apptainer build $NVIDIA_IMAGE_NAME.sif oci-archive://$NVIDIA_IMAGE_NAME.tar`

Using `podman save IMAGE_ID -o *.tar` leads to the following error: `bufio.Scanner: token too long`

# Cotainr Builds:

## Building base Pytorch container

Building a base Pytorch 2.6.0 container is no problem.  

1. `export $FINAL_IMAGE_NAME=${NVIDIA_IMAGE_NAME}_base_pytorch2.6.sif`
2. `cotainr build --accept-licenses --base-image  $NVIDIA_IMAGE_NAME.sif --conda-env conda_envs/base_pytorch.yml $FINAL_IMAGE_NAME`
3. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell --nv $FINAL_IMAGE_NAME`

The `--nv` option enable nvidia GPUs. 
Pytorch works without issues, at least when running the [limited test]("Nvidia containers with cotainr/tests/basic_pytorch_GPU_test.py").

## Building final container:

The final container includes among others:

- Pytorch (2.7.0 with Cuda 12.8)
- BitsandBytes (just works. reports torch available.)
- transformers (just works - moved model to GPU.)
- accelerate (configured at runtime with `accelerate config`. See `accelerate-env_report.md`)
- deepspeed (see below)
- Apex (see below)
- Flash attention (see below)
- 

The container can be built with:
1. `export $FINAL_IMAGE_NAME=${NVIDIA_IMAGE_NAME}_final_container.sif`
2. `cotainr build --accept-licenses --base-image  $NVIDIA_IMAGE_NAME.sif --conda-env conda_envs/pytorch_success.yml conda_envs/extensions.yml -v $FINAL_IMAGE_NAME`
3. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell --nv $FINAL_IMAGE_NAME`

### Cotainr addition

In order, to include `apex`, `deepspeed` and `flash attention` that are compiled against the local pytorch extension we had to add an additional feature to cotainr. 
This extension allows for a secondary conda yaml to be passed to cotainr. The secondary environment file is used in a new `conda env update` step. 
The `conda env update` step is specifically intended to install pip packages that depend on other pip packages. Thus, if one your packages depends on pytorch (e.g., flash-attn) you would add the pytorch pip dependencies to the first yaml file and then add flash-attn to the second yaml file.
In theory, the current implementation allows for an unlimited chaining of dependencies via multiple conda environment yamls. 

- [cotainr enhanced gitrepo](https://github.com/DeiC-HPC/cotainr/tree/feature/enhance_conda_env_installation)

#### Including Deepspeed 
Deepspeed does depend on pytorch, however, their implementation allows for JIT compilation. Thus, the deepspeed and pytorch installation does not need to be decoupled. 
One can choose to decouple the two and to pre-compile all ops. For this, we would need to move `deepspeed` into the pip dependeny section of the secondary yaml and set an additional variable in the first step of the conda environment creation (`DS_BUILD_OPS: 1`).
However, this leads to the following error `fatal error: oneapi/ccl.hpp:` which we have not looked into. 
Additionally, decoupling the deepspeed and Pytorch installation requires the manual installation of dependencies, due to the environment variables needed by `apex`, see section below.

#### Including Flash attention
Flash attention depends on pytorch and needs to be installed in the secondary step. 
Furthermore, it also requires the `--no-build-isolation` flag in the conda env yaml in order for the correct finding of torch. 

#### Including Apex
Apex on [conda](https://anaconda.org/conda-forge/nvidia-apex/files) doesnt work, either in the primary or secondary conda environment file. 
Only the pip installation is somewhat successful. However, even with the secondary step, the nvidia-apex installation is painful.
Providing the `--no-build-isolation` flag does not work via pip requirements.txt or the conda environment yml. For all conda environment approaches that do not work see lines 22 to 38 (here)['Nvidia containers with cotainr/conda_envs/extensions.yml')

For the secondary to properly work we need to set a conda environment wide flag in the variables section of the `pytorch_success.yml` (`PIP_NO_BUILD_ISOLATION: 0`).
This flag is baked into the conda environment and needs to be set in the primary conda environment creation step. Enabling this means, that dependencies need to be installed manually. 

## Test


## Problems & concerns
- Multi conda is required to get majority of packages working at appropriate speed
- the `--no-build-isolation` flag is poorly documented and supported as its mostly applicable to niche applications

- setting `PIP_NO_BUILD_ISOLATION: 0` could lead to unintended consequences as dependencies need to be installed manually. 

## Results summary

Apart of Apex and flash-attn the installation process is very smooth.
Even flash-attn is managable, however, the apex installation is not great; especially due to the required conda env wide variable. 
