# Using flatbuffers Interface

In order to generate the `serialization_generated.h` in this directory, we have done the following:

- Install flatbuffers, `sudo snap install flatbuffers` to provide `flatc`
- git close the jax repository and find the flatbuffer schema file at `jax/jax/_src/export/serialization.fbs`
- Run `flatc --cpp --gen-onefile serialization.fbs` to generate the headerfile for C++

The generated_serialization is another API interface that allows for creating `jax.export` like objects in other programming languages. On the C++ side we get access to the very convenient jax_export::serialization::GetExported method which takes in a pointer to the serialzed flatbuffer and builds the exported object.
