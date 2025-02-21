# Building the LUMI PyTorch container using cotainr

- **Keywords:** Pytorch, Container, AI, Cotainr
- **Date:** 2025-02-21

The PyTorch v2.3.1 container based on ROCm 6.0.3 on LUMI (i.e. `/appl/local/containers/tested-containers/lumi-pytorch-rocm-6.0.3-python-3.12-pytorch-v2.3.1-dockerhash-2c1c14cafd28.sif`) is custom built with a variety of custom wheels and source code from special ROCm repositories as defined in the Dockerfile in https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.0.3-python-3.12-pytorch-v2.3.1.docker.

This repo attempts to build a similar container using a conda_env.yml file and cotainr, the test-container is built using the command in `build.txt`.

## Running this BitBulldozer
We first `git clone https://github.com/DeiC-HPC/BitBulldozersLab.git` this repo to LUMI.
This repo used the 2023.11.0 cotainr release, which is included in this repo as a submodule. It is an empty folder by default, and requires initialization 
```
$ git submodule init
$ git submodule update
```
Before we are ready to run `cotainr` we need to have a sufficiently recent Python executable, so we run
```
module load cray-python
```
Then, we are ready to test various packages, the neccesary commands are included in `build.txt` which copy-pasted and run. Note, that in order to get the unfiltered error message from `cotainr`, we have to change the following line
```diff
cotainr/cotainr/container.py#L258
- [line for line in e.stderr.split("\n") if line.startswith("FATAL")]
+ [line for line in e.stderr.split("\n")]

```
The success library most closely resembling the [Container by Samuel](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.1.3-python-3.12-pytorch-v2.4.1.docker), is run via
```
cotainr/bin/cotainr build --base-image /appl/local/containers/sif-images/lumi-rocm-rocm-6.1.3.sif --conda-env conda_env_success.yml test.sif -vv --accept-licenses
```
Some basic import tests of key libraries result in the following warnings:
```
Singularity> python
Python 3.12.8 | packaged by conda-forge | (main, Dec  5 2024, 14:24:40) [GCC 13.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import torch
>>> import deepspeed
[2025-02-05 11:40:34,904] [WARNING] [real_accelerator.py:162:get_accelerator] Setting accelerator to CPU. If you have GPU or other accelerator, we were unable to detect it.
[2025-02-05 11:40:34,965] [INFO] [real_accelerator.py:203:get_accelerator] Setting ds_accelerator to cpu (auto detect)
>>> import bitsandbytes
/opt/conda/envs/conda_container_env/lib/python3.12/site-packages/bitsandbytes/backends/cpu_xpu_common.py:29: UserWarning: g++ not found, torch.compile disabled for CPU/XPU.
  warnings.warn("g++ not found, torch.compile disabled for CPU/XPU.")
```

## Library removal concerns
After installation of all the packages, the _Conda_ libstc++.so library  is explicitly [removed](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/common/Dockerfile.no-torch-libstdc%2B%2B) from the official LUMI PyTorch container to ensure the container C++ library is used. This might or might not be an issue for portability of the container depending on how the base container is built. It nevertheless is an issue for the cotainr method as it doesn't support modifying the container post-install. This is done in all versions of the docker script. Note: There are similar concerns for ROCm>=6.1.3 versions (without LLVM), where the ROCm libraries from the PyTorch installation are removed.

## Writing pip commands in conda-env
Writing pip commands to a Conda environment can be quite advanced, see [here](https://github.com/conda/conda/blob/main/tests/env/support/advanced-pip/environment.yml) for various examples of allowed notation. However, the formatting for installing packages on GitHub has undergone several iterations through the last few years, and as such, the notation in `conda-env.yml` is quite strongly dependent on the specific version of `pip`. See for example [here](https://github.com/pypa/pip/pull/11617). The current (pip version 25.0) supported per-requirement options are listed [here](https://pip.pypa.io/en/latest/reference/requirements-file-format/#per-requirement-options), although one may also get warnings that the `--global-option` was depricated in 24.2.

## Conda yaml deficiencies
The attempted cotainr build with `conda_env.yml` in this repo failed, whereas the cotainr build with `conda_env_ref.yml` and subsequent manual installing the `pip install apex @ git+https://github.com/rocm/apex` does succeed. The reason for this failure is described [here](https://github.com/astral-sh/uv/issues/1715) as:

_A number of machine learning-related modules Flash-attn, NVidia Apex need pytorch to be installed before they are installed, so that they can do things like compile against version of pytorch currently installed in the user's environment._

_You might think that these modules should declare that they depend upon Pytorch at setup time in their pyproject.toml file, but that isn't a good solution. No one wants a newly installed Pytorch version, and they might have installed pytorch using Conda or some other mechanism that pip isn't aware of. And these modules want to just work with whatever version of pytorch is already there. It would cause a LOT more problems than it would solve._

Essentially, the package `Apex` **needs** to be built with `--no-build-isolation` after PyTorch is installed in a two-step process. However, because conda installs all requested dependencies at once using a generated `requirements.txt` file it would be impossible without additional steps. This could possibly be accomplished by allowing separately pip installing a `requirements.txt` after the conda installation like suggested in this [PR](https://github.com/DeiC-HPC/cotainr/pull/55). We would need to be careful that the pip installation properly uses the conda environment. Note, that this issue is not unique to the ROCm branch, but is required with Nvidia as well.

## Results summary
The following table summarizes pip-installable packages, for which pre-compiled wheels are either not available or possible.

| Partial Failure | Failure         |
| --------------- | --------------- |
| Deepspeed       | Apex            |
| Bitsandbytes    | Flash-Attention |

The 2 major failing modes are pip dependency resolution and explicit compilation required:
- As Conda attempts to build the example wheels for `conda_env_apex.yml`, it fails when attempt to resolve dependencies leading to the following error. As described in previously, this is not an ordinary dependence, but a required pre-installed module. Even if pip proceeded the installation, there are [no way to determine the installation order](https://pip.pypa.io/en/stable/cli/pip_install/#installation-order) beyond the regular "dependency" commitment. 
```pip
> Running command git clone --filter=blob:none --quiet https://github.com/rocm/apex /tmp/pip-install-lqtpscb5/apex_def0b5a2399747bab333ceb1934b5a9a           
> Running command git submodule update --init --recursive -q
× Getting requirements to build wheel did not run successfully.
  │ exit code: 1
  ╰─> ModuleNotFoundError: No module named 'torch'
``` 
- The partial failure of Deepspeed is summarized in `deepspeed-env_report.md`. Pip installation is successful, however, this is without the hardware acceleration from no C++/CUDA/hip ops (extensions). These ops need to be [compiled against PyTorch](https://www.deepspeed.ai/tutorials/advanced-install/#pre-install-deepspeed-ops) like the previous point.
- Bitsandbytes is slightly different, here `torch` is labelled as an explicit dependency. There is [alpha releases](https://huggingface.co/docs/bitsandbytes/main/en/installation?backend=AMD+ROCm&platform=Linux#multi-backend-pip) for pre-compiled binary builds, which does successfully install. We note that these are only compatible with `rocm≥6.1` and thus the target container is changed from [rocm6.0.3 build](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.0.3-python-3.12-pytorch-v2.3.1.docker) to [rocm6.1.3 build](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.1.3-python-3.12-pytorch-v2.4.1.docker).

