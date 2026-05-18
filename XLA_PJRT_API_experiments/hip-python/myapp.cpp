#include <stdio.h>
#include <dlfcn.h>
#include "pyembed.h"
#include <hip/hip_runtime.h>

#define CHECK_HIP(cmd) \
    do { \
        hipError_t err = (cmd); \
        if (err != hipSuccess) { \
            fprintf(stderr, "HIP error: %s at %s:%d\n", \
                    hipGetErrorString(err), __FILE__, __LINE__); \
            return 1; \
        } \
    } while (0)

static void *load_sym(void *handle, const char *name) {
    void *sym = dlsym(handle, name);
    if (sym == NULL) {
        fprintf(stderr, "Failed to find '%s' function\n", name);
        dlclose(handle);
    }
    return sym;
}

int main(int argc, char **argv)
{
  void *libpython = dlopen("libpython3.12.so", RTLD_LAZY|RTLD_GLOBAL);
  if (!libpython) {
    fprintf(stderr, "Failed to libpython\n");
    return -1;
  }
  
  void *py = dlopen("./libpyembed.so", RTLD_NOW | RTLD_LOCAL);
  if (py == NULL) {
    fprintf(stderr, "Failed to load library\n");
    return -1;
  }

  int (*run)(float *, float *, float *, const size_t) = (int (*)(float *, float *, float *, const size_t))load_sym(py, "run");
  if (run == NULL) return -1;

  const size_t N = 1024;
  const size_t size = N * sizeof(float);
  
  // Initialize host arrays with ones
  float *h_a = new float[N];
  float *h_b = new float[N];
  float *h_c = new float[1];
  
  for (size_t i = 0; i < N; i++) {
    h_a[i] = 1.0f;
    h_b[i] = 1.0f;
  }
  h_c[0] = 2.0f;

  float *d_a = nullptr;
  float *d_b = nullptr;
  float *d_c = nullptr;
  
  CHECK_HIP(hipMalloc(&d_a, size));
  CHECK_HIP(hipMalloc(&d_b, size));
  CHECK_HIP(hipMalloc(&d_c, sizeof(float)));

  // Copy ones from host to device
  CHECK_HIP(hipMemcpy(d_a, h_a, size, hipMemcpyHostToDevice));
  CHECK_HIP(hipMemcpy(d_b, h_b, size, hipMemcpyHostToDevice));
  CHECK_HIP(hipMemcpy(d_c, h_c, sizeof(float), hipMemcpyHostToDevice));

  int ret = run(d_a, d_b, h_c, N);
  fprintf(stdout, "Return code: %i\n", ret);

  CHECK_HIP(hipFree(d_a));
  CHECK_HIP(hipFree(d_b));
  CHECK_HIP(hipFree(d_c));
  
  dlclose(py);
  dlclose(libpython);
  return 0;
}


