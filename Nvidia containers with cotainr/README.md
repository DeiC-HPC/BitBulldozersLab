

Nvidia Container repository
- https://catalog.ngc.nvidia.com/orgs/nvidia/containers
- many containers

Start with:
1. nvcr.io/nvidia/cuda:12.5.0-devel-ubuntu22.04 
2. podman image save --format oci-archive 17d5b91a37e5 > nvidia_cuda12.5_devel.tar
3. apptainer build nvidia_cuda12.5_devel.sif oci-archive://nvidia_cuda12.5_devel.tar
4. cotainr build --accept-licenses --base-image nvidia_cuda12.5_devel.sif --conda-env ../../Projects/BitBulldozersLab/Nvidia\ containers\ with\ cotainr/conda_envs/conda_env_cuda_12.5.yml nvidia_cuda12.5_devel_pytorch2.6.sif
4. APPTAINERENV_NVIDIA_VISIBLE_DEVICES=0 apptainer shell --nv nvidia_cuda12.5_devel_pytorch2.6.sif 

Using `podman save IMAGE_ID -o *.tar` leads to the following error: `bufio.Scanner: token too long`

# Tried:

## Base CUDA container:
https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags

- nvcr.io/nvidia/cuda:12.5.0-devel-ubuntu22.04  ==> WORKS
- nvcr.io/nvidia/cuda:12.9.1-cudnn-devel-ubuntu22.04 ==> 

## Cuda DL container
https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda-dl-base/tags
- nvcr.io/nvidia/cuda-dl-base:25.06-cuda12.9-devel-ubuntu24.04

## HPC container
https://catalog.ngc.nvidia.com/orgs/nvidia/containers/nvhpc/tags
- nvcr.io/nvidia/nvhpc:25.5-devel-cuda12.9-ubuntu22.04

Launch python (i.e., `python3`)

```python
import torch
print(torch.cuda.is_available())
print(torch.cuda.device_count())
if torch.cuda.is_available():
    x = torch.zeros(3, 3)
    x = x.to('cuda')
    print(x)
```

Output should be:
``
```python
True
1
tensor([[0., 0., 0.],
        [0., 0., 0.],
        [0., 0., 0.]], device='cuda:0')
```
