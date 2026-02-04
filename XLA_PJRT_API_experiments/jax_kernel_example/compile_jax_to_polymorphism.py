import jax
import jax.numpy as jnp
from jax import export
import numpy as np

def simple_add(x, y):
    return x + y

def main():    
    a = export.symbolic_shape("a")
    x_shape = jax.ShapeDtypeStruct(a, jnp.float32)
    y_shape = jax.ShapeDtypeStruct(a, jnp.float32)

    jit_f = jax.jit(simple_add)
    
    # MLIR Stablehlo
    exported = export.export(jit_f)(x_shape, y_shape)
    print(exported.in_avals)
    print(exported.out_avals)

    res = exported.call(np.ones(5, dtype=np.float32), 2 * np.ones(5, dtype=np.float32))
    serialized = exported.serialize()

    with open("simple_add_stablehlo.flatbuffer", "wb") as bf2:
        bf2.write(serialized)
        
if __name__ == "__main__":
    main()
