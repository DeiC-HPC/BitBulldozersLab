(conda_container_env) python -m deepspeed report
[2025-07-23 11:30:39,969] [INFO] [real_accelerator.py:254:get_accelerator] Setting ds_accelerator to cuda (auto detect)
[2025-07-23 11:30:42,159] [INFO] [logging.py:107:log_dist] [Rank -1] [TorchCheckpointEngine] Initialized with serialization = False
/opt/cotainr/conda/envs/conda_container_env/bin/python: No module named deepspeed.__main__; 'deepspeed' is a package and cannot be directly executed
(conda_container_env) python -m deepspeed.env_report
[2025-07-23 11:31:04,790] [INFO] [real_accelerator.py:254:get_accelerator] Setting ds_accelerator to cuda (auto detect)
[2025-07-23 11:31:06,250] [INFO] [logging.py:107:log_dist] [Rank -1] [TorchCheckpointEngine] Initialized with serialization = False
--------------------------------------------------
DeepSpeed C++/CUDA extension op report
--------------------------------------------------
NOTE: Ops not installed will be just-in-time (JIT) compiled at
      runtime if needed. Op compatibility means that your system
      meet the required dependencies to JIT install the op.
--------------------------------------------------
JIT compiled ops requires ninja
ninja .................. [OKAY]
--------------------------------------------------
op name ................ installed .. compatible
--------------------------------------------------
 [WARNING]  async_io requires the dev libaio .so object and headers but these were not found.
 [WARNING]  async_io: please install the libaio-dev package with apt
 [WARNING]  If libaio is already installed (perhaps from source), try setting the CFLAGS and LDFLAGS environment variables to where it can be found.
async_io ............... [NO] ....... [NO]
fused_adam ............. [NO] ....... [OKAY]
cpu_adam ............... [NO] ....... [OKAY]
cpu_adagrad ............ [NO] ....... [OKAY]
cpu_lion ............... [NO] ....... [OKAY]
dc ..................... [NO] ....... [OKAY]
 [WARNING]  Please specify the CUTLASS repo directory as environment variable $CUTLASS_PATH
evoformer_attn ......... [NO] ....... [NO]
 [WARNING]  FP Quantizer is using an untested triton version (3.3.0), only 2.3.(0, 1) and 3.0.0 are known to be compatible with these kernels
fp_quantizer ........... [NO] ....... [NO]
fused_lamb ............. [NO] ....... [OKAY]
fused_lion ............. [NO] ....... [OKAY]
/opt/cotainr/conda/envs/conda_container_env/compiler_compat/ld: cannot find -lcufile: No such file or directory
collect2: error: ld returned 1 exit status
gds .................... [NO] ....... [NO]
transformer_inference .. [NO] ....... [OKAY]
inference_core_ops ..... [NO] ....... [OKAY]
cutlass_ops ............ [NO] ....... [OKAY]
quantizer .............. [NO] ....... [OKAY]
ragged_device_ops ...... [NO] ....... [OKAY]
ragged_ops ............. [NO] ....... [OKAY]
random_ltd ............. [NO] ....... [OKAY]
 [WARNING]  sparse_attn requires a torch version >= 1.5 and < 2.0 but detected 2.7
 [WARNING]  using untested triton version (3.3.0), only 1.0.0 is known to be compatible
sparse_attn ............ [NO] ....... [NO]
spatial_inference ...... [NO] ....... [OKAY]
transformer ............ [NO] ....... [OKAY]
stochastic_transformer . [NO] ....... [OKAY]
utils .................. [NO] ....... [OKAY]
--------------------------------------------------
DeepSpeed general environment info:
torch install path ............... ['/opt/cotainr/conda/envs/conda_container_env/lib/python3.12/site-packages/torch']
torch version .................... 2.7.0+cu128
deepspeed install path ........... ['/opt/cotainr/conda/envs/conda_container_env/lib/python3.12/site-packages/deepspeed']
deepspeed info ................... 0.17.2, unknown, unknown
torch cuda version ............... 12.8
torch hip version ................ None
nvcc version ..................... 12.8
deepspeed wheel compiled w. ...... torch 2.7, cuda 0.0
shared memory (/dev/shm) size .... 15.25 GB
(conda_container_env) exit
exit
