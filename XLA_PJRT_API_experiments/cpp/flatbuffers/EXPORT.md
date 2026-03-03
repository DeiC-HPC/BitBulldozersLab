## Notes regarding Polymorphism and moving compile-step to C++

Currently, we can take the JIT-compiled object in JAX, and fully AOT-compile it in Python and serialize the resulting executable that can be loaded in C++ with the PJRT API. This is illustrated in `compile_jax_to_serial.py`. This is incompatible with the JAX feature of polymophism, which require using the `jax.export` module as illustrated in `compile_jax_to_polymorphism`.

### Understanding exported.serialize objects
We cannot directly use the serialized objects from the `jax.export` module because they are [flatbuffer](https://flatbuffers.dev/languages/cpp/) format. This object contains most importantly a serialized MLIR object that we could likely use in PJRT in C++
```
Key: "mlir_module_serialized" has Value:
 b"ML\xefR\rStableHLO_v1.9.5\x00\x01#\x05\...
```
But it also contains a variety of other things,
```
Key: "fun_name" has Value:
 simple_add
Key: "in_tree" has Value:
 PyTreeDef(((*, *), {}))
Key: "in_avals" has Value:
 (ShapedArray(float32[a]), ShapedArray(float32[a]))
...
```

We can likely parse these objects on the C++ side by using the flatbuffers tools:
`Run flatc --cpp --gen-onefile serialization.fbs` where serialization.fbs is the schema written for the Jax export object and is located in `jax/jax/_src/export/serialization.fbs`, which should generate a header-file that is compatible with the Python class definition in JAX. From this object we can likely extract the mlir_module_serialized and parse it using PJRT.

The most likely advantage is that we would get the intermediate representation in C++ so that we can compile it more dynamically. However, the downside is that we will likely lose many of the JAX features such as polymorphism anyways. See here for the [call](https://github.com/jax-ml/jax/blob/a5854e44cb01c1b6aa24d43ab997e0ed77d8dab6/jax/_src/export/_export.py#L324) function that implements the export-features on a deserialized object in `call_jax_to_polymorphism.py`. 