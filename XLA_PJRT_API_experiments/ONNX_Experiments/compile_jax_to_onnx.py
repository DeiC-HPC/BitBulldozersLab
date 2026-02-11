import jax
import jax.numpy as jnp
from jax2onnx import to_onnx

def simple_add(x, y):
    return 2 * x + y

x_shape = jax.ShapeDtypeStruct(('B',), jnp.float32)
y_shape = jax.ShapeDtypeStruct(('B',), jnp.float32)

input_specs = [x_shape, y_shape]

to_onnx(simple_add,
        inputs=input_specs,
        model_name="simple_add",
        return_mode="file",
        output_path="simple_add.onnx",
        enable_double_precision=False)

