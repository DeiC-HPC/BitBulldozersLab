/*
 * Example of using XLA PJRT C API to run AOT-compiled JAX Kernels
 * 
 * This demonstrates:
 * 1. Loading a PJRT ROCM plugin
 * 2. Creating a client
 * 3. Loading compiled HLO code
 * 4. Creating device buffers for inputs/outputs
 * 5. Executing the computation
 * 6. Moving buffers from device to host
 */

#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include "pjrt/pjrt_c_api.h"

#define NUM_DEVICES 1
#define DEVICE_ID 0

static const PJRT_Api* api;
static PJRT_Client* client;
static PJRT_Device* device;

void PJRT_Init() {
  // Step 1.1: Load in the PJRT plugin
  void* handle = dlopen("pjrt/xla_rocm_plugin.so", RTLD_NOW | RTLD_LOCAL);
  const PJRT_Api* (*get_api)() = dlsym(handle, "GetPjrtApi");
  api = get_api();

  // Step 1.2: Create PJRT client
  PJRT_Client_Create_Args create_args = {
    .struct_size = PJRT_Client_Create_Args_STRUCT_SIZE
  };
  api->PJRT_Client_Create(&create_args);
  client = create_args.client;

  // Step 1.3: Get devices
  PJRT_Client_Devices_Args devices_args = {
    .struct_size = PJRT_Client_Devices_Args_STRUCT_SIZE,
    .client = client
  };
  api->PJRT_Client_Devices(&devices_args);
  device = devices_args.devices[DEVICE_ID];
}

PJRT_LoadedExecutable* Load_Kernel(const char* filename) {
  FILE* f = fopen(filename, "rb");

  fseek(f, 0, SEEK_END);
  long size = ftell(f);
  fseek(f, 0, SEEK_SET);

  char* buffer = malloc(size);
  fread(buffer, 1, size, f);
  fclose(f);

  PJRT_Executable_DeserializeAndLoad_Args exe_args = {
    .struct_size = PJRT_Executable_DeserializeAndLoad_Args_STRUCT_SIZE,
    .client = client,
    .serialized_executable=buffer,
    .serialized_executable_size=size
  };
  api->PJRT_Executable_DeserializeAndLoad(&exe_args);
  free(buffer);
  return exe_args.loaded_executable;
}

void Execute(PJRT_LoadedExecutable* executable,
	     PJRT_Buffer* buffer_x, PJRT_Buffer* buffer_y,
	     PJRT_Buffer* output[]) {
  PJRT_Buffer* input_h[2] = { buffer_x, buffer_y };
  PJRT_Buffer* const* const argument_lists[NUM_DEVICES] = { input_h };
  PJRT_Buffer** output_lists[NUM_DEVICES] = { output };

  PJRT_ExecuteOptions options = {
    .struct_size = PJRT_ExecuteOptions_STRUCT_SIZE,
  };

  PJRT_LoadedExecutable_Execute_Args execute_args = {
    .struct_size = PJRT_LoadedExecutable_Execute_Args_STRUCT_SIZE,
    .executable = executable,
    .execute_device = device,
    .argument_lists = argument_lists,
    .num_devices = NUM_DEVICES,
    .num_args = 2,
    .output_lists = output_lists,
    .options = &options,
  };
  api->PJRT_LoadedExecutable_Execute(&execute_args);
}


void Copy_HtD(float* input, size_t n, PJRT_Buffer** buffer){
  PJRT_Client_BufferFromHostBuffer_Args buffer_args = {
    .struct_size = PJRT_Client_BufferFromHostBuffer_Args_STRUCT_SIZE,
    .client = client,
    .data = input,
    .type = PJRT_Buffer_Type_F32,
    .dims = (int64_t[]){n},
    .num_dims = 1,
    .device = device
  };
  api->PJRT_Client_BufferFromHostBuffer(&buffer_args);
  *buffer = buffer_args.buffer;
}


void Copy_DtH(PJRT_Buffer *src, float *dst, size_t dst_size) {
  PJRT_Buffer_ToHostBuffer_Args to_host_args = {
    .struct_size = PJRT_Buffer_ToHostBuffer_Args_STRUCT_SIZE,
    .src = src,
    .dst = dst,
    .dst_size = dst_size
  };
  api->PJRT_Buffer_ToHostBuffer(&to_host_args);
  
  PJRT_Event_Await_Args ready = {
    .struct_size = PJRT_Event_Await_Args_STRUCT_SIZE,
    .event = to_host_args.event,
  };
  api->PJRT_Event_Await(&ready);
  
  PJRT_Event_Destroy_Args destroy_ready_event = {
    .struct_size = PJRT_Event_Destroy_Args_STRUCT_SIZE,
    .event = to_host_args.event
  };
  api->PJRT_Event_Destroy(&destroy_ready_event);
}

void Destroy_Args(PJRT_Buffer** output_d, PJRT_Buffer* buffer_x, PJRT_Buffer* buffer_y,
		  PJRT_LoadedExecutable* executable)
{
  PJRT_Buffer_Destroy_Args destroy_inner_device_output = {
    .struct_size = PJRT_Buffer_Destroy_Args_STRUCT_SIZE,
    .buffer = output_d[DEVICE_ID]
  };
  api->PJRT_Buffer_Destroy(&destroy_inner_device_output);
  
  PJRT_Buffer_Destroy_Args destroy_x = {
    .struct_size = PJRT_Buffer_Destroy_Args_STRUCT_SIZE,
    .buffer = buffer_x
  };
  api->PJRT_Buffer_Destroy(&destroy_x);

  PJRT_Buffer_Destroy_Args destroy_y = {
    .struct_size = PJRT_Buffer_Destroy_Args_STRUCT_SIZE,
    .buffer = buffer_y
  };
  api->PJRT_Buffer_Destroy(&destroy_y);

  PJRT_LoadedExecutable_Destroy_Args destroy_exec = {
    .struct_size = PJRT_LoadedExecutable_Destroy_Args_STRUCT_SIZE,
    .executable = executable
  };
  api->PJRT_LoadedExecutable_Destroy(&destroy_exec);

  PJRT_Client_Destroy_Args destroy_client = {
    .struct_size = PJRT_Client_Destroy_Args_STRUCT_SIZE,
    .client = client
  };
  api->PJRT_Client_Destroy(&destroy_client);
}


int main(int argc, char** argv) {
  // Step 1: Initialize API, Client and Device
  PJRT_Init();

  // Step 2: Load compiled binary
  PJRT_LoadedExecutable* executable = Load_Kernel("../jax_kernel_example/foo.bin");
  size_t num_outputs = 1;
  size_t size_out = 4, size_in = 4;
  
  // Step 3: Prepare input / output data buffers
  float input_x[] = {1.0f, 2.0f, 3.0f, 4.0f};
  float input_y[] = {5.5f, 6.6f, 7.7f, 8.8f};
  float output_h[size_out];

  PJRT_Buffer* buffer_x = NULL, *buffer_y = NULL, *output_d[num_outputs];
  Copy_HtD(input_x, size_in, &buffer_x);
  Copy_HtD(input_y, size_in, &buffer_y);
  
  // Step 4: Execute the computation
  Execute(executable, buffer_x, buffer_y, output_d);
  
  // Step 5: Retrieve results
  Copy_DtH(output_d[DEVICE_ID], output_h, sizeof(output_h));

  printf("   Output:   [%.1f, %.1f, %.1f, %.1f]\n",
	 output_h[0], output_h[1], output_h[2], output_h[3]);
  printf("   Expected: [7.5, 10.6, 13.7, 16.8]\n\n");

  // Step 6: Cleanup
  Destroy_Args(output_d, buffer_x, buffer_y, executable);
  return 0;
}

