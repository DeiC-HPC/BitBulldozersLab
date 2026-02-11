import numpy
import onnxruntime as ort
import torch
import numpy as np
from time import time

# Check if all setup is correct and if GPU is available
print(ort.get_available_providers())
print(torch.cuda.is_available())

# set torch device & create input
device = torch.device("cuda:0")
# randoms = torch.ra(, dtype=torch.float32, device=device).contiguous()
# y = torch.tensor([5.0, 6.0, 7.0, 8.0], dtype=torch.float32, device=device).contiguous()

# # create output tensor
# out = torch.zeros([4], dtype=torch.float32, device=device).contiguous()

S0    = torch.tensor([100.0], device=torch.device("cuda"), dtype=torch.float32).contiguous()   # spot
K     = torch.tensor([105.0], device=torch.device("cuda"), dtype=torch.float32).contiguous()   # strike (kept constant for Greeks)
r     = torch.tensor([0.05], device=torch.device("cuda"), dtype=torch.float32).contiguous()    # risk‑free rate
sigma = torch.tensor([0.20], device=torch.device("cuda"), dtype=torch.float32).contiguous()    # volatility
T     = torch.tensor([1.0], device=torch.device("cuda"), dtype=torch.float32).contiguous()     # 1 year

# MC settings
n_steps = torch.tensor([500], device=torch.device("cuda"), dtype=torch.int32).contiguous()          # daily discretisation
n_steps_smaller = torch.tensor([n_steps-1], device=torch.device("cuda"), dtype=torch.int32).contiguous()          # daily discretisation
n_paths = torch.tensor([500_000 ], device=torch.device("cuda"), dtype=torch.int32).contiguous()     # half‑million paths → ~0.1 % MC error

randoms = torch.tensor(np.random.normal(size=(n_paths[0], n_steps[0])), device=torch.device("cuda"), dtype=torch.float32).contiguous()

# start inference session
sess_options = ort.SessionOptions()
sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
sess_options.optimized_model_filepath = "greeks_optimized.onnx"
session = ort.InferenceSession("greeks.onnx",sess_options, providers=["ROCMExecutionProvider", "MIGraphXExecutionProvider"])
io_binding = session.io_binding()

io_binding.bind_input(
    name="in_0",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(randoms.shape),
    buffer_ptr=randoms.data_ptr()
)

io_binding.bind_input(
    name="in_1",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(S0.shape),
    buffer_ptr=S0.data_ptr()
)

io_binding.bind_input(
    name="in_2",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(K.shape),
    buffer_ptr=K.data_ptr()
)

io_binding.bind_input(
    name="in_3",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(r.shape),
    buffer_ptr=r.data_ptr()
)

io_binding.bind_input(
    name="in_4",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(sigma.shape),
    buffer_ptr=sigma.data_ptr()
)

io_binding.bind_input(
    name="in_5",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(T.shape),
    buffer_ptr=T.data_ptr()
)

io_binding.bind_input(
    name="in_6",
    device_type="cuda",
    device_id=0,
    element_type= np.int32,
    shape=tuple(n_steps_smaller.shape),
    buffer_ptr=n_steps_smaller.data_ptr()
)

io_binding.bind_input(
    name="in_7",
    device_type="cuda",
    device_id=0,
    element_type= np.int32,
    shape=tuple(n_paths.shape),
    buffer_ptr=n_paths.data_ptr()
)

out = torch.zeros([1], dtype=torch.float32, device=device).contiguous()

io_binding.bind_output(
    name='squeeze_out_0',
    device_type="cuda",
    device_id=0,
    element_type=np.float32,
    shape=tuple(out.shape),
    buffer_ptr=out.data_ptr()
)

start = time()
for i in range(1,100):
    # _ = session.run(["squeeze_out_0", "div_out_6", "add_out_7", "add_out_6"], {"in_0": randoms, "in_1": S0, "in_2": K, "in_3": r, "in_4": sigma, "in_5": T, "in_6": n_steps_smaller, "in_7": n_paths})
    session.run_with_iobinding(io_binding)
print(time()-start)
out_cpu = io_binding.copy_outputs_to_cpu()

print(out_cpu)

# print({
#         "price": out[0],
#         "delta": out[1],
#         "vega" : out[2],
#         "rho"  : out[3]
#     })
