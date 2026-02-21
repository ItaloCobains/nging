#include "engine/core.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  (void)argc;
  (void)argv;

  Engine *e = engine_create();
  if (!e) {
    return EXIT_FAILURE;
  }

  engine_run(e);
  engine_destroy(e);

  return EXIT_SUCCESS;
}
