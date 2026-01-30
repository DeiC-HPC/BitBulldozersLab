#!/usr/bin/env python3
"""
Compile JAX functions to HLO for AOT execution.
This script demonstrates how to export JAX functions to HLO format.

Combined AI generated and modified with
https://github.com/joaospinto/call_jax_from_cpp/blob/5ca04351ef8c545f3781feaa29a37f68b8260034/call_jax_from_cpp/simple_jax_example.py
"""

import jax
import jax.numpy as jnp
from jax import export
import numpy as np

import os
os.environ['JAX_PLATFORMS'] = 'rocm'

def simple_add(x, y):
    return x + y

def main():
    # Example 1: Simple addition
    print("\n1. Compiling simple_add function...")
    x_shape = jax.ShapeDtypeStruct((4,), jnp.float32)
    y_shape = jax.ShapeDtypeStruct((4,), jnp.float32)

    jit_f = jax.jit(simple_add)
    lowered = jit_f.lower(x_shape, y_shape)
    
    # Save the HLO module
    with open("simple_add.txt", "w") as hlo_f:
        hlo = lowered.compile().as_text()
        hlo_f.write(hlo)
    print(f"Saved HLO to simple_add.txt")

    fmt = 'hlo' # 'hlo' or 'stablehlo'
    serialized_proto = lowered.compiler_ir(fmt).as_serialized_hlo_module_proto()
    

    # Save serialized format
    with open("simple_add.hlo", "wb") as bf:
        bf.write(serialized_proto)

    # MLIR Stablehlo
    exported = export.export(jit_f)(x_shape, y_shape)
    serialized = exported.serialize()

    # TODO(joao): this does not appear to be useful; the C/C++ APIs seem to required a serialized ExecutableAndOptionsProto.
    with open("simple_add.stablehlo", "wb") as bf2:
        bf2.write(serialized)
        
    print("\n✓ Compilation complete!")
    print("\nGenerated files:")
    print("  - simple_add.txt (text format)")
    print("  - simple_add.hlo (HLO format)")
    print("  - simple_add.stable (StableHLO format)")

if __name__ == "__main__":
    main()
