import numpy
import onnxruntime as ort
import torch
import numpy as np

# Check if all setup is correct and if GPU is available
print(ort.get_available_providers())
print(torch.cuda.is_available())

# set torch device & create input
device = torch.device("cuda:0")
x = torch.tensor([1.0, 2.0, 3.0, 4.0], dtype=torch.float32, device=device).contiguous()
y = torch.tensor([5.0, 6.0, 7.0, 8.0], dtype=torch.float32, device=device).contiguous()

# create output tensor
out = torch.zeros([4], dtype=torch.float32, device=device).contiguous()

# start inference session
session = ort.InferenceSession("simple_add.onnx", providers=['MIGraphXExecutionProvider'])
io_binding = session.io_binding()

io_binding.bind_input(
    name="in_0",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(x.shape),
    buffer_ptr=x.data_ptr()
)

io_binding.bind_input(
    name="in_1",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(y.shape),
    buffer_ptr=y.data_ptr()
)

io_binding.bind_output(
    name='add_out_0',
    device_type="cuda",
    device_id=0,
    element_type=np.float32,
    shape=tuple(out.shape),
    buffer_ptr=out.data_ptr()
)

session.run_with_iobinding(io_binding)
out_cpu = io_binding.copy_outputs_to_cpu()

print(out_cpu)