# LUMI Jax container with cotainr

- **Keywords:** Jax, Pytorch, Container, AI, Cotainr, LUMI, ROCm
- **Date:** 2025-07-28

The JAX & PyTorch v2.3.1 container based on ROCm 6.0.3 for LUMI.

## Requirements:
- Podman (v4.9.6-dev)
- apptainer (v1.4.1)
- cotainr (v2025.7.2)

## Containers
- use 2 containers
- full open source

built sif image with cotainr

### Open source container 



```commandline
 cotainr build --base-image ../base_image_libcxi_libfabric2000_mpich423.sif --conda-env=/home/julius/Projects/BitBulldozersLab/Lumi\ Jax\ container\ with\ cotainr/conda_envs/conda_env.yml  libcxi_libfabric2000_mpich423_jax_pytorch.sif
```

### Samuels container

(i.e. `/appl/local/containers/tested-containers/lumi-pytorch-rocm-6.0.3-python-3.12-pytorch-v2.3.1-dockerhash-2c1c14cafd28.sif`)


## Test

### Simple test
```commandline
 srun --output=cotainr.out --error=cotainr.err --account=project_465001699 --time=00:01:00 --mem=20G --cpus-per-task=1 --partition=dev-g --mpi=pmi2 --gpus-per-node=8 singularity exec -B /project/project_465001699/ libcxi_libfabric2000_mpich423_jax_pytorch.sif  python3 -c "import jax; print(jax.devices())"
```

```commandline
 [RocmDevice(id=0), RocmDevice(id=1), RocmDevice(id=2), RocmDevice(id=3), RocmDevice(id=4), RocmDevice(id=5), RocmDevice(id=6), RocmDevice(id=7)]
```


### Running Jax test suit
```commandline
 git clone https://github.com/jax-ml/jax.git
 # takes super long
 # srun --output=cotainr.out --error=cotainr.err --account=project_465001699 --time=00:15:00 --mem=20G --nodes=1 --ntasks-per-node=1 --cpus-per-task=16 --partition=dev-g --mpi=pmi2 --gpus-per-node=2 singularity exec -B /project/project_465001699/julius/jax/jax libcxi_libfabric2000_mpich423_jax_pytorch.sif  bash -c "cd jax; pytest -n auto tests"
 srun --output=cotainr.out --error=cotainr.err --account=project_465001699 --time=00:15:00 --mem=120G --nodes=1 --ntasks-per-node=1 --cpus-per-task=16 --partition=dev-g --mpi=pmi2 --gpus-per-node=2 singularity exec -B /project/project_465001699/julius/jax/jax libcxi_libfabric2000_mpich423_jax_pytorch.sif  bash -c 'cd jax; python tests/lax_numpy_test.py --test_targets="testPad"'
```

### Running Jax example



```commandline
 git clone https://github.com/jax-ml/jax.git
```

Change line 33 in `examples/mnist_classifier.py` from `from examples import datasets` to `import datasets`.

```commandline
 srun --output=cotainr.out --error=cotainr.err --account=project_465001699 --time=00:15:00 --mem=60G --nodes=1 --ntasks-per-node=1 --cpus-per-task=8 --partition=dev-g --mpi=pmi2 --gpus-per-node=1 singularity exec -B /project/project_465001699/julius/jax/jax libcxi_libfabric2000_mpich423_jax_pytorch.sif  bash -c 'cd jax/examples; python mnist_classifier.py'
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
