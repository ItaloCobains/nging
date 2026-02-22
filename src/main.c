#include "engine/core.h"
#include <stdio.h>
#include <stdlib.h>

/**
 * @brief Main function.
 * @param argc The number of arguments.
 * @param argv The arguments.
 * @return EXIT_SUCCESS if successful, EXIT_FAILURE otherwise.
 */
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
