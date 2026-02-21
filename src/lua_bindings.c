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

static int l_engine_is_key_down(lua_State *L) {
  int scancode = (int)luaL_checkinteger(L, 1);
  const Uint8 *state = SDL_GetKeyboardState(NULL);
  lua_pushboolean(L, state[scancode]);
  return 1;
}

static int l_engine_get_mouse_pos(lua_State *L) {
  int x, y;
  SDL_GetMouseState(&x, &y);
  lua_pushinteger(L, x);
  lua_pushinteger(L, y);
  return 2;
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
  lua_pushcfunction(L, l_engine_is_key_down);
  lua_setfield(L, -2, "is_key_down");
  lua_pushcfunction(L, l_engine_get_mouse_pos);
  lua_setfield(L, -2, "get_mouse_pos");

  lua_newtable(L);
  lua_pushinteger(L, SDL_SCANCODE_W);
  lua_setfield(L, -2, "W");
  lua_pushinteger(L, SDL_SCANCODE_A);
  lua_setfield(L, -2, "A");
  lua_pushinteger(L, SDL_SCANCODE_S);
  lua_setfield(L, -2, "S");
  lua_pushinteger(L, SDL_SCANCODE_D);
  lua_setfield(L, -2, "D");
  lua_pushinteger(L, SDL_SCANCODE_UP);
  lua_setfield(L, -2, "UP");
  lua_pushinteger(L, SDL_SCANCODE_DOWN);
  lua_setfield(L, -2, "DOWN");
  lua_pushinteger(L, SDL_SCANCODE_LEFT);
  lua_setfield(L, -2, "LEFT");
  lua_pushinteger(L, SDL_SCANCODE_RIGHT);
  lua_setfield(L, -2, "RIGHT");
  lua_pushinteger(L, SDL_SCANCODE_SPACE);
  lua_setfield(L, -2, "SPACE");
  lua_setfield(L, -2, "keys");

  lua_setglobal(L, "engine");
}
