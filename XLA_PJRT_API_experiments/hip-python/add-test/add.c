#include <stdio.h>
#include <dlfcn.h>
#include "add.h"

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

  
  void *py = dlopen("./libadd.so", RTLD_NOW | RTLD_LOCAL);
  if (py == NULL) {
    fprintf(stderr, "Failed to load library\n");
    return -1;
  }
	
  vec *(*adddiff)(int, int) = load_sym(py, "adddiff");
  if (adddiff == NULL) return -1;

  int (*add)(int, int) = load_sym(py, "add");
  if (add == NULL) return -1;

  cnt *(*get_container)(void) = load_sym(py, "get_container");
  if (get_container == NULL) return -1;
 
  vec *c = adddiff(10, 15);

  printf("result add: %d\n", c->u);
  printf("result diff: %d\n", c->v);

  int c2 = add(3, 5);
  printf("result add-2: %d\n", c2);

  cnt *container = get_container();
  printf("Container items: %d\n", container->vec->u);
  printf("Container items: %d\n", container->vec->v);
  
  dlclose(py);
  return 0;
}


