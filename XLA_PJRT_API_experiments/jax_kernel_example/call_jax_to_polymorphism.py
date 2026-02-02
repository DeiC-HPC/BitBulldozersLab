import numpy as np

from jax import export

def main():
    with open("simple_add_stablehlo.flatbuffer", "rb") as bf:
        serialized = bf.read()

    exp = export.deserialize(serialized)
    for key, value in exp.__dict__.items():
        print(f'Key: "{key}" has Value:\n {value}')
    res = exp.call(np.ones(5, dtype=np.float32), 2 * np.ones(5, dtype=np.float32))
    print(res, res.shape)
    
if __name__ == "__main__":
    main()
