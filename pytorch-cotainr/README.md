# Custom PyTorch with additional libraries
The PyTorch container on LUMI are custom built with a variety of custom wheels and source code from
speciala ROCm repositories. An example can be seen on [GitHub](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.0.3-python-3.12-pytorch-v2.3.1.docker).
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

## Library removal concerns
After installation of all the packages, the _Conda_ libstc++.so library  is explicitly [removed](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/common/Dockerfile.no-torch-libstdc%2B%2B) from the container to ensure the container C++ library is used. This might or might not be an issue for portability of the container depending on how the base container is built. It nevertheless is an issue for the cotainer method as it doesn't support modifying the container post-install. This is done in all versions of the docker script. Note: There are similar concerns for ROCm>=6.1.3 versions (without LLVM), where the ROCm libraries from the PyTorch installation are removed.

## Writing pip commands in conda-env
Writing pip commands to a Conda environment can be quite advanced, see [here](https://github.com/conda/conda/blob/main/tests/env/support/advanced-pip/environment.yml) for various examples of allowed notation. However, the formatting for installing packages on GitHub has undergone several iterations through the last few years, and as such, the notation in `conda-env.yml` is quite strongly dependent on the specific version of `pip`. See for example [here](https://github.com/pypa/pip/pull/11617). The current (pip version 25.0) supported per-requirement options are listed [here](https://pip.pypa.io/en/latest/reference/requirements-file-format/#per-requirement-options), although one may also get warnings that the `--global-option` was depricated in 24.2.

## Conda yaml deficiencies
The attempted cotainr build with `conda_env.yml` in this repo failed, whereas the cotainr build with `conda_env_ref.yml` and subsequent manual installing the `pip install apex @ git+https://github.com/rocm/apex` does succeed. The reason for this failure is described [here](https://github.com/astral-sh/uv/issues/1715) as:

_A number of machine learning-related modules Flash-attn, NVidia Apex need pytorch to be installed before they are installed, so that they can do things like compile against version of pytorch currently installed in the user's environment._

_You might think that these modules should declare that they depend upon Pytorch at setup time in their pyproject.toml file, but that isn't a good solution. No one wants a newly installed Pytorch version, and they might have installed pytorch using Conda or some other mechanism that pip isn't aware of. And these modules want to just work with whatever version of pytorch is already there. It would cause a LOT more problems than it would solve._

Essentially, the package `Apex` **needs** to be built with `--no-build-isolation` after PyTorch is installed in a two-step process. However, because conda installs all requested dependencies at once using a generated `requirements.txt` file it would be impossible without additional steps. This could possibly be accomplished by allowing separately pip installing a `requirements.txt` after the conda installation like suggested in this [PR](https://github.com/DeiC-HPC/cotainr/pull/55). We would need to be careful that the pip installation properly uses the conda environment. Note, that this issue is not unique to the ROCm branch, but is required with Nvidia as well.

## Cotainr dependency error
As Conda attemps to build the example wheels for `conda_env_apex.yml`, it fails when attempt to resolve dependencies leading to the following error (in short)
```pip
> Running command git clone --filter=blob:none --quiet https://github.com/rocm/apex /tmp/pip-install-lqtpscb5/apex_def0b5a2399747bab333ceb1934b5a9a
> Running command git submodule update --init --recursive -q
× Getting requirements to build wheel did not run successfully.
  │ exit code: 1
  ╰─> ModuleNotFoundError: No module named 'torch'
```
As described in previously this is expected for some Python packages. The following table summarizes other packages which fail identically.


| Partial Failure | Failure         |
| --------------- | --------------- |
| Deepspeed       | Apex            |
|                 | Flash-Attention |

Note, the partial failure of Deepspeed is summarized in `deepspeed-env_report.md`. Pip installation is succesful, however, this is without the hardware acceleration from no C++/CUDA/hip ops (extensions). These ops need to be [compiled against PyTorch](https://www.deepspeed.ai/tutorials/advanced-install/#pre-install-deepspeed-ops) like Apex.
