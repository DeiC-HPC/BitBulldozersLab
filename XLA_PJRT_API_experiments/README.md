## Required Environment

Create required Python environment:
```shell
uv venv
uv pip install jax==0.6.0 jaxlib==0.6.0 jax-rocm7-plugin==0.6.0 jax-rocm7-pjrt==0.6.0 absl-py flatbuffers
```

Using this Python venv, we can generate export (Ahead-of-time compiled) Jax kernels to HLO and stableHLO intermediate representation using `compile_jax_to_hlo.py`.

In order to read, compile and exectue these kernels from C we need the PJRT interface from XLA,
we grab this interface as a PJRT C API header file from the xla repository (pjrt_c_api.h is included in this repo)
```
git clone https://github.com/openxla/xla.git
cp xla/xla/pjrt/c/pjrt_c_api.h c/pjrt/
```

Additionally, we need the pjrt_c_api implementation, we can consider compiling the CPU C++ implementation in the XLA repo, however in this repo, we get a precompiled
binary for the ROCm backend from the jax-rocm7-pjrt PyPI Wheel, which provides (xla_rocm_plugin.so is included in this repo)
```
export PJRT_PLUGIN=.venv/lib/python3.12/site-packages/jax_plugins/xla_rocm7/xla_rocm_plugin.so
cp $PJRT_PLUGIN c/pjrt
```


## Links
A good link overview:
https://github.com/jax-ml/jax/discussions/22184#discussioncomment-9909496

Emphasis:
https://github.com/openxla/xla/blob/main/xla/pjrt/c/pjrt_c_api.h
https://github.com/openxla/xla/issues/7038#issuecomment-1817223335
https://github.com/jax-ml/jax/issues/1871#issuecomment-2284816681

Python side:
https://github.com/joaospinto/call_jax_from_cpp/blob/5ca04351ef8c545f3781feaa29a37f68b8260034/call_jax_from_cpp/simple_jax_example.py
https://docs.jax.dev/en/latest/export/export.html
https://github.com/LeelaChessZero/lc0/issues/2068

Others:
https://github.com/jax-ml/jax/discussions/33567
https://github.com/jax-ml/jax/discussions/22266
https://docs.google.com/document/d/1TKB5NyGtdzrpgw5mpyFjVAhJjpSNdF31T6pjPl_UT2o/edit?tab=t.0
https://openxla.org/xla/tools
https://openxla.org/stablehlo/bytecode
https://github.com/openxla/stablehlo
https://discourse.llvm.org/t/mlir-documentation-is-confusing-and-not-as-helpful-as-it-could-be/60715
(Hardware implementation)
https://github.com/openxla/xla/blob/main/docs/pjrt/pjrt_integration.md