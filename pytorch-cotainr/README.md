# Custom PyTorch with additional libraries

The PyTorch container on LUMI are custom built with a variety of custom wheels and source code from
speciala ROCm repositories. An example can be seen on [GitHub](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.0.3-python-3.12-pytorch-v2.3.1.docker).
This repo attempts to build a similar container using a conda_env.yml file and cotainr, the test-container is built using the command in `build.txt`.

## Writing pip commands in conda-env
Writing pip commands to a Conda environment can be quite advanced, see [here](https://github.com/conda/conda/blob/main/tests/env/support/advanced-pip/environment.yml) for various examples of allowed notation. However, the formatting for installing packages on GitHub has undergone several iterations through the last few years, and as such, the notation in `conda-env.yml` is quite strongly dependent on the specific version of `pip`. See for example [here](https://github.com/pypa/pip/pull/11617). The current (pip version 25.0) supported per-requirement options are listed [here](https://pip.pypa.io/en/latest/reference/requirements-file-format/#per-requirement-options), although one may also get warnings that the `--global-option` was depricated in 24.2.

## Conda yaml deficiencies
The attempted cotainr build with `conda_env.yml` in this repo failed, whereas the cotainr build with `conda_env_ref.yml` and subsequent manual installing the `pip install apex @ git+https://github.com/rocm/apex` does succeed. The reason for this failure is described [here](https://github.com/astral-sh/uv/issues/1715) as:

_A number of machine learning-related modules Flash-attn, NVidia Apex need pytorch to be installed before they are installed, so that they can do things like compile against version of pytorch currently installed in the user's environment.

You might think that these modules should declare that they depend upon Pytorch at setup time in their pyproject.toml file, but that isn't a good solution. No one wants a newly installed Pytorch version, and they might have installed pytorch using Conda or some other mechanism that pip isn't aware of. And these modules want to just work with whatever version of pytorch is already there. It would cause a LOT more problems than it would solve._

Essentially, the package `Apex` **needs** to be built with `--no-build-isolation` after PyTorch is installed in a two-step process. However, because conda installs all requested dependencies at once using a generated `requirements.txt` file it would be impossible without additional steps. This could possibly be accomplished by allowing separately pip installing a `requirements.txt` after the conda installation like suggested in this [PR](https://github.com/DeiC-HPC/cotainr/pull/55).