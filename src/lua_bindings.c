#include "engine/lua_bindings.h"
#include <SDL2/SDL.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <stdio.h>

static SDL_Renderer *s_renderer;

static int l_engine_log(lua_State *L) {
  const char *msg = luaL_checkstring(L, 1);
  printf("[lua] %s\n", msg);
  return 0;
}

static int l_engine_clear(lua_State *L) {
  (void)L;
  Uint8 r = (Uint8)luaL_checkinteger(L, 1);
  Uint8 g = (Uint8)luaL_checkinteger(L, 2);
  Uint8 b = (Uint8)luaL_checkinteger(L, 3);
  Uint8 a = (Uint8)luaL_optinteger(L, 4, 255);
  SDL_SetRenderDrawColor(s_renderer, r, g, b, a);
  SDL_RenderClear(s_renderer);
  return 0;
}

static int l_engine_set_draw_color(lua_State *L) {
  Uint8 r = (Uint8)luaL_checkinteger(L, 1);
  Uint8 g = (Uint8)luaL_checkinteger(L, 2);
  Uint8 b = (Uint8)luaL_checkinteger(L, 3);
  Uint8 a = (Uint8)luaL_optinteger(L, 4, 255);
  SDL_SetRenderDrawColor(s_renderer, r, g, b, a);
  return 0;
}

static int l_engine_draw_rect(lua_State *L) {
  int x = (int)luaL_checkinteger(L, 1);
  int y = (int)luaL_checkinteger(L, 2);
  int w = (int)luaL_checkinteger(L, 3);
  int h = (int)luaL_checkinteger(L, 4);
  SDL_Rect rect = {x, y, w, h};
  SDL_RenderFillRect(s_renderer, &rect);
  return 0;
}

void engine_lua_register_bindings(lua_State *L, struct SDL_Renderer *renderer) {
  s_renderer = renderer;

  lua_newtable(L);
  lua_pushcfunction(L, l_engine_log);
  lua_setfield(L, -2, "log");
  lua_pushcfunction(L, l_engine_clear);
  lua_setfield(L, -2, "clear");
  lua_pushcfunction(L, l_engine_set_draw_color);
  lua_setfield(L, -2, "set_draw_color");
  lua_pushcfunction(L, l_engine_draw_rect);
  lua_setfield(L, -2, "draw_rect");
  lua_setglobal(L, "engine");
}
