## Required Environment

Create required Python environment:
```shell
uv venv python 3.12
source .venv/bin/activate
uv pip install jax2onnx
uv pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/onnxruntime_rocm-1.22.1-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl
uv pip install --pre torch --index-url https://download.pytorch.org/whl/rocm7.0
uv pip install -i https://test.pypi.org/simple/ hip-python==7.0.2.555.40
```

The following command compiles the function to the ONNX format with variable input & output sizes. 
```shell
python compile_jax_to_onnx.py
```

We can then execute it using the `onnxruntime-rocm`. 
We can provide torch tensors that are allocated on the GPU directly as an input via the IO_binding option.
The outputs can also be IO_bound

```shell
python onnx_runtime_test.py
```

Additionally, we can provide hipMalloc'ed arrays as an input:

```shell
python onnx_runtime_hip_test.py
```

## Links
- https://github.com/enpasos/jax2onnx
- https://netron.app/ -->visualize ONNX network 
- https://onnxruntime.ai/docs/api/python/api_summary.html --> info on data & io_binding
- https://github.com/ROCm/hip-python --> hip-python 

### Deprecated links
- https://github.com/CrayLabs/SmartSim
--> We are not looking further at SmartSim. It seems to have a lot of issues. 
  - No releases in the last 1.5-2 years
  - No raw GPU pointer inputs
  - `smart build ...` is needed for actually building backends and stuff like onnx. This either didnt install pytorch/onnx etc. or failed. 