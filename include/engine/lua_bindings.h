#ifndef ENGINE_LUA_BINDINGS_H
#define ENGINE_LUA_BINDINGS_H

#include <lua.h>

struct SDL_Renderer;

void engine_lua_register_bindings(lua_State *L, struct SDL_Renderer *renderer);

#endif
