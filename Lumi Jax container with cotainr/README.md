# LUMI Jax container with cotainr

- **Keywords:** Jax, Pytorch, Container, AI, Cotainr, LUMI, ROCm
- **Date:** 2025-07-28

The JAX & PyTorch v2.3.1 container based on ROCm 6.0.2 for LUMI.

# Simple Pip Approach

In the simple approach we simply install Jax via the pip package.

## Requirements:
- Podman (v4.9.6-dev)
- apptainer (v1.4.1)
- cotainr (v2025.7.2)

## Containers
- use 2 containers
- full open source &  Lumi Base container. 

We use the fully open source container the build instructions are available [here](https://github.com/DeiC-HPC/BitBulldozersLab/pull/7).
Specifically we use the `base_image_libcxi_libfabric2000_mpich423.sif` version.

Furthermore, we use one of the Lumi Base containers available on Lumi under the following path: 
- `/appl/local/containers/sif-images/lumi-rocm-rocm-6.0.3.sif` --> Error; some ROCm libraries are missing
- `/appl/local/containers/sif-images/lumi-rocm-rocm-6.2.4.sif` --> Works

### Open source container 

Building the Jax image with cotainr can be done with the following command:

```commandline
 cotainr build --base-image /containers/base_image_libcxi_libfabric2000_mpich423.sif --conda-env=/BitBulldozersLab/Lumi\ Jax\ container\ with\ cotainr/conda_envs/conda_env.yml  libcxi_libfabric2000_mpich423_jax_pytorch.sif
```
This results in the `libcxi_libfabric2000_mpich423_jax_pytorch.sif` image. 


### Lumi Base container

Building the Jax image with the image on Lumi can be done with the following commands:

```commandline
 srun --output=results.out --error=results.err --account=project_XXXXXXXXXXX --time=00:30:00 --mem=160G --cpus-per-task=8 --partition=debug cotainr build jax_torch_rocm6.2.4.sif --base-image=/appl/local/containers/sif-images/lumi-rocm-rocm-6.0.3.sif --conda-env=conda.yml --accept-licenses
```
This results in the `jax_torch_rocm6.2.4.sif` image. 

## Test

We run three tests. 
First, simple test that just checks if the ROCm GPUs are found. 
Second, we run a small subset of the tests in the Jax Github repository.
Last, we run the Jax Mnist classifier example from the Jax Github repository. 

### Simple test

This is a simple test to check if the GPUs are available.

#### Open Source Container
For the open source container:
```commandline
 srun --output=results.out --error=results.err --account=project_465001699 --time=00:01:00 --mem=20G --cpus-per-task=1 --partition=dev-g --mpi=pmi2 --gpus-per-node=8 singularity exec -B /project/project_465001699/ libcxi_libfabric2000_mpich423_jax_pytorch.sif  python3 -c "import jax; print(jax.devices())"
```

The output should be:

```commandline
 [RocmDevice(id=0), RocmDevice(id=1), RocmDevice(id=2), RocmDevice(id=3), RocmDevice(id=4), RocmDevice(id=5), RocmDevice(id=6), RocmDevice(id=7)]
```

#### Lumi Base Container
For the container based on Samuels image:
```commandline
srun --output=results.out --error=results.err --account=project_465001699 --time=00:01:00 --mem=20G --cpus-per-task=1 --partition=dev-g --mpi=pmi2 --gpus-per-node=8 singularity exec -B /project/project_465001699/ jax_torch_rocm6.2.4.sif  python3 -c "import jax; print(jax.devices())"
```

The output should be:

```commandline
 [RocmDevice(id=0), RocmDevice(id=1), RocmDevice(id=2), RocmDevice(id=3), RocmDevice(id=4), RocmDevice(id=5), RocmDevice(id=6), RocmDevice(id=7)]
```

### Running Jax test suit

The following command clones the Jax repository and runs a numpy test.

```commandline
 git clone https://github.com/jax-ml/jax.git
```

#### Open Source Container

```commandline
 srun --output=results.out --error=results.err --account=project_465001699 --time=00:15:00 --mem=120G --nodes=1 --ntasks-per-node=1 --cpus-per-task=16 --partition=dev-g --mpi=pmi2 --gpus-per-node=2 singularity exec -B /project/project_465001699/julius/jax/jax libcxi_libfabric2000_mpich423_jax_pytorch.sif  bash -c 'cd jax; python tests/lax_numpy_test.py --test_targets="testPad"'
```

Not all tests pass. 

####  Lumi Base Container

```commandline
 srun --output=results.out --error=results.err --account=project_465001699 --time=00:15:00 --mem=120G --nodes=1 --ntasks-per-node=1 --cpus-per-task=16 --partition=dev-g --mpi=pmi2 --gpus-per-node=2 singularity exec -B /project/project_465001699/julius/jax/jax jax_torch_rocm6.2.4.sif  bash -c 'cd jax; python tests/lax_numpy_test.py --test_targets="testPad"'
```

Not all tests pass. 


### Running Jax example

Lastly, we train a Mnist classifier using Jax. 

In the Jax Github repository you first need to change line 33 in `examples/mnist_classifier.py` from `from examples import datasets` to `import datasets`.

#### Open Source Container

We can run the classifier using the following command:
```commandline
 srun --output=results.out --error=results.err --account=project_465001699 --time=00:15:00 --mem=60G --nodes=1 --ntasks-per-node=1 --cpus-per-task=8 --partition=dev-g --mpi=pmi2 --gpus-per-node=1 singularity exec -B /project/project_465001699/julius/jax/jax libcxi_libfabric2000_mpich423_jax_pytorch.sif  bash -c 'cd jax/examples; python mnist_classifier.py'
```

Output:

```commandline
Starting training...
Epoch 0 in 6.82 sec
Training set accuracy 0.09871666878461838
Test set accuracy 0.09799999743700027
Epoch 1 in 0.20 sec
Training set accuracy 0.09871666878461838
Test set accuracy 0.09799999743700027
Epoch 2 in 0.21 sec
Training set accuracy 0.09871666878461838
Test set accuracy 0.09799999743700027
....
```

Error:

The following errors are generated:

```commandline
E0728 15:50:04.390109   34963 buffer_comparator.cc:156] Difference at 32: -nan, expected 200.448
E0728 15:50:04.390131   34963 buffer_comparator.cc:156] Difference at 33: -nan, expected 196.919
E0728 15:50:04.390135   34963 buffer_comparator.cc:156] Difference at 34: -nan, expected 197.874
E0728 15:50:04.390138   34963 buffer_comparator.cc:156] Difference at 35: -nan, expected 196.177
E0728 15:50:04.390140   34963 buffer_comparator.cc:156] Difference at 36: -nan, expected 199.391
E0728 15:50:04.390143   34963 buffer_comparator.cc:156] Difference at 37: -nan, expected 192.441
E0728 15:50:04.390145   34963 buffer_comparator.cc:156] Difference at 38: -nan, expected 194.484
E0728 15:50:04.390148   34963 buffer_comparator.cc:156] Difference at 39: -nan, expected 200.298
E0728 15:50:04.390150   34963 buffer_comparator.cc:156] Difference at 40: -nan, expected 197.816
E0728 15:50:04.390152   34963 buffer_comparator.cc:156] Difference at 41: -nan, expected 196.744
2025-07-28 15:50:04.390159: E external/xla/xla/service/gpu/autotuning/gemm_fusion_autotuner.cc:1080] Results do not match the reference. This is likely a bug/unexpected loss of precision.
....
```

There is a bug report for this:
https://github.com/jax-ml/jax/issues/26846
Seems to work fine on RX6950XT but not on MI250X

Apparently this is fixed in jax 0.6.2:
https://github.com/jax-ml/jax/issues/27188

There is also this one:
https://github.com/jax-ml/jax/issues/24909

**Note: Running the same test with the prebuilt Jax container on Lumi does not result in the error!** 

#### Lumi Base Container

We can run the classifier using the following command:
```commandline
 srun --output=results.out --error=results.err --account=project_465001699 --time=00:15:00 --mem=60G --nodes=1 --ntasks-per-node=1 --cpus-per-task=8 --partition=dev-g --mpi=pmi2 --gpus-per-node=1 singularity exec -B /project/project_465001699/julius/jax/jax jax_torch_rocm6.2.4.sif  bash -c 'cd jax/examples; python mnist_classifier.py'
```

This results in similar errors with respect to `external/xla/xla/service/gpu/autotuning/gemm_fusion_autotuner.cc:1080` as the open source container. 

# Build Jax from source

Due to the errors in the open source container I decided to try to build Jax from source. 
To enable this I added a functionality to cotainr that allows us to run a bash script after the conda environment setup. 
The current work for this can be found here:
https://github.com/DeiC-HPC/cotainr/tree/feature/enable_bash_script

## Build in container
I started building Jax from source to make Bazel use `ld.ldd` instead of the `gold` linker I create a Bash script called `ld.gold` that forwards everything to ld.ldd. 
The `gold` linker is deprecated by now https://lwn.net/Articles/1007541/ but Bazel still defaults back to it. 

Furthermore, to set the clang path properly I had to sed one of the bazelrc files from the repository. Otherwise, it would continue to default to a non-existing clang. 

I finally gave up after the build system could not find the right ROCm libraries. 

The command used is:

```commandline
 cotainr build --base-image ../base_image_libcxi_libfabric2000_mpich423.sif --conda-env /BitBulldozersLab/Lumi\ Jax\ container\ with\ cotainr/conda_envs/conda_env.yml /BitBulldozersLab/Lumi\ Jax\ container\ with\ cotainr/conda_envs/install_jax.sh -v libcxi_libfabric2000_mpich423_jax_dev.sif
```

## Build on Raxos

Additionally, I tried to build the Jax wheels outside of a container on Raxos. 

```commandline
    python3 ./build/build.py build --wheels=jaxlib,jax-rocm-plugin,jax-rocm-pjrt \
        --rocm_version=602 --clang_path=$CLANG_COMPILER_PATH \
        --rocm_amdgpu_targets=gfx90a --bazel_options='-j=8'
```

And this resulted in the following error:

Error: `clang frontend command failed with exit code 139`
- This seems to correspond to a segfault that seems to creep up in some clang versions.

We could try again after updating Raxos and installing a newer clang version. 


## Problems & concerns
- 

## Results summary

The pip installation of Jax sort of works. I am not sure if the performance loss in the gemm_fusion_autotuner is a big issue, but I expect that the precision loss could result in poorly trained and non converging neural networks.
It is worrying that this behaviour is even present in the regular Lumi containers and that users are reliant on the images that come with Jax and not much else. 
Additionally, the complete Jax for ROCm seems to behind by quite a few versions. Pip installs Jax v0.5.0 whereas v0.7.0 is already available. 

The 

