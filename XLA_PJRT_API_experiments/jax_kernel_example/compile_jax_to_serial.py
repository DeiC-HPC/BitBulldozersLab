from jax._src.lib import xla_client
import jax

def f(x, y):
    return 2 * x + y

x_shape = jax.ShapeDtypeStruct((4,), jax.numpy.float32)
y_shape = jax.ShapeDtypeStruct((4,), jax.numpy.float32)
compiled = jax.jit(f).trace(x_shape, y_shape).lower().compile()

from jax._src import xla_bridge as xb
print('Available XLA backends:', xb.backends().keys())

backend = xb.get_backend('rocm')
executable = compiled._executable.xla_extension_executable()
serialized_executable = backend.serialize_executable(executable)

with open('foo.bin', 'wb') as fd:
    fd.write(serialized_executable)
    
