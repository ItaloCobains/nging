#include "engine/lua_bindings.h"
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <stdbool.h>
#include <stdio.h>

/**
 * @brief Create a new Lua state.
 * @param renderer The SDL renderer.
 * @return The Lua state or NULL if failed.
 */
lua_State *lua_engine_create(struct SDL_Renderer *renderer) {
  lua_State *L = luaL_newstate();
  if (!L) {
    fprintf(stderr, "Failed to create Lua state\n");
    return NULL;
  }
  luaL_openlibs(L);
  engine_lua_register_bindings(L, renderer);
  return L;
}

/**
 * @brief Destroy the Lua state.
 * @param L The Lua state.
 */
void lua_engine_destroy(lua_State *L) {
  if (L)
    lua_close(L);
}

/**
 * @brief Run a Lua script.
 * @param L The Lua state.
 * @param path The path to the Lua script.
 * @return True if successful, false otherwise.
 */
bool lua_engine_run_script(lua_State *L, const char *path) {
  if (luaL_dofile(L, path) != LUA_OK) {
    fprintf(stderr, "Lua error: %s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
    return false;
  }

  return true;
}

/**
 * @brief Call the update function.
 * @param L The Lua state.
 * @param delta The delta time.
 */
void lua_engine_call_update(lua_State *L, double delta) {
  lua_getglobal(L, "engine");

  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    return;
  }

  lua_getfield(L, -1, "update");
  lua_remove(L, -2);

  if (!lua_isfunction(L, -1)) {
    lua_pop(L, 1);
    return;
  }

  lua_pushnumber(L, delta);

  if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
    fprintf(stderr, "Lua update error: %s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
  }
}

/**
 * @brief Call the draw function.
 * @param L The Lua state.
 */
void lua_engine_call_draw(lua_State *L) {
  lua_getglobal(L, "engine");

  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    return;
  }

  lua_getfield(L, -1, "draw");
  lua_remove(L, -2);

  if (!lua_isfunction(L, -1)) {
    lua_pop(L, 1);
    return;
  }
  if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
    fprintf(stderr, "Lua draw error: %s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
  }
}
