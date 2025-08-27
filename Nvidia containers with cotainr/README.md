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

1. `export FINAL_IMAGE_NAME=${NVIDIA_IMAGE_NAME}_base_pytorch2.6.sif`
2. `cotainr build --accept-licenses --base-image  $NVIDIA_IMAGE_NAME.sif --conda-env conda_envs/base_pytorch.yml $FINAL_IMAGE_NAME`
3. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell --nv $FINAL_IMAGE_NAME`

The `--nv` option enable nvidia GPUs. 
Pytorch works without issues, at least when running the [limited test]("Nvidia containers with cotainr/tests/basic_pytorch_GPU_test.py").

## Building final container:

The final container includes among others:

- Pytorch (2.7.0 with Cuda 12.8)
- BitsandBytes (works - reports torch available.)
- transformers (works - moved model to GPU.)
- accelerate (configured at runtime with `accelerate config`. See `accelerate-env_report.md` generated with `accelerate env`)
- deepspeed - see below (See `deepspeed-env_report.md` generated with `python -m deepspeed.env_report`)
- Apex - see below (reports torch available. `apex.torch.cuda.is_available()`)
- Flash attention - see below (5 failed tests)

The container can be built with:
1. `export FINAL_IMAGE_NAME=${NVIDIA_IMAGE_NAME}_final_container.sif`
2. `cotainr build --accept-licenses --base-image  $NVIDIA_IMAGE_NAME.sif --conda-env conda_envs/pytorch_success.yml -v $FINAL_IMAGE_NAME`
3. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell --nv $FINAL_IMAGE_NAME`

## Conda
The build fully depends on conda packages. This simplifies the build process in contrast to using a mix of conda and pip based installations. 
However, it also comes with some downsides. Most notably Pytorch does not officially support conda any longer. Thus, if one runs into pytorch issues that are related to the installation there is no official support. 

All packages `just work` when installing them via conda. The cuda versions seem to be picked up properly across all packages.

### Including Deepspeed
The deepspeed extensions have to be JIT compiled. 

### Including Apex

- A lot of Apex functionality has been moved into Pytorch core apparently. (e.g., https://github.com/NVIDIA/apex/issues/818)
  - Major removal of code on May 7th: https://github.com/NVIDIA/apex/pull/1896/files 
  - AMP and DataDistributedParallel seem to have been removed from Apex.
- I cannot get the examples to run at all. The examples have last been updated 6 years ago.

## Test

Importing `torch`, `transformers`, `accelerate`, `BitsandBytes` all report that the GPU is available.
Moving a transformers model to the GPU works (`tests/transformers_gpu_test.py`).

### Deepspeed
The following deepspeed training example works as well: 
https://github.com/deepspeedai/DeepSpeedExamples/tree/master/training/imagenet 
Run:
1. `git clone https://github.com/deepspeedai/DeepSpeedExamples/`
2. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer exec -B ~/nvidia_container/conda/DeepSpeedExamples/ --nv $FINAL_IMAGE_NAME deepspeed --num_nodes=1 --num_gpus=1 ~/nvidia_container/conda/DeepSpeedExamples/training/imagenet/main.py -a resnet18 --deepspeed --deepspeed_config ~/nvidia_container/conda/DeepSpeedExamples/training/imagenet/config/ds_config.json --dummy`


### Apex

Run:
1. `git clone https://github.com/NVIDIA/apex/`
2. `nano apex/examples/imagenet/`
3. add the following line to `def parser()` --> `parser.add_argument('--dummy', action='store_true', help="use fake data to benchmark")`
4. add to line 206:
   ```python
    if args.dummy:
        print("=> Dummy data is used!")
        train_dataset = datasets.FakeData(1281167, (3, 224, 224), 1000, transforms.ToTensor())
        val_dataset = datasets.FakeData(50000, (3, 224, 224), 1000, transforms.ToTensor())
    else:
   ```
   And indent lines 207 to 218 (i.e., train_dataset and val_dataset)
5. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell -B ~/nvidia_container/conda/apex/ --nv $FINAL_IMAGE_NAME`
6. `cd apex/examples/imagenet/`
7. `python main_amp.py --dummy -a resnet18 --b 224 --workers 1 --opt-level O0 .`

DOES NOT WORK DUE TO REMOVAL OF DDP, AMP and FP16_utils from Apex
Other more modern examples and applications of Apex MAY still work!


### flash-attention
Many of the flash-attention tests pass. However, currently 5 fail due to additional packages that are not installed or found - among others `cuda`. 
The tests also seem to be outdated - it relies on Python 3.8.
Run:
1. `git clone https://github.com/Dao-AILab/flash-attention`
2. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell -B ~/nvidia_container/conda/flash-attention/ --nv $FINAL_IMAGE_NAME`
3. `cd ~/nvidia_container/conda/flash-attention/`
4. `python -m pytest -v --maxfail=10 tests/`


## Problems & concerns
- Installation of pip only packages may be challenging.
- Deepspeed extensions are JIT compiled. 
- Apex tests and documentation are out of date. 
- Not sure if all Apex extensions are present in the conda apex installation. 
- Flash-attention tests may be out of date - or the installation does not work 100% correctly. 

- Compatibility between packages may still be an issue as one relies on whatever packages + libraries the conda community provides (e.g., If one needs a certain library + cuda version, that may not be provided by the community). 

## Results summary

Installation is easy and `just works`, however, users may run into trouble when trying to add pip packages. 
Furthermore, there may be issues with apex and flash-attention as I simply cannot run the tests & examples without errors due to out of date repositories. 

-----------------------------------------------------------


# Mixed Pip & Conda installation

Additionally, I tried to install a mixture of conda and pip installation. This results in two conda.yml files that are needed:
[pytorch_success_pip.yml](conda_envs/pytorch_success_pip.yml) and [extensions.yml](conda_envs/extensions.yml)

**WARN: This takes some time and a lot of memory.** 
The container can be built with:
1. `export FINAL_IMAGE_NAME=${NVIDIA_IMAGE_NAME}_final_container.sif`
2. `cotainr build --accept-licenses --base-image  $NVIDIA_IMAGE_NAME.sif --conda-env conda_envs/pytorch_success_pip.yml conda_envs/extensions.yml -v $FINAL_IMAGE_NAME`
3. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell --nv $FINAL_IMAGE_NAME`


### Cotainr addition

In order, to include `apex`, `deepspeed` and `flash attention` that are compiled against the local pytorch extension we had to add a feature to cotainr. This is because there is [no way to determine the installation order](https://pip.pypa.io/en/stable/cli/pip_install/#installation-order) beyond the regular "dependency" commitment.
This extension allows for a secondary conda yaml to be passed to cotainr. The secondary environment file is used in a new `conda env update` step. 
The `conda env update` step is specifically intended to install pip packages that depend on other pip packages. Thus, if one your packages depends on pytorch (e.g., flash-attn) you would add the pytorch pip dependencies to the first yaml file and then add flash-attn to the second yaml file.
In theory, the current implementation allows for an unlimited chaining of dependencies via multiple conda environment yamls. 

- [cotainr enhanced gitrepo](https://github.com/DeiC-HPC/cotainr/tree/feature/enhance_conda_env_installation)

#### Including Deepspeed 
Deepspeed does depend on pytorch, however, their implementation allows for JIT compilation. Thus, the deepspeed and pytorch installation does not need to be decoupled. 
One can choose to decouple the two and to pre-compile all ops. For this, we would need to move `deepspeed` into the pip secondary section of the secondary yaml and set an additional variable in the first step of the conda environment creation (`DS_BUILD_OPS: 1`).
However, this leads to the following error `fatal error: oneapi/ccl.hpp:` which we have not looked into. 
Additionally, decoupling the deepspeed and Pytorch installation requires the manual installation of dependencies, due to the environment variables needed by `apex`, see section below.

#### Including Flash attention
Flash attention depends on pytorch and needs to be installed in the secondary step. 
Furthermore, it also requires the `--no-build-isolation` flag in the conda env yaml in order for the correct finding of torch. 

#### Including Apex

**WARN:**
- A lot of Apex functionality has been moved into Pytorch core apparently. (e.g., https://github.com/NVIDIA/apex/issues/818)
  - Major removal of code on May 7th: https://github.com/NVIDIA/apex/pull/1896/files 
  - AMP and DataDistributedParallel seem to have been removed from Apex.
- I cannot get the examples to run at all. The examples have last been updated 6 years ago.

The pip installation is somewhat successful. However, even with the secondary step, the apex installation is painful.
Providing the `--no-build-isolation` flag does not work via pip requirements.txt or the conda environment yml. For all conda environment approaches that do not work see lines 22 to 38 (here)['Nvidia containers with cotainr/conda_envs/extensions.yml')

For the secondary to properly work we need to set a conda environment wide flag in the variables section of the `pytorch_success_pip.yml` (`PIP_NO_BUILD_ISOLATION: 0`).
This flag is baked into the conda environment and needs to be set in the primary conda environment creation step. Enabling this means, that dependencies need to be installed manually.

Furthermore, we need to set an additional 4 environment variables to build the Cuda and C++ extensions. To speed up the compilation we set a further 2 environment variables. 
For more details see lines 26 to 28 in `pytorch_success_pip.yml`.
For compiling all C++/CUDA extensions, the CPATH has to be modified to identify all headers. Additionally, the linker also has to be updated. This requires creating a new `/etc/ld.so.conf.d/nvidia.conf` file with the correct paths and running `ldconfig`. This needs to be further investigated. 

Apex compilation requires the system cuda (container cuda) and Pytorch cuda to be the same.

## Tests of the conda and pip mixed installation

Importing `torch`, `transformers`, `accelerator`, `BitsandBytes` all report that the GPU is available.
Moving a transformers model to the GPU works (`tests/transformers_gpu_test.py`).

### Deepspeed
The following deepspeed training example works as well: 
https://github.com/deepspeedai/DeepSpeedExamples/tree/master/training/imagenet 
Run:
1. `git clone https://github.com/deepspeedai/DeepSpeedExamples/`
2. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer exec -B ~/nvidia_container/conda/DeepSpeedExamples/ --nv $FINAL_IMAGE_NAME deepspeed --num_nodes=1 --num_gpus=1 ~/nvidia_container/conda/DeepSpeedExamples/training/imagenet/main.py -a resnet18 --deepspeed --deepspeed_config ~/nvidia_container/conda/DeepSpeedExamples/training/imagenet/config/ds_config.json --dummy`


### Apex

Run:
1. `git clone https://github.com/NVIDIA/apex/`
2. `nano apex/examples/imagenet/`
3. add the following line to `def parser()` --> `parser.add_argument('--dummy', action='store_true', help="use fake data to benchmark")`
4. add to line 206:
   ```python
    if args.dummy:
        print("=> Dummy data is used!")
        train_dataset = datasets.FakeData(1281167, (3, 224, 224), 1000, transforms.ToTensor())
        val_dataset = datasets.FakeData(50000, (3, 224, 224), 1000, transforms.ToTensor())
    else:
   ```
   And indent lines 207 to 218 (i.e., train_dataset and val_dataset)
5. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell -B ~/nvidia_container/conda/apex/ --nv $FINAL_IMAGE_NAME`
6. `cd apex/examples/imagenet/`
7. `python main_amp.py --dummy -a resnet18 --b 224 --workers 1 --opt-level O0 .`

Same issue as with the conda only build.

### flash-attention
Many of the flash-attention tests pass. However, currently 5 fail due to additional packages that are not installed or found. 
The tests also seem to be outdated - it relies on Python 3.8.
Run:
1. `git clone https://github.com/Dao-AILab/flash-attention`
2. `APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell -B ~/nvidia_container/conda/flash-attention/ --nv $FINAL_IMAGE_NAME`
3. `cd ~/nvidia_container/conda/flash-attention/`
4. `python -m pytest -v --maxfail=10 tests/`

## Problems & concerns with the conda and pip mixed installation
- Multi conda installation is required to get some of the packages working at appropriate speed.
- The `--no-build-isolation` flag is poorly documented and supported as it's mostly applicable to niche applications (like AI).
  - The UV solution is nice https://github.com/astral-sh/uv/issues/1715
- Setting `PIP_NO_BUILD_ISOLATION: 0` could lead to unintended consequences as dependencies need to be installed manually. 
  - Triple build may be possible & required for both deepspeed with precompiled ops and apex. 
- Not all apex extensions are currently installed via the pip method. 
  - Linker doesn't work for all apex extensions, as libraries and headers are installed by conda into the site-packages folder. 
  - Might have to add additional config files for linker to run and run `ldconfig`.
  - Might also be a problem for the `deepspeed` compilations. I am not sure about the JIT compilation.

## Results summary of the conda and pip mixed installation

Apart from Apex and flash-attn the installation process is very smooth.
Even flash-attn is manageable, however, the apex installation is not great; especially due to dependency issues (conda) and the required environment variable, ldconfig etc. (pip).
The large number and combination of pre-made Nvidia containers makes finding a working container easy. There are even containers with apex pre-installed, however, I am not sure how customization with cotainr would work.  
