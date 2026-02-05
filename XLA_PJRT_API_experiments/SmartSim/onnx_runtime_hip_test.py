import onnxruntime as ort
from hip import hip
import numpy as np

# from amd website - https://rocm.docs.amd.com/projects/hip-python/en/latest/user_guide/1_usage.html
def hip_check(call_result):
    err = call_result[0]
    result = call_result[1:]
    if len(result) == 1:
        result = result[0]
    if isinstance(err, hip.hipError_t) and err != hip.hipError_t.hipSuccess:
        raise RuntimeError(str(err))
    return result

# Check if all setup is correct and if GPU is available
print(ort.get_available_providers())
props = hip.hipDeviceProp_t()
hip_check(hip.hipGetDeviceProperties(props,0))
print(props.name)

# create input & output data
x_h = np.array([1.0, 2.0, 3.0, 4.0], dtype=np.float32)
y_h = np.array([5.0, 6.0, 7.0, 8.0], dtype=np.float32)
out_h = np.array([0.0]*4, dtype=np.float32)

# calculate size in bytes of each array
x_num_bytes = x_h.itemsize * len(x_h)
y_num_bytes = y_h.itemsize * len(y_h)
out_num_bytes = out_h.itemsize * len(out_h)

# allocate GPU memory
x_d = hip_check(hip.hipMalloc(x_num_bytes))
y_d = hip_check(hip.hipMalloc(y_num_bytes))
out_d = hip_check(hip.hipMalloc(out_num_bytes))

# create stream and transfer data.
stream = hip_check(hip.hipStreamCreate())
hip_check(hip.hipMemcpyAsync(x_d, x_h, x_num_bytes, hip.hipMemcpyKind.hipMemcpyHostToDevice, stream))
hip_check(hip.hipMemcpyAsync(y_d, y_h, y_num_bytes, hip.hipMemcpyKind.hipMemcpyHostToDevice, stream))

# start inference session
session = ort.InferenceSession("simple_add.onnx", providers=['MIGraphXExecutionProvider'])

# sync stream and destroy
hip_check(hip.hipStreamSynchronize(stream))
hip_check(hip.hipStreamDestroy(stream))

# bind IO so that we can directly use stuff on device
io_binding = session.io_binding()
io_binding.bind_input(
    name="in_0",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(x_h.shape),
    buffer_ptr=x_d
)

io_binding.bind_input(
    name="in_1",
    device_type="cuda",
    device_id=0,
    element_type= np.float32,
    shape=tuple(y_h.shape),
    buffer_ptr=y_d
)

io_binding.bind_output(
    name='add_out_0',
    device_type="cuda",
    device_id=0,
    element_type=np.float32,
    shape=tuple(out_h.shape),
    buffer_ptr=out_d
)

# run onnx model
session.run_with_iobinding(io_binding)

# copy out put back to cpu
out_cpu = io_binding.copy_outputs_to_cpu()
print(out_cpu)

# freedom to the mallocs
hip_check(hip.hipFree(x_d))
hip_check(hip.hipFree(y_d))
hip_check(hip.hipFree(out_d))
