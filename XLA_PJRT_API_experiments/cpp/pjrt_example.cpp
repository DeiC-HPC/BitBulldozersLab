#include "../c/pjrt/pjrt_c_api.h"
#include <dlfcn.h>
#include <iostream>

#define CHECK_STATUS(expr, msg)						\
  do {									\
    PJRT_Error* err = (expr);						\
    if (err != NULL) {							\
      PJRT_Error_Message_Args message_args = {				\
	.struct_size = PJRT_Error_Message_Args_STRUCT_SIZE,		\
	.error = err							\
      };								\
      PJRT_Error_GetCode_Args getcode_args = {				\
	.struct_size = PJRT_Error_GetCode_Args_STRUCT_SIZE,		\
	.error = err							\
      };								\
									\
      api->PJRT_Error_Message(&message_args);				\
      api->PJRT_Error_GetCode(&getcode_args);				\
      								        \
      fprintf(stderr, "Error: %s\n", msg);				\
      fprintf(stderr, "Error Code: %d\n", getcode_args.code);		\
      fprintf(stderr, "Error Message: %.*s\n",				\
	      (int)message_args.message_size, message_args.message);	\
									\
      PJRT_Error_Destroy_Args destroy_args = {				\
	.struct_size = PJRT_Error_Destroy_Args_STRUCT_SIZE,		\
	.error = err							\
      };								\
      api->PJRT_Error_Destroy(&destroy_args);				\
      exit(1);								\
    }									\
  } while(0)

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


// Global API pointer
const PJRT_Api* api = NULL;

// Load PJRT plugin dynamically
const PJRT_Api* load_pjrt_plugin(const char* plugin_path) {
  void* handle = dlopen(plugin_path, RTLD_NOW | RTLD_LOCAL);
  if (!handle) {
    std::cerr << "Failed to load plugin: " << dlerror() << std::endl;
    return NULL;
  }
    
  const PJRT_Api* (*get_api)() = (const PJRT_Api* (*)())dlsym(handle, "GetPjrtApi");
  if (!get_api) {
    std::cerr << "Failed to find GetPjrtApi symbol\n" << std::endl;
    dlclose(handle);
    return NULL;
  }
    
  return get_api();
}

int main(int argc, char** argv) {
  api = load_pjrt_plugin("../c/pjrt/xla_rocm_plugin.so");
  PJRT_Plugin_Attributes_Args attr_args = {
    .struct_size = PJRT_Plugin_Attributes_Args_STRUCT_SIZE
  };
  CHECK_STATUS(api->PJRT_Plugin_Attributes(&attr_args), "Failed to get Plugin Attrs");

  const PJRT_NamedValue* attr = attr_args.attributes;
  for (size_t i = 0; i < attr_args.num_attributes; i++) {
    std::cout << attr[i].name << std::endl;
    PJRT_NamedValue_Type type = attr[i].type;
    if (attr[i].type == PJRT_NamedValue_kString) {
      std::cout << attr[i].string_value << std::endl;
    } else if (attr[i].type == PJRT_NamedValue_kInt64) {
      std::cout << attr[i].int64_value << std::endl;
    } else if (attr[i].type == PJRT_NamedValue_kInt64List) {
      for (size_t j = 0; j < attr[i].value_size; j++) {
	std::cout << attr[i].int64_array_value[j] << '.';
      }
      std::cout << std::endl;
    }
  }

  PJRT_Client_Create_Args create_args = {
    .struct_size = PJRT_Client_Create_Args_STRUCT_SIZE
  };
  CHECK_STATUS(api->PJRT_Client_Create(&create_args), "Failed to create client");
  PJRT_Client* client = create_args.client;
  
  PJRT_Client_Devices_Args devices_args = {
    .struct_size = PJRT_Client_Devices_Args_STRUCT_SIZE,
    .client = client
  };
  CHECK_STATUS(api->PJRT_Client_Devices(&devices_args), "Failed to get devices");
  PJRT_Device* device = devices_args.devices[0];
  
  size_t code_size;
  const char* code = read_file("../jax_kernel_example/foo.bin", &code_size);
  
  PJRT_Executable_DeserializeAndLoad_Args exe_args = {
    .struct_size = PJRT_Executable_DeserializeAndLoad_Args_STRUCT_SIZE,
    .client = client,
    .serialized_executable=code,
    .serialized_executable_size=code_size
  };

  CHECK_STATUS(api->PJRT_Executable_DeserializeAndLoad(&exe_args), "Failed to deserialize and load");
  PJRT_LoadedExecutable* loaded_executable = exe_args.loaded_executable;

  float input_x = 1.0f;
  float input_y = 2.0f;
  size_t input_size = sizeof(float);

  PJRT_Client_BufferFromHostBuffer_Args buffer_x_args = {
        .struct_size = PJRT_Client_BufferFromHostBuffer_Args_STRUCT_SIZE,
        .client = client,
        .data = input_x,
        .type = PJRT_Buffer_Type_F32,
        .dims = (int64_t[]){1},
        .num_dims = 1,
        .device = device
    };
    CHECK_STATUS(api->PJRT_Client_BufferFromHostBuffer(&buffer_x_args), 
                 "Failed to create buffer X");
    PJRT_Buffer* buffer_x = buffer_x_args.buffer;
    
    // Buffer for Y
    PJRT_Client_BufferFromHostBuffer_Args buffer_y_args = {
        .struct_size = PJRT_Client_BufferFromHostBuffer_Args_STRUCT_SIZE,
        .client = client,
        .data = input_y,
        .type = PJRT_Buffer_Type_F32,
        .dims = (int64_t[]){1},
        .num_dims = 1,
        .device = device
    };
    CHECK_STATUS(api->PJRT_Client_BufferFromHostBuffer(&buffer_y_args),
                 "Failed to create buffer Y");
    PJRT_Buffer* buffer_y = buffer_y_args.buffer;


  
}
