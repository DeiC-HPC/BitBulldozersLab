# RCCL Communication experiments

The repository contains simple examples of using the RCCL communication library to perform GPU-to-GPU communications. This library is highly utilized in the C++ PyTorch backend.

## Single GPU RCCL reduction using simple HIP buffer
A RCCL communicator is based on three components, a CPU rank, a GPU device and one (or more) opaque unique IDs of the root CPU ranks. Thus we notice a first peculiarity: The communicator that orchastrates GPU-to-GPU communication is located on the CPU. 

In the `src/rccl-hip.cpp` example, we initialize such a communicator, and then allocate test arrays onto the GPU using hip buffers. Compiling and running this example using `./compile.sh` followed by `sbatch run-single.sh`, we see the test array is sent and received on the same GPU as if nothing happened. For something to actually happen we need multiple GPUs, and to handle multiple GPUs we require multiple CPU ranks in order to create a new RCCL communicator for each GPU device.

## Extending to Multi GPU RCCL reduction using OpenMP
In the `src/rccl-openmp.cpp` example, we are using OpenMP to create two ranks, and their respective RCCL communicator as well as allocate the test array to both GPUs. Running this example using `sbatch run-openmp.sh`, we see now that the numbers 1 through `n` in the inital array is doubled in the received array buffer after the reduce operation. To emphasize, the reduction is not done on the array of numbers but on the array of arrays on different GPUs.