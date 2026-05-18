/* file plugin.h */
#include <stdint.h>

/* Opaque handle types matching HIP/hipBLAS */
typedef void* hipStream_t;
typedef void* hipblasHandle_t;

/*
 * hipInit()
 * Initializes the HIP device, creates a stream and a hipBLAS handle,
 * binds the handle to the stream, and returns both.
 *
 * Returns 0 on success, non-zero on failure.
 * Out-params are set only on success.
 */
 extern int hipInit(hipStream_t *stream_out, hipblasHandle_t *handle_out);

typedef struct {
  void* x_d;
  void* y_d;
  float* alpha;
  int alpha_len;
  int n;
} Alloc;

extern Alloc* hidden_alloc(void);

/* hipPointer: wraps a raw device pointer with 2D shape metadata.
 * ptr   - raw device pointer (integer address)
 * shape - (rows, cols) dimensions of the array
 * Returns a void* representing the configured DeviceArray
 */
// extern void* hipPointer(uint64_t ptr, Shape2D shape);

/* my_hipblasSaxpy: performs SAXPY (y = alpha*x + y) on device arrays.
 * handle - hipBLAS library handle
 * n      - number of elements
 * alpha  - scalar multiplier (pointer to float)
 * x_d    - device pointer to input vector x
 * y_d    - device pointer to input/output vector y
 * Returns the updated y_d device pointer
 */
extern void* my_hipblasSaxpy(
    hipblasHandle_t handle,
    int             n,
    const float*    alpha,
    float*          x_d,
    float*          y_d
);

