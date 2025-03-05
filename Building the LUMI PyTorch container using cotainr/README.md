# Building the LUMI PyTorch container using cotainr

- **Keywords:** Pytorch, Container, AI, Cotainr
- **Date:** 2025-02-21

The PyTorch v2.3.1 container based on ROCm 6.0.3 on LUMI (i.e. `/appl/local/containers/tested-containers/lumi-pytorch-rocm-6.0.3-python-3.12-pytorch-v2.3.1-dockerhash-2c1c14cafd28.sif`) is custom built with a variety of custom wheels and source code from special ROCm repositories as defined in the Dockerfile in https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.0.3-python-3.12-pytorch-v2.3.1.docker.

## Building the containers
### Settings up the prerequisites
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

### Building Apex container
An attempt was made to build Apex in a one-step conda file
```
cotainr/bin/cotainr build --base-image /appl/local/containers/sif-images/lumi-rocm-rocm-6.0.3.sif --conda-env conda_env_apex.yml apex.sif -vv --accept-licenses
```
This fails because the libraies are not [PEP528](https://peps.python.org/pep-0518/) compliant as described in "Conda yaml deficiencies" described below. This can be illustrated by first building
```
cotainr/bin/cotainr build --base-image /appl/local/containers/sif-images/lumi-rocm-rocm-6.0.3.sif --conda-env conda_env_ref.yml ref.sif -vv --accept-licenses
singularity shell ref.sif
pip install apex @ git+https://github.com/rocm/apex
```
This does succesfully install the library, however it is installed to `$HOME/.local/` site-packages as a local user installation and not actually inside the container. Note that it seems like Nvidia gets around this non-compliance by distributing precompiled versions of Apex on [conda](https://anaconda.org/conda-forge/nvidia-apex/files) with a matrix of `cuda`, `pytorch` and `numpy` dependencies. 

### Building the Deepspeed container
The Deepspeed container can be built
```
cotainr/bin/cotainr build --base-image /appl/local/containers/sif-images/lumi-rocm-rocm-6.0.3.sif --conda-env conda_env_deepspeed.yml deepspeed.sif -vv --accept-licenses
```
This is not an optimized installation as seen in `deepspeed-env_report.md` under the `op name ... installed` tab, where every extension report `[NO]`. Whereas the library itself is [PEP528](https://peps.python.org/pep-0518/) compliant, the actual acceleration extensions are not, and needs to be [compiled against PyTorch](https://www.deepspeed.ai/tutorials/advanced-install/#pre-install-deepspeed-ops). If we attempt to install Deepspeed with the same extensions as the target container we can run
```
source export_env.sh
cotainr/bin/cotainr build --base-image /appl/local/containers/sif-images/lumi-rocm-rocm-6.0.3.sif --conda-env conda_env_deepspeed.yml deepspeed.sif -vv --accept-licenses
```
Which does not succeed.

### Building the BitsandBytes container
The BitsandBytes container can be built
```
otainr/bin/cotainr build --base-image /appl/local/containers/sif-images/lumi-rocm-rocm-6.1.3.sif --conda-env conda_env_bitsandbytes.yml bitsandbytes.sif -vv --accept-licenses
```
However, note that we use an alpha version with ROCm support which requires a newer ROCm. The base-image container is therefore chosen to be `/appl/local/containers/sif-images/lumi-rocm-rocm-6.1.3.sif`.

### Building the final container

Combining the previous builds into a single container which most closely resembling the [Container by Samuel](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.1.3-python-3.12-pytorch-v2.4.1.docker), is run via
```
cotainr/bin/cotainr build --base-image /appl/local/containers/sif-images/lumi-rocm-rocm-6.1.3.sif --conda-env conda_env_success.yml test.sif -vv --accept-licenses
```
We attempt to import the three key libraries `torch`, `deepspeed` and `bitsandbytes` in the script `import-test.py` which is submitted to the `dev-g` partition on LUMI using the `run-import-test.sh` script (mind the bind path!). We get the output:
```
$> cat slurm-XXXXXX.out 
[2025-02-21 16:03:09,619] [INFO] [real_accelerator.py:203:get_accelerator] Setting ds_accelerator to cuda (auto detect)
/opt/conda/envs/conda_container_env/lib/python3.12/site-packages/bitsandbytes/backends/cpu_xpu_common.py:29: UserWarning: g++ not found, torch.compile disabled for CPU/XPU.
  warnings.warn("g++ not found, torch.compile disabled for CPU/XPU.")
Import finished
```
where we get info from deepspeed that it finds the GPU accelerator and a UserWarning from BitsandBytes that the g++ compiler is not present in the container. This UserWarning could possibly be removed by including a `g++` compiler conda package.

## Problems & concerns

### Library removal concerns
After installation of all the packages, the _Conda_ libstc++.so library  is explicitly [removed](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/common/Dockerfile.no-torch-libstdc%2B%2B) from the official LUMI PyTorch container to ensure the container C++ library is used. This might or might not be an issue for portability of the container depending on how the base container is built. It nevertheless is an issue for the cotainr method as it doesn't support modifying the container post-install. This is done in all versions of the docker script. Note: There are similar concerns for ROCm>=6.1.3 versions (without LLVM), where the ROCm libraries from the PyTorch installation are removed.

### Writing pip commands in conda-env
Writing pip commands to a Conda environment can be quite advanced, see [here](https://github.com/conda/conda/blob/main/tests/env/support/advanced-pip/environment.yml) for various examples of allowed notation. However, the formatting for installing packages on GitHub has undergone several iterations through the last few years, and as such, the notation in `conda_env_apex.yml` is quite strongly dependent on the specific version of `pip`. See for example [here](https://github.com/pypa/pip/pull/11617). The current (pip version 25.0) supported per-requirement options are listed [here](https://pip.pypa.io/en/latest/reference/requirements-file-format/#per-requirement-options), although one may also get warnings that the `--global-option` was depricated in 24.2.

### Conda yaml deficiencies
The package `Apex` **needs** to be built with `--no-build-isolation` after PyTorch is installed in a two-step process. However, because conda resolves and installs all dependencies at once using a generated `requirements.txt` file it would be impossible without additional steps. This is a conscious choice in the ML community where they claim good reasons for PEP528 non-compliance is described [here](https://github.com/astral-sh/uv/issues/1715).

Note, this could possibly be accomplished by allowing separately pip installing a `requirements.txt` after the conda installation like suggested in this [PR](https://github.com/DeiC-HPC/cotainr/pull/55). We would need to be careful that the pip installation properly uses the conda environment. Finally, this issue is not unique to the ROCm branch, but is required with Nvidia as well. 


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
- Bitsandbytes is slightly different, here `torch` is labelled as an explicit dependency. There are [alpha releases](https://huggingface.co/docs/bitsandbytes/main/en/installation?backend=AMD+ROCm&platform=Linux#multi-backend-pip) for pre-compiled binary builds, which does successfully install. We note that these are only compatible with `rocm≥6.1` and thus the target container is changed from [rocm6.0.3 build](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.0.3-python-3.12-pytorch-v2.3.1.docker) to [rocm6.1.3 build](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.1.3-python-3.12-pytorch-v2.4.1.docker).

## Key Findings

- Cotainr by design relies on package managers to be able to resolve dependencies correctly.
- For build time dependency management to work in the Python package ecosystem, packages must implement PEP528. Only declaring install time dependencies is insufficient to ensure correct dependency handling if pip (or another tool) tries to build a wheel from source at install time.
- It is common for PyTorch "extension packages" (e.g. Apex, Deepspeed, bitandbytes) to not explicitly declare PyTorch as a build time dependencies according to PEP528 but instead rely on the user to manually install PyTorch before attempting to install these packages. Installing such packages from a pip requirement.txt file fails.

Consequently, cotainr also fails to install these packages when added as pip requirements in a conda environment file making it impossible to directly build Samuel's PyTorch container using cotainr.