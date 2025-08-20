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

## Env Vaiables Lumi:
```commandline
export PROJECT_NUM=project_XXXXXXXXXX
```

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

This uses the latest `jax[rocm]` version and ROCm 6.2.4.
Building the Jax image with the image on Lumi can be done with the following commands:

```commandline
 srun --output=results.out --error=results.err --account=$PROJECT_NUM --time=00:30:00 --mem=160G --cpus-per-task=8 --partition=debug cotainr build jax_torch_rocm6.2.4.sif --base-image=/appl/local/containers/sif-images/lumi-rocm-rocm-6.2.4.sif --conda-env=conda_env_jax_lumi.yml --accept-licenses
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

**Note: You may have to set the LD_LIBRARY_PATH**

For the open source container:
```commandline
 srun --output=results.out --error=results.err --account=$PROJECT_NUM --time=00:01:00 --mem=20G --cpus-per-task=1 --partition=dev-g --mpi=pmi2 --gpus-per-node=8 singularity exec -B /project/$PROJECT_NUM/ libcxi_libfabric2000_mpich423_jax_pytorch.sif  python3 -c "import jax; print(jax.devices())"
```

The output should be:

```commandline
 [RocmDevice(id=0), RocmDevice(id=1), RocmDevice(id=2), RocmDevice(id=3), RocmDevice(id=4), RocmDevice(id=5), RocmDevice(id=6), RocmDevice(id=7)]
```

#### Lumi Base Container

**Note: You may have to set the LD_LIBRARY_PATH and adjust the ROCM_PATH**

For the container based on Samuels image:
```commandline
srun --output=results.out --error=results.err --account=$PROJECT_NUM --time=00:01:00 --mem=20G --cpus-per-task=1 --partition=dev-g --mpi=pmi2 --gpus-per-node=8 singularity exec -B /project/$PROJECT_NUM/ jax_torch_rocm6.2.4.sif  python3 -c "import jax; print(jax.devices())"
```

The output should be:

```commandline
 [RocmDevice(id=0), RocmDevice(id=1), RocmDevice(id=2), RocmDevice(id=3), RocmDevice(id=4), RocmDevice(id=5), RocmDevice(id=6), RocmDevice(id=7)]
```

### Running Jax test suit

The following command clones the Jax repository and runs a numpy test.

```commandline
 cd /project/$PROJECT_NUM/$USER/
 mkdir jax 
 cd jax
 git clone https://github.com/jax-ml/jax.git
 git switch --detach jax-v0.4.35
```

#### Open Source Container

```commandline
 srun --output=results.out --error=results.err --account=$PROJECT_NUM --time=00:15:00 --mem=120G --nodes=1 --ntasks-per-node=1 --cpus-per-task=16 --partition=dev-g --mpi=pmi2 --gpus-per-node=2 singularity exec -B /project/$PROJECT_NUM/$USER/jax/jax libcxi_libfabric2000_mpich423_jax_pytorch.sif  bash -c 'cd jax; python tests/lax_numpy_test.py --test_targets="testPad"'
```

Tests should all pass.

####  Lumi Base Container

```commandline
git switch --detach jax-v0.5.0
```

```commandline
 srun --output=results.out --error=results.err --account=$PROJECT_NUM --time=00:15:00 --mem=120G --nodes=1 --ntasks-per-node=1 --cpus-per-task=16 --partition=dev-g --mpi=pmi2 --gpus-per-node=2 singularity exec -B /project/$PROJECT_NUM/$USER/jax/jax jax_torch_rocm6.2.4.sif  bash -c 'cd jax; python tests/lax_numpy_test.py --test_targets="testPad"'
```

Tests should all pass.

### Running Jax example

Lastly, we train a Mnist classifier using Jax. 

In the Jax Github repository you first need to change line 33 in `examples/mnist_classifier.py` from `from examples import datasets` to `import datasets`.

#### Open Source Container

We can run the classifier using the following command:
```commandline
 srun --output=results.out --error=results.err --account=$PROJECT_NUM --time=00:15:00 --mem=60G --nodes=1 --ntasks-per-node=1 --cpus-per-task=8 --partition=dev-g --mpi=pmi2 --gpus-per-node=1 singularity exec -B /project/$PROJECT_NUM/$USER/jax/jax libcxi_libfabric2000_mpich423_jax_pytorch.sif  bash -c 'cd jax/examples; python mnist_classifier.py'
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

**These errors are gone when using the right tag for the mnist classifier!**

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


#### Lumi Base Container

We can run the classifier using the following command:
```commandline
 srun --output=results.out --error=results.err --account=$PROJECT_NUM --time=00:15:00 --mem=60G --nodes=1 --ntasks-per-node=1 --cpus-per-task=8 --partition=dev-g --mpi=pmi2 --gpus-per-node=1 singularity exec -B /project/$PROJECT_NUM/$USER/jax/jax jax_torch_rocm6.2.4.sif  bash -c 'cd jax/examples; python mnist_classifier.py'
```

# Build Jax from source

**Note: The below isn't really necessary anymore as I managed to fix the errors for the previous packages. It may still be required if newer features of jax are needed.**

Due to the errors in the open source container I decided to try to build Jax from source. 
To enable this I added a functionality to cotainr that allows us to run a bash script after the conda environment setup. 
The current work for this can be found here:
https://github.com/DeiC-HPC/cotainr/tree/feature/enable_bash_script

## Build in container
I started building Jax from source. However, in the containers Bazel defaults to use the `gold` linker. 
To make Bazel use `ld.ldd` instead of the `gold` linker I create a Bash script called `ld.gold` that forwards everything to `ld.ldd`. 
The `gold` linker is deprecated by now https://lwn.net/Articles/1007541/ but Bazel still defaults back to it and I havent found another way around this in the container. 

Furthermore, to set the clang path properly I had to `sed` one of the bazelrc files from the repository. Otherwise, it would continue to default to a non-existing clang. 

I finally gave up after the build system could not find the right ROCm libraries. 

**Note: When trying this, make sure you comment out line 23 in the conda_env.yml. That line installs jax via pip.**

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
- This corresponds to a segfault that seems to creep up in some clang versions.

We could try again after updating Raxos and installing a newer clang version. 


# Results summary

The pip installation of Jax works. However, one may need to make sure that ROCm and Jax are compatible; for example, the prebuild jax v0.5.0 wheels may not work with ROCm v6.0.3 but only v6.2.4 (and possibly above). This is because ROCm v6.0.3 is missing the `librocprofiler-register.so.0` library, however, the tests and MNIST classifier still run.  

The compilation process for Jax is not very transparent. 
It seems to ignore the clang path and still downloads its own clang. `Ld.gold` is the default linker in a container and switching to for example `ld.ldd` is a hassle. 
Furthermore, setting the ROCm path seems to be ignored and the linker does not find the right libraries. For future reference we could look into the compilation setup by Samuel: https://github.com/sfantao/lumi-containers-unofficial/blob/main/jax/build-rocm-5.6.1-python-3.10-jax-0.4.13.docker

Lastly, the Lumi images may be missing parts required by Jax, so even the `pip install` method may fail. 
