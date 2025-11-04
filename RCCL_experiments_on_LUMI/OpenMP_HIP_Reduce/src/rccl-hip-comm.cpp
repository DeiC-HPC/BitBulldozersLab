#include <iostream>
#include <hip/hip_runtime.h>
#include <rccl/rccl.h>

void HIP_CHECK(hipError_t error) {
  if (error != hipSuccess) {
    std::cerr << "HIP error: " << hipGetErrorString(error) << std::endl;
    exit(-1);
  }
}

#define HIP_CHECK(cmd) \
    do { \
        hipError_t error = (cmd); \
        if (error != hipSuccess) { \
            std::cerr << "HIP error: " << hipGetErrorString(error) \
                      << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
            exit(EXIT_FAILURE); \
        } \
    } while(0)

#define RCCL_CHECK(cmd) \
    do { \
        ncclResult_t result = (cmd); \
        if (result != ncclSuccess) { \
            std::cerr << "RCCL error: " << ncclGetErrorString(result) \
                      << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
            exit(EXIT_FAILURE); \
        } \
    } while(0)

int main(int argc, char* argv[]) {
    int nDevices = 0;
    HIP_CHECK(hipGetDeviceCount(&nDevices));
    
    if (nDevices < 1) {
        std::cerr << "No GPU devices found!" << std::endl;
        return EXIT_FAILURE;
    }
    
    std::cout << "Found " << nDevices << " GPU device(s)" << std::endl;
    
    // Use first GPU for this simple example
    int deviceId = 0;
    HIP_CHECK(hipSetDevice(deviceId));
    
    // Initialize RCCL
    ncclComm_t comm;
    ncclUniqueId id;
    
    // Generate unique ID (in multi-process setup, rank 0 generates and broadcasts)
    RCCL_CHECK(ncclGetUniqueId(&id));
    
    // Initialize communicator
    // For single GPU: nRanks=1, rank=0
    RCCL_CHECK(ncclCommInitRank(&comm, 1, id, 0));
    
    // Allocate data
    const int N = 1024;
    float* h_send = new float[N];
    float* h_recv = new float[N];
    
    // Initialize send buffer
    for (int i = 0; i < N; i++) {
        h_send[i] = static_cast<float>(i);
    }
    
    // Allocate device memory
    float *d_send, *d_recv;
    HIP_CHECK(hipMalloc(&d_send, N * sizeof(float)));
    HIP_CHECK(hipMalloc(&d_recv, N * sizeof(float)));
    
    // Copy data to device
    HIP_CHECK(hipMemcpy(d_send, h_send, N * sizeof(float), hipMemcpyHostToDevice));
    
    // Create HIP stream
    hipStream_t stream;
    HIP_CHECK(hipStreamCreate(&stream));
    
    std::cout << "Performing RCCL AllReduce operation..." << std::endl;
    
    // Perform AllReduce (sum operation)
    RCCL_CHECK(ncclAllReduce(d_send, d_recv, N, ncclFloat, ncclSum, comm, stream));
    
    // Wait for completion
    HIP_CHECK(hipStreamSynchronize(stream));
    
    // Copy result back to host
    HIP_CHECK(hipMemcpy(h_recv, d_recv, N * sizeof(float), hipMemcpyDeviceToHost));
    
    // Verify results (with single GPU, sum should equal input)
    std::cout << "Verifying results..." << std::endl;
    bool success = true;
    for (int i = 0; i < 10; i++) {  // Check first 10 elements
        std::cout << "Element " << i << ": sent=" << h_send[i] 
                  << ", received=" << h_recv[i] << std::endl;
        if (h_recv[i] != h_send[i]) {
            success = false;
        }
    }
    
    if (success) {
        std::cout << "SUCCESS: AllReduce completed correctly!" << std::endl;
    } else {
        std::cout << "FAILURE: Results do not match!" << std::endl;
    }
    
    // Cleanup
    RCCL_CHECK(ncclCommDestroy(comm));
    HIP_CHECK(hipStreamDestroy(stream));
    HIP_CHECK(hipFree(d_send));
    HIP_CHECK(hipFree(d_recv));
    delete[] h_send;
    delete[] h_recv;
    
    std::cout << "Cleanup complete." << std::endl;
    
    return 0;
}
