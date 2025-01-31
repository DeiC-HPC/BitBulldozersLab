# Custom PyTorch with additional libraries

The PyTorch container on LUMI are custom built with a variety of custom wheels and source code from
speciala ROCm repositories. An example can be seen on [GitHub](https://github.com/sfantao/lumi-containers/blob/lumi-sep2024/pytorch/build-rocm-6.0.3-python-3.12-pytorch-v2.3.1.docker).
This repo attempts to build a similar container using a conda_env.yml file and cotainr.

## Steps to reproduce

```
git clone https://github.com/DeiC-HPC/cotainr.git --branch 2023.11.0
```

