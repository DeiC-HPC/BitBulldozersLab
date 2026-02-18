#!/usr/bin/env python
from libpyembed import ffi
from functools import wraps
import traceback
from hip._util.types import DeviceArray, NDBuffer
from hip import hip
from hip import hipblas
import numpy as np


def analyse(obj, filter_keys=True):
    if filter_keys:
        dict_keys = [i for i in dir(obj) if not i.startswith('_')]
    else:
        dict_keys = [i for i in dir(obj)]
    print(dict_keys)


def with_return_code(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            func(*args, **kwargs)
            return 0
        except Exception:
            traceback.print_exc()
            return 1
    return wrapper

# from amd website - https://rocm.docs.amd.com/projects/hip-python/en/latest/user_guide/1_usage.html
def hip_check(call_result):
    err = call_result[0]
    result = call_result[1:]
    if len(result) == 1:
        result = result[0]
    if isinstance(err, hip.hipError_t) and err != hip.hipError_t.hipSuccess:
        raise RuntimeError(str(err))
    return result

def alloc(arr):
    return hip_check(hip.hipMalloc(arr.nbytes))

def hidden_alloc(direct = False):
    # create input & output data
    alpha = np.array([2.0], dtype=np.float32)
    x_h = np.array([1.0, 2.0, 3.0, 4.0], dtype=np.float32)
    y_h = np.array([5.0, 6.0, 7.0, 8.0], dtype=np.float32)
    
    # allocate GPU memory
    x_d = alloc(x_h)
    y_d = alloc(y_h)

    # create stream and transfer data.
    stream = hip_check(hip.hipStreamCreate())
    hip_check(hip.hipMemcpyAsync(x_d, x_h, x_h.nbytes, hip.hipMemcpyKind.hipMemcpyHostToDevice, stream))
    hip_check(hip.hipMemcpyAsync(y_d, y_h, y_h.nbytes, hip.hipMemcpyKind.hipMemcpyHostToDevice, stream))
    hip_check(hip.hipStreamSynchronize(stream))
    hip_check(hip.hipStreamDestroy(stream))
    #hip_check(hip.hipFree(x_d))
    #hip_check(hip.hipFree(y_d))
    if not direct:
        return (x_d.as_c_void_p(), x_d.shape,
                y_d.as_c_void_p(), y_d.shape,
                alpha, len(x_h))
    else:
        return x_d, y_d, alpha, len(x_h)

from hip._util.types import DeviceArray
from ctypes import c_void_p
def hipArray(ptr: c_void_p, shape: int):
    addr = int(ffi.cast("uintptr_t", ptr))
    arr = DeviceArray(addr)
    arr.configure(_force=True, shape=(shape,))
    return arr

def numpyArray(ptr: c_void_p, shape: int):
    print(ptr)
    addr = int(ffi.cast("uintptr_t", ptr))
    arr = np.ndarray(buffer=(addr, False), shape=(shape,), dtype=np.float32, copy=False)
    #arr = NDBuffer(addr)
    #arr.configure(_force=True, shape=(shape,))    
    return arr

@ffi.def_extern()
@with_return_code
def run(xptr, yptr, aptr, size):
    # Check if all setup is correct and if GPU is available
    props = hip.hipDeviceProp_t()
    hip_check(hip.hipGetDeviceProperties(props,0))
    print(props.name)

    # Emulate allocation done in Fortran, outputs raw C void pointers
    # xptr, xs, yptr, ys, alpha, n = hidden_alloc()
    
    # Initialize hip buffers from raw pointers
    x_d = hipArray(xptr, size)
    y_d = hipArray(yptr, size)
    #alpha = hipArray(aptr, 1)
    #alpha = 2.0
    # alpha = np.array([2.0], dtype=np.float32)
    alpha = numpyArray(aptr, 1)
    
    # Directly retrieve hip buffers
    #x_d, y_d, alpha, n = hidden_alloc(direct = True)

    out_h = np.zeros(size, dtype=np.float32)

    stream = hip_check(hip.hipStreamCreate())
    handle = hip_check(hipblas.hipblasCreate())
    hip_check(hipblas.hipblasSetStream(handle, stream))

    # Calculate Single-precession alpha * x + y on GPU
    hip_check(hipblas.hipblasSaxpy(
        handle,
        n=size,
        alpha=alpha,
        x=x_d, incx=1,
        y=y_d, incy=1))

    hip_check(hip.hipMemcpyAsync(out_h, y_d, out_h.nbytes, hip.hipMemcpyKind.hipMemcpyDeviceToHost, stream))
    print(out_h)

    # sync stream and destroy
    hip_check(hip.hipStreamSynchronize(stream))
    hip_check(hip.hipStreamDestroy(stream))
    hip_check(hipblas.hipblasDestroy(handle))

    # We can in principle free the cpp pointers from Python
    # hip_check(hip.hipFree(x_d))
    # hip_check(hip.hipFree(y_d))
