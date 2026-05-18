#!/usr/bin/env python
from libpyembed import ffi
from hip import hipblas
from hip import hip
import numpy as np
from hip._util.types import DeviceArray
from ctypes import POINTER
import weakref

global_weakkeydict = weakref.WeakKeyDictionary()


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

@ffi.def_extern()
def hidden_alloc():
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
    
    result = ffi.new("Alloc *")
    result.x_d = ffi.cast("void *", x_d)
    result.y_d = ffi.cast("void *", y_d)
    result.alpha = ffi.cast("float *", alpha.ctypes.data)
    result.alpha_len = len(alpha)
    result.n = len(x_h)
    
    return result


def hipPointer(ptr, shape):
    addr = int(ffi.cast("uintptr_t", ptr))
    arr = DeviceArray(addr)
    arr.configure(_force=True, shape=shape)
    return arr

@ffi.def_extern()
def hipInit(stream_out, handle_out):
    try:
        props = hip.hipDeviceProp_t()
        hip_check(hip.hipGetDeviceProperties(props, 0))
        stream = hip_check(hip.hipStreamCreate())
        handle = hip_check(hipblas.hipblasCreate())
        hip_check(hipblas.hipblasSetStream(handle, stream))
        stream_out = stream
        handle_out = handle
        return 0   # success
    except Exception as e:
        print("Exception caught in hipInit: ", e)
        return -1  # error

@ffi.def_extern()
def my_hipblasSaxpy(handle, n, alpha, x_d, y_d):
    from numpy import asarray
    alpha = asarray(alpha)
    x_d_ptr = hipPointer(x_d, (n,))
    y_d_ptr = hipPointer(y_d, (n,))
    print(handle)
    hip_check(hipblas.hipblasSaxpy(
        handle,
        n=n,
        alpha=alpha,
        x=x_d_ptr, incx=1,
        y=y_d_ptr, incy=1))
