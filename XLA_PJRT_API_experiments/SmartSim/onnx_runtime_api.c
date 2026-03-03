//
// Created by julius on 2/6/26.
//

#include <stdio.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <onnxruntime_c_api.h>

#define CHECK_HIP(call) \
    do { \
        hipError_t err = call; \
        if (err != hipSuccess) { \
            fprintf(stderr, "HIP error at %s:%d: %s\n", __FILE__, __LINE__, \
                    hipGetErrorString(err)); \
            exit(EXIT_FAILURE); \
        } \
    } while (0)

#define CHECK_ORT(call) \
    do { \
        OrtStatus* status = call; \
        if (status != NULL) { \
            const char* msg = g_ort->GetErrorMessage(status); \
            fprintf(stderr, "ONNX Runtime error: %s\n", msg); \
            g_ort->ReleaseStatus(status); \
            exit(EXIT_FAILURE); \
        } \
    } while (0)

const OrtApi* g_ort = NULL;

void run_simple_add_inference() {
    // Initialize ONNX Runtime API
    g_ort = OrtGetApiBase()->GetApi(ORT_API_VERSION);

    // 1. Create 3 HIP arrays on the GPU
    float* d_input1;
    float* d_input2;
    float* d_output;

    size_t input_size = 10; // Example size
    size_t data_size = input_size * sizeof(float);

    CHECK_HIP(hipMalloc(&d_input1, data_size));
    CHECK_HIP(hipMalloc(&d_input2, data_size));
    CHECK_HIP(hipMalloc(&d_output, data_size));

    // Initialize input data on host and copy to device
    float* h_input1 = (float*)malloc(data_size);
    float* h_input2 = (float*)malloc(data_size);
    for (size_t i = 0; i < input_size; i++) {
        h_input1[i] = (float)i;
        h_input2[i] = (float)(i * 2);
    }

    CHECK_HIP(hipMemcpy(d_input1, h_input1, data_size, hipMemcpyHostToDevice));
    CHECK_HIP(hipMemcpy(d_input2, h_input2, data_size, hipMemcpyHostToDevice));

    // 2. Create ONNX Runtime inference session
    OrtEnv* env;
    CHECK_ORT(g_ort->CreateEnv(ORT_LOGGING_LEVEL_WARNING, "test", &env));

    OrtSessionOptions* session_options;
    CHECK_ORT(g_ort->CreateSessionOptions(&session_options));

    // Enable ROCm/HIP execution provider
    OrtROCMProviderOptions rocm_options;
    rocm_options.device_id = 0;
    CHECK_ORT(g_ort->SessionOptionsAppendExecutionProvider_ROCM(session_options, &rocm_options));

    OrtSession* session;

    // 3. Load the 'simple_add.onnx' model
    const char* model_path = "simple_add.onnx";
    CHECK_ORT(g_ort->CreateSession(env, model_path, session_options, &session));

    // 4. Create IOBinding for ONNX Runtime to use the HIP arrays
    OrtIoBinding* io_binding;
    CHECK_ORT(g_ort->CreateIoBinding(session, &io_binding));

    OrtMemoryInfo* memory_info;
    CHECK_ORT(g_ort->CreateMemoryInfo("Hip", OrtDeviceAllocator, 0, OrtMemTypeDefault, &memory_info));

    // Create input tensors
    int64_t input_shape[] = {input_size};
    size_t input_dims = 1;

    OrtValue* input1_tensor;
    CHECK_ORT(g_ort->CreateTensorWithDataAsOrtValue(
        memory_info, d_input1, data_size, input_shape, input_dims,
        ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT, &input1_tensor));

    OrtValue* input2_tensor;
    CHECK_ORT(g_ort->CreateTensorWithDataAsOrtValue(
        memory_info, d_input2, data_size, input_shape, input_dims,
        ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT, &input2_tensor));

    OrtValue* output_tensor;
    CHECK_ORT(g_ort->CreateTensorWithDataAsOrtValue(
        memory_info, d_output, data_size, input_shape, input_dims,
        ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT, &output_tensor));

    // Bind inputs and outputs
    CHECK_ORT(g_ort->BindInput(io_binding, "input1", input1_tensor));
    CHECK_ORT(g_ort->BindInput(io_binding, "input2", input2_tensor));
    CHECK_ORT(g_ort->BindOutput(io_binding, "output", output_tensor));

    // Run inference
    CHECK_ORT(g_ort->RunWithBinding(session, NULL, io_binding));

    // Synchronize to ensure computation is complete
    CHECK_HIP(hipDeviceSynchronize());

    // 5. Copy the output from ONNX Runtime back to the CPU
    float* h_output = (float*)malloc(data_size);
    CHECK_HIP(hipMemcpy(h_output, d_output, data_size, hipMemcpyDeviceToHost));

    // 6. Print the output
    printf("Output:\n");
    for (size_t i = 0; i < input_size; i++) {
        printf("%.2f + %.2f = %.2f\n", h_input1[i], h_input2[i], h_output[i]);
    }

    // Cleanup ONNX Runtime resources
    g_ort->ReleaseValue(input1_tensor);
    g_ort->ReleaseValue(input2_tensor);
    g_ort->ReleaseValue(output_tensor);
    g_ort->ReleaseMemoryInfo(memory_info);
    g_ort->ReleaseIoBinding(io_binding);
    g_ort->ReleaseSession(session);
    g_ort->ReleaseSessionOptions(session_options);
    g_ort->ReleaseEnv(env);

    // 7. Free the HIP mallocs
    CHECK_HIP(hipFree(d_input1));
    CHECK_HIP(hipFree(d_input2));
    CHECK_HIP(hipFree(d_output));

    // Free host memory
    free(h_input1);
    free(h_input2);
    free(h_output);
}

int main() {
    run_simple_add_inference();
    printf("Inference completed successfully!\n");
    return 0;
}

