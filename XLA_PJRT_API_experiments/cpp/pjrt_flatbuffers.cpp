/*
 * Example of using XLA PJRT C API to run AOT-compiled JAX functions
 * 
 * This demonstrates:
 * 1. Loading a PJRT plugin (CPU in this case)
 * 2. Creating a client
 * 3. Loading compiled HLO code
 * 4. Creating buffers for inputs/outputs
 * 5. Executing the computation
 */

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include "../c/pjrt/pjrt_c_api.h"
#include "flatbuffers/serialization_generated.h"

using namespace jax_export::serialization;

#define CHECK_STATUS(expr, msg) \
    do { \
        PJRT_Error* err = (expr); \
        if (err != NULL) { \
            PJRT_Error_Message_Args message_args = { \
                .struct_size = PJRT_Error_Message_Args_STRUCT_SIZE, \
                .error = err \
            }; \
            PJRT_Error_GetCode_Args getcode_args = { \
                .struct_size = PJRT_Error_GetCode_Args_STRUCT_SIZE, \
                .error = err \
            }; \
            \
            api->PJRT_Error_Message(&message_args); \
            api->PJRT_Error_GetCode(&getcode_args); \
            \
            fprintf(stderr, "Error: %s\n", msg); \
            fprintf(stderr, "Error Code: %d\n", getcode_args.code); \
            fprintf(stderr, "Error Message: %.*s\n", \
                    (int)message_args.message_size, message_args.message); \
            \
            PJRT_Error_Destroy_Args destroy_args = { \
                .struct_size = PJRT_Error_Destroy_Args_STRUCT_SIZE, \
                .error = err \
            }; \
            api->PJRT_Error_Destroy(&destroy_args); \
            exit(1); \
        } \
    } while(0)


// Global API pointer
const PJRT_Api* api = NULL;

// Load PJRT plugin dynamically
const PJRT_Api* load_pjrt_plugin(const char* plugin_path) {
    void* handle = dlopen(plugin_path, RTLD_NOW | RTLD_LOCAL);
    if (!handle) {
        fprintf(stderr, "Failed to load plugin: %s\n", dlerror());
        return NULL;
    }
    
    const PJRT_Api* (*get_api)() = (const PJRT_Api* (*)())dlsym(handle, "GetPjrtApi");
    if (!get_api) {
        fprintf(stderr, "Failed to find GetPjrtApi symbol\n");
        dlclose(handle);
        return NULL;
    }
    
    return get_api();
}

// Read file contents
char* read_file(const char* filename, size_t* size) {
    FILE* f = fopen(filename, "rb");
    if (!f) {
        fprintf(stderr, "Failed to open file: %s\n", filename);
        return NULL;
    }
    
    fseek(f, 0, SEEK_END);
    *size = ftell(f);
    fseek(f, 0, SEEK_SET);
    
    char* buffer = (char *)malloc(*size);
    if (!buffer) {
        fclose(f);
        return NULL;
    }
    
    fread(buffer, 1, *size, f);
    fclose(f);
    return buffer;
}

int main(int argc, char** argv) {
    printf("XLA PJRT C API Example: Running AOT-compiled JAX\n");
    printf("================================================\n\n");
    
    // Step 1: Load PJRT plugin (CPU)
    printf("1. Loading PJRT CPU plugin...\n");
    // api = load_pjrt_plugin("/home/joaso/fennol/xla-pjrt-c-api/BitBulldozersLab/XLA_PJRT_API_experiments/c/pjrt_c_api_gpu_plugin.so");
    api = load_pjrt_plugin("../c/pjrt/xla_rocm_plugin.so");
    
    if (!api) {
        fprintf(stderr, "Failed to load PJRT plugin\n");
        return 1;
    }
    printf("   ✓ Plugin loaded\n\n");

    // Step 1.5: Read plugin attributes
    PJRT_Plugin_Attributes_Args attr_args = {
      .struct_size = PJRT_Plugin_Attributes_Args_STRUCT_SIZE
    };
    CHECK_STATUS(api->PJRT_Plugin_Attributes(&attr_args), "Failed to get Plugin Attrs");

    const PJRT_NamedValue* attr = attr_args.attributes;
    for (size_t i = 0; i < attr_args.num_attributes; i++) {
      printf("%s\n", attr[i].name);
      PJRT_NamedValue_Type type = attr[i].type;
      if (attr[i].type == PJRT_NamedValue_kString) {
	printf("%s\n", attr[i].string_value);
      } else if (attr[i].type == PJRT_NamedValue_kInt64) {
	printf("%li\n", attr[i].int64_value);
      } else if (attr[i].type == PJRT_NamedValue_kInt64List) {
	for (size_t j = 0; j < attr[i].value_size; j++) {
	  printf("%li.", attr[i].int64_array_value[j]);
	}
	printf("\n");
      }	
    }
    
      
    // Step 2: Create PJRT client
    printf("2. Creating PJRT client...\n");
    PJRT_Client_Create_Args create_args = {
        .struct_size = PJRT_Client_Create_Args_STRUCT_SIZE
    };
    CHECK_STATUS(api->PJRT_Client_Create(&create_args), "Failed to create client");
    PJRT_Client* client = create_args.client;
    printf("   ✓ Client created\n\n");
    
    // Step 3: Get devices
    printf("3. Getting available devices...\n");
    PJRT_Client_Devices_Args devices_args = {
        .struct_size = PJRT_Client_Devices_Args_STRUCT_SIZE,
        .client = client
    };
    CHECK_STATUS(api->PJRT_Client_Devices(&devices_args), "Failed to get devices");
    printf("   ✓ Found %zu device(s)\n\n", devices_args.num_devices);
    
    if (devices_args.num_devices == 0) {
        fprintf(stderr, "No devices available\n");
        return 1;
    }
    PJRT_Device* device = devices_args.devices[0];
    
    // Step 4: Load compiled HLO code
    printf("4. Loading compiled HLO code...\n");

    size_t flatbuffer_size;
    char* flatbuffer = read_file("../jax_kernel_example/simple_add_stablehlo_static.flatbuffer", &flatbuffer_size);
    // char* flatbuffer = read_file("../jax_kernel_example/simple_add.stablehlo", &flatbuffer_size);
    
    const auto* exported = GetExported(flatbuffer);
    auto* mlir_bytes = exported->mlir_module_serialized();
    
    char* code = (char *)mlir_bytes->data();
    size_t code_size = mlir_bytes->size();

    // size_t code_size;
    // char* code = read_file("../jax_kernel_example/simple_add.stablehlo", &code_size);
    if (!code) {
        fprintf(stderr, "Failed to read compiled code\n");
        return 1;
    }

    const PJRT_Program program = {
      .struct_size = PJRT_Program_STRUCT_SIZE,
      .code = code,
      .code_size = code_size,
      .format = "mlir",
      .format_size = strlen("mlir")
    };

    //const char* compile_options;
    //size_t compile_options_size;
    
    PJRT_Client_Compile_Args compile_args = {
      .struct_size = PJRT_Client_Compile_Args_STRUCT_SIZE,
      .client = client,
      .program = &program,
      // .compile_options=compile_options,
      // .compile_options_size=compile_options_size,
    };

    CHECK_STATUS(api->PJRT_Client_Compile(&compile_args), "Failed to compile");
    PJRT_LoadedExecutable* executable = compile_args.executable;

    // PJRT_Executable_DeserializeAndLoad_Args exe_args = {
    //   .struct_size = PJRT_Executable_DeserializeAndLoad_Args_STRUCT_SIZE,
    //   .client = client,
    //   .serialized_executable=code,
    //   .serialized_executable_size=code_size
    // };

    // CHECK_STATUS(api->PJRT_Executable_DeserializeAndLoad(&exe_args), "Failed to deserialize and load");
    // PJRT_LoadedExecutable* executable = exe_args.loaded_executable;

    printf("   ✓ Deserialized and Loaded executable\n\n");
    free(code);
    
    // Step 5: Prepare input data
    printf("5. Preparing input data...\n");
    float input_x[] = {1.0f, 2.0f, 3.0f, 4.0f};
    float input_y[] = {5.0f, 6.0f, 7.0f, 8.0f};
    size_t input_size = 4 * sizeof(float);
    const int64_t dims[] = {4};
      
    printf("   Input X: [%.1f, %.1f, %.1f, %.1f]\n", 
           input_x[0], input_x[1], input_x[2], input_x[3]);
    printf("   Input Y: [%.1f, %.1f, %.1f, %.1f]\n\n",
           input_y[0], input_y[1], input_y[2], input_y[3]);
    
    // Step 6: Create input buffers
    printf("6. Creating input buffers...\n");

    // TODO: Can we create a PJRT buffer directly from a raw rocm pointer?

    // Buffer for X
    PJRT_Client_BufferFromHostBuffer_Args buffer_x_args = {
        .struct_size = PJRT_Client_BufferFromHostBuffer_Args_STRUCT_SIZE,
        .client = client,
        .data = &input_x,
        .type = PJRT_Buffer_Type_F32,
        .dims = dims,
        .num_dims = 1,
        .device = device
        // .host_buffer_semantics = PJRT_HostBufferSemantics_kImmutableUntilTransferCompletes
    };
    CHECK_STATUS(api->PJRT_Client_BufferFromHostBuffer(&buffer_x_args), 
                 "Failed to create buffer X");
    PJRT_Buffer* buffer_x = buffer_x_args.buffer;
    
    // Buffer for Y
    PJRT_Client_BufferFromHostBuffer_Args buffer_y_args = {
        .struct_size = PJRT_Client_BufferFromHostBuffer_Args_STRUCT_SIZE,
        .client = client,
        .data = &input_y,
        .type = PJRT_Buffer_Type_F32,
        .dims = dims,
        .num_dims = 1,
        .device = device
        // .host_buffer_semantics = PJRT_HostBufferSemantics_kImmutableUntilTransferCompletes
    };
    CHECK_STATUS(api->PJRT_Client_BufferFromHostBuffer(&buffer_y_args),
                 "Failed to create buffer Y");
    PJRT_Buffer* buffer_y = buffer_y_args.buffer;
    printf("   ✓ Input buffers created\n\n");
    
    // Step 7: Execute the computation
    printf("7. Executing computation...\n");
    PJRT_Buffer* device_args[2] = { buffer_x, buffer_y };
    PJRT_Buffer* const* const argument_lists[1] = { device_args };

    PJRT_Buffer* outputs_for_device[4];
    PJRT_Buffer** output_lists[1] = { outputs_for_device };

    PJRT_ExecuteOptions options = {0};
    options.struct_size = PJRT_ExecuteOptions_STRUCT_SIZE;

    PJRT_LoadedExecutable_Execute_Args execute_args = {
        .struct_size = PJRT_LoadedExecutable_Execute_Args_STRUCT_SIZE,
        .executable = executable,
	.options = &options,
        .argument_lists = argument_lists,
        .num_devices = 1,
        .num_args = 2,
        .output_lists = output_lists,
	.execute_device = device,
    };

    CHECK_STATUS(api->PJRT_LoadedExecutable_Execute(&execute_args),
                 "Failed to execute");
    printf("   ✓ Execution complete\n\n");
    
    // Step 8: Retrieve results
    printf("8. Retrieving results...\n");

    float output[4];
    PJRT_Buffer_ToHostBuffer_Args to_host_args = {
      .struct_size = PJRT_Buffer_ToHostBuffer_Args_STRUCT_SIZE,
      .src = *output_lists[0],
      .dst = output,
      .dst_size = sizeof(output)
    };
    CHECK_STATUS(api->PJRT_Buffer_ToHostBuffer(&to_host_args),
		 "Failed to copy result to host");

    PJRT_Event_Await_Args ready = {
        .struct_size = PJRT_Event_IsReady_Args_STRUCT_SIZE,
        .event = to_host_args.event
    };
    CHECK_STATUS(api->PJRT_Event_Await(&ready), "Failed to wait for ready event.");

    printf("   Output: [%.1f, %.1f, %.1f, %.1f]\n",
           output[0], output[1], output[2], output[3]);
    printf("   Expected: [7.0, 10.0, 13.0, 16.0]\n\n");
        
    // Cleanup output buffer
    printf("9. Cleaning up...\n");
    PJRT_Buffer_Destroy_Args destroy_out_device_buffer_args = {
      .struct_size = PJRT_Buffer_Destroy_Args_STRUCT_SIZE,
      .buffer = *output_lists[0]
    };
    api->PJRT_Buffer_Destroy(&destroy_out_device_buffer_args);
    
    // Cleanup
    // TODO: For proper functioning may have to first check if the runtime is done with the buffer
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

    PJRT_Event_Destroy_Args destroy_ready_event = {
        .struct_size = PJRT_Event_Destroy_Args_STRUCT_SIZE,
        .event = to_host_args.event
    };
    api->PJRT_Event_Destroy(&destroy_ready_event);

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

    printf("   ✓ Cleanup complete\n\n");
    printf("Success! ✓\n");
    
    return 0;
}
