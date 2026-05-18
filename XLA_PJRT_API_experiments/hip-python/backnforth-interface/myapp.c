#include <stdio.h>
#include <dlfcn.h>
#include "pyembed.h"

static void *load_sym(void *handle, const char *name) {
    void *sym = dlsym(handle, name);
    if (sym == NULL) {
        fprintf(stderr, "Failed to find '%s' function\n", name);
        dlclose(handle);
    }
    return sym;
}

int main(int argc, char *argv)
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

  int (*hipInit)(hipStream_t *, hipblasHandle_t *) = load_sym(py, "hipInit");
  if (hipInit == NULL) return -1;
  
  Alloc *(*hidden_alloc)(void) = load_sym(py, "hidden_alloc");
  if (hidden_alloc == NULL) return -1;
  
  void (*my_hipblasSaxpy)(hipblasHandle_t, int, const float*, float*, float*) = load_sym(py, "my_hipblasSaxpy");
  if (my_hipblasSaxpy == NULL) return -1;

  hipStream_t *stream;
  hipblasHandle_t *handle;
  int ret = hipInit(stream, handle);
  if (ret == -1) {
    fprintf(stderr, "Hip initialization failed\n");
    return -1;
  };
  
  Alloc *hal = hidden_alloc();

  
  printf("Length of hidden array: %d\n", hal->n);
  printf("Length of alpha: %d\n", hal->alpha_len);
  const float *alpha = (const float *)hal->alpha;
  
  printf("Length of alpha: %f\n", alpha[0]);

  my_hipblasSaxpy(handle, hal->n, alpha, hal->x_d, hal->y_d);
    
  dlclose(py);
  return 0;
}


