#include "engine/core.h"
#include "engine/lua_bindings.h"
#include "engine/time.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <lua.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

/**
 * @brief Engine structure.
 */
struct Engine {
  SDL_Window *window;
  SDL_Renderer *renderer;
  lua_State *L;
  bool running;
};

extern lua_State *lua_engine_create(struct SDL_Renderer *renderer);
extern void lua_engine_destroy(lua_State *L);
extern int lua_engine_run_script(lua_State *L, const char *path);
extern void lua_engine_call_update(lua_State *L, double dt);
extern void lua_engine_call_draw(lua_State *L);

/**
 * @brief Create a new engine.
 * @return The engine or NULL if failed.
 */
Engine *engine_create(void) {
  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS | SDL_INIT_AUDIO) != 0) {
    fprintf(stderr, "SDL_Init error: %s\n", SDL_GetError());
    return NULL;
  }

  if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 512) != 0) {
    fprintf(stderr, "Mix_OpenAudio error: %s\n", Mix_GetError());
    SDL_Quit();
    return NULL;
  }

  SDL_Window *window =
      SDL_CreateWindow("nging", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                       800, 600, SDL_WINDOW_SHOWN);

  if (!window) {
    fprintf(stderr, "SDL_CreateWindow error: %s\n", SDL_GetError());
    SDL_Quit();
    return NULL;
  }

  SDL_Renderer *renderer =
      SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
  if (!renderer) {
    fprintf(stderr, "SDL_CreateRenderer error: %s\n", SDL_GetError());
    SDL_DestroyWindow(window);
    SDL_Quit();
    return NULL;
  }

  lua_State *L = lua_engine_create(renderer);
  if (!L) {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return NULL;
  }

  if (!lua_engine_run_script(L, "lua/scripts/main.lua")) {
    lua_engine_destroy(L);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return NULL;
  }

  Engine *e = (Engine *)malloc(sizeof(Engine));
  if (!e) {
    lua_engine_destroy(L);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return NULL;
  }

  e->window = window;
  e->renderer = renderer;
  e->L = L;
  e->running = true;

  engine_time_init();
  return e;
}

/**
 * @brief Destroy the engine.
 * @param e The engine.
 */
void engine_destroy(Engine *e) {
  if (!e)
    return;
  lua_engine_destroy(e->L);
  SDL_DestroyRenderer(e->renderer);
  SDL_DestroyWindow(e->window);
  free(e);
  Mix_CloseAudio();
  Mix_Quit();
  SDL_Quit();
}

/**
 * @brief Run the engine.
 * @param e The engine.
 * @return True if successful, false otherwise.
 */
bool engine_run(Engine *e) {
  SDL_Event event;

  while (e->running) {
    while (SDL_PollEvent(&event)) {
      if (event.type == SDL_QUIT)
        e->running = false;
    }

    double delta = engine_time_delta();
    lua_engine_call_update(e->L, delta);

    lua_engine_call_draw(e->L);
    SDL_RenderPresent(e->renderer);
  }

  return true;
}
