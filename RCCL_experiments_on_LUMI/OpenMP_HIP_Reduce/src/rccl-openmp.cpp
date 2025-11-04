#include <iostream>
#include <hip/hip_runtime.h>
#include <rccl/rccl.h>
#include <omp.h>

void HIP_CHECK(hipError_t err) {
  if (err != hipSuccess) {
    std::cerr << "HIP error: " << hipGetErrorString(err) << std::endl;
    exit(-1);
  }
}

void RCCL_CHECK(ncclResult_t err) {
  if (err != ncclSuccess) {
    std::cerr << "RCCL error: " << ncclGetErrorString(err) << std::endl;
    exit(-1);
  }
}

int main(int argc, char* argv[]) {
  int nDevices = 0;
  HIP_CHECK(hipGetDeviceCount(&nDevices));
  std::cout << nDevices << " devices found." << std::endl;

  int v;
  RCCL_CHECK(ncclGetVersion(&v));
  std::cout << "RCCL version: " << v << std::endl;
  
  ncclUniqueId id;
  RCCL_CHECK(ncclGetUniqueId(&id));
  int root = 0;
  
  #pragma omp parallel
  { 
      int myRank = omp_get_thread_num();
      std::cout << "My rank: " << myRank << std::endl;

      HIP_CHECK(hipSetDevice(myRank));
      
      // Initialize communicator
      ncclComm_t myComm;
      RCCL_CHECK(ncclCommInitRank(&myComm, nDevices, id, myRank));
    
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
      if (myRank == root) {
	HIP_CHECK(hipMalloc(&d_recv, N * sizeof(float)));
      }
      HIP_CHECK(hipMemcpy(d_send, h_send, N * sizeof(float), hipMemcpyHostToDevice));

      // Setup GPU Stream
      hipStream_t stream;
      HIP_CHECK(hipStreamCreate(&stream));

      // Perform operation
      std::cout << "Performing RCCL Reduce operation on rank " << myRank << std::endl;
      RCCL_CHECK(ncclReduce(d_send, d_recv, N, ncclFloat, ncclSum, root, myComm, stream));
      HIP_CHECK(hipStreamSynchronize(stream));
      if (myRank == root) {
	HIP_CHECK(hipMemcpy(h_recv, d_recv, N * sizeof(float), hipMemcpyDeviceToHost));
      }

      if (myRank == root) {
	// Verify results (with single GPU, sum should equal input)
	std::cout << "Verifying results..." << std::endl;
	bool success = true;
	for (int i = 0; i < 10; i++) {  // Check first 10 elements
	  std::cout << "sent=" << h_send[i] 
		    << ", received=" << h_recv[i] << std::endl;
	  if (h_recv[i] != nDevices * h_send[i]) {
	    success = false;
	  }
	}
    
	if (success) {
	  std::cout << "SUCCESS: Reduce completed correctly!" << std::endl;
	} else {
	  std::cout << "FAILURE: Results do not match!" << std::endl;
	}
      } 
      // Cleanup
      RCCL_CHECK(ncclCommDestroy(myComm));
      HIP_CHECK(hipStreamDestroy(stream));
      HIP_CHECK(hipFree(d_send));
      if (myRank == root) {
	HIP_CHECK(hipFree(d_recv));
      }
      delete[] h_send;
      delete[] h_recv;
      if (myRank == root) {
	std::cout << "Cleanup complete." << std::endl;
      }
  }   
  return 0;
}
