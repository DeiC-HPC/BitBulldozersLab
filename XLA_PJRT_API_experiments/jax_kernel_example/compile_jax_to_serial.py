import jax
from jax._src.lib import xla_client
def f(x, y):
    return 2 * x + y

x_shape = jax.ShapeDtypeStruct((4,), jnp.float32)
y_shape = jax.ShapeDtypeStruct((4,), jnp.float32)
traced = jax.jit(f).trace(x_shape, y_shape)
lowered = traced.lower()
compiled = lowered.compile()
executable = compiled._executable.xla_extension_executable()

from jax._src import xla_bridge as xb
print('Available XLA backends:', xb.backends().keys())

backend = xb.get_backend('rocm')
serialized_executable = backend.serialize_executable(executable)

with open('foo.bin', 'wb') as fd:
    fd.write(serialized_executable)
    
