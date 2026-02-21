#ifndef ENGINE_CORE_H
#define ENGINE_CORE_H

#include <stdbool.h>

typedef struct Engine Engine;

Engine *engine_create(void);
void engine_destroy(Engine *engine);
bool engine_run(Engine *engine);

#endif
