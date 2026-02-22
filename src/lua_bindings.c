#include "engine/lua_bindings.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_ttf.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static SDL_Renderer *s_renderer;
static TTF_Font *s_font = NULL;

static Mix_Chunk *s_sounds[6] = {0};

/**
 * @brief Generate a sine wave.
 * @param freq The frequency.
 * @param duration_ms The duration in milliseconds.
 * @param amplitude The amplitude.
 * @return The Mix_Chunk.
 */
static Mix_Chunk *generate_sine_wave(int freq, int duration_ms, int amplitude) {
  int sample_rate = 44100;
  int num_samples = (sample_rate * duration_ms) / 1000;
  int16_t *samples = (int16_t *)malloc(num_samples * sizeof(int16_t));

  double phase_increment = 2.0 * 3.14159265359 * freq / sample_rate;
  double phase = 0.0;
  double decay_factor = 1.0;
  double decay_per_sample = pow(0.01, 1.0 / num_samples);

  for (int i = 0; i < num_samples; i++) {
    int16_t sample = (int16_t)(sin(phase) * amplitude * decay_factor);
    samples[i] = sample;
    phase += phase_increment;
    decay_factor *= decay_per_sample;
  }

  Mix_Chunk *chunk = (Mix_Chunk *)malloc(sizeof(Mix_Chunk));
  chunk->allocated = 1;
  chunk->abuf = (Uint8 *)samples;
  chunk->alen = num_samples * sizeof(int16_t);
  chunk->volume = MIX_MAX_VOLUME;

  return chunk;
}

/**
 * @brief Generate a white noise.
 * @param duration_ms The duration in milliseconds.
 * @param amplitude The amplitude.
 * @return The Mix_Chunk.
 */
static Mix_Chunk *generate_white_noise(int duration_ms, int amplitude) {
  int sample_rate = 44100;
  int num_samples = (sample_rate * duration_ms) / 1000;
  int16_t *samples = (int16_t *)malloc(num_samples * sizeof(int16_t));

  double decay_factor = 1.0;
  double decay_per_sample = pow(0.01, 1.0 / num_samples);

  for (int i = 0; i < num_samples; i++) {
    int16_t sample =
        (int16_t)((rand() % (2 * amplitude)) - amplitude) * decay_factor;
    samples[i] = sample;
    decay_factor *= decay_per_sample;
  }

  Mix_Chunk *chunk = (Mix_Chunk *)malloc(sizeof(Mix_Chunk));
  chunk->allocated = 1;
  chunk->abuf = (Uint8 *)samples;
  chunk->alen = num_samples * sizeof(int16_t);
  chunk->volume = MIX_MAX_VOLUME;

  return chunk;
}

/**
 * @brief Log a message.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_log(lua_State *L) {
  const char *msg = luaL_checkstring(L, 1);
  printf("[lua] %s\n", msg);
  return 0;
}

/**
 * @brief Clear the screen.
 * @param L The Lua state.
 * @return 0.
 */
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

/**
 * @brief Set the draw color.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_set_draw_color(lua_State *L) {
  Uint8 r = (Uint8)luaL_checkinteger(L, 1);
  Uint8 g = (Uint8)luaL_checkinteger(L, 2);
  Uint8 b = (Uint8)luaL_checkinteger(L, 3);
  Uint8 a = (Uint8)luaL_optinteger(L, 4, 255);
  SDL_SetRenderDrawColor(s_renderer, r, g, b, a);
  return 0;
}

/**
 * @brief Draw a rectangle.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_draw_rect(lua_State *L) {
  int x = (int)luaL_checkinteger(L, 1);
  int y = (int)luaL_checkinteger(L, 2);
  int w = (int)luaL_checkinteger(L, 3);
  int h = (int)luaL_checkinteger(L, 4);
  SDL_Rect rect = {x, y, w, h};
  SDL_RenderFillRect(s_renderer, &rect);
  return 0;
}

/**
 * @brief Check if a key is down.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_is_key_down(lua_State *L) {
  int scancode = (int)luaL_checkinteger(L, 1);
  const Uint8 *state = SDL_GetKeyboardState(NULL);
  lua_pushboolean(L, state[scancode]);
  return 1;
}

/**
 * @brief Get the mouse position.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_get_mouse_pos(lua_State *L) {
  int x, y;
  SDL_GetMouseState(&x, &y);
  lua_pushinteger(L, x);
  lua_pushinteger(L, y);
  return 2;
}

/**
 * @brief Set the font.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_set_font(lua_State *L) {
  const char *path = luaL_checkstring(L, 1);
  int size = (int)luaL_checkinteger(L, 2);

  if (s_font != NULL) {
    TTF_CloseFont(s_font);
    s_font = NULL;
  }

  s_font = TTF_OpenFont(path, size);
  if (s_font == NULL) {
    return luaL_error(L, "TTF_OpenFont error: %s", TTF_GetError());
  }

  return 0;
}

/**
 * @brief Draw text.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_draw_text(lua_State *L) {
  const char *text = luaL_checkstring(L, 1);
  int x = (int)luaL_checkinteger(L, 2);
  int y = (int)luaL_checkinteger(L, 3);

  if (s_font == NULL) {
    return luaL_error(L, "Font not loaded. Call engine.set_font() first.");
  }

  Uint8 r, g, b, a;
  SDL_GetRenderDrawColor(s_renderer, &r, &g, &b, &a);

  SDL_Color color = {r, g, b, a};
  SDL_Surface *surface = TTF_RenderUTF8_Blended(s_font, text, color);
  if (surface == NULL) {
    return luaL_error(L, "TTF_RenderUTF8_Blended error: %s", TTF_GetError());
  }

  SDL_Texture *texture = SDL_CreateTextureFromSurface(s_renderer, surface);
  if (texture == NULL) {
    SDL_FreeSurface(surface);
    return luaL_error(L, "SDL_CreateTextureFromSurface error: %s",
                      SDL_GetError());
  }

  int width, height;
  SDL_QueryTexture(texture, NULL, NULL, &width, &height);

  SDL_Rect dst = {x, y, width, height};
  SDL_RenderCopy(s_renderer, texture, NULL, &dst);

  SDL_DestroyTexture(texture);
  SDL_FreeSurface(surface);

  return 0;
}

/**
 * @brief Draw a rectangle outline.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_draw_rect_outline(lua_State *L) {
  int x = (int)luaL_checkinteger(L, 1);
  int y = (int)luaL_checkinteger(L, 2);
  int w = (int)luaL_checkinteger(L, 3);
  int h = (int)luaL_checkinteger(L, 4);
  SDL_Rect rect = {x, y, w, h};
  SDL_RenderDrawRect(s_renderer, &rect);
  return 0;
}

/**
 * @brief Play a sound.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_play_sound(lua_State *L) {
  const char *name = luaL_checkstring(L, 1);
  int sound_idx = -1;

  if (strcmp(name, "shoot") == 0)
    sound_idx = 0;
  else if (strcmp(name, "hit") == 0)
    sound_idx = 1;
  else if (strcmp(name, "explosion") == 0)
    sound_idx = 2;
  else if (strcmp(name, "pickup") == 0)
    sound_idx = 3;
  else if (strcmp(name, "damage") == 0)
    sound_idx = 4;
  else if (strcmp(name, "wave") == 0)
    sound_idx = 5;

  if (sound_idx >= 0 && sound_idx < 6 && s_sounds[sound_idx]) {
    Mix_PlayChannel(-1, s_sounds[sound_idx], 0);
  }

  return 0;
}

/**
 * @brief Set the SFX volume.
 * @param L The Lua state.
 * @return 0.
 */
static int l_engine_set_sfx_volume(lua_State *L) {
  double v = luaL_checknumber(L, 1);
  int vol = (int)(v * 128);
  if (vol < 0)
    vol = 0;
  if (vol > 128)
    vol = 128;
  Mix_Volume(-1, vol);
  return 0;
}

/**
 * @brief Register the Lua bindings.
 * @param L The Lua state.
 * @param renderer The SDL renderer.
 */
void engine_lua_register_bindings(lua_State *L, struct SDL_Renderer *renderer) {
  s_renderer = renderer;

  SDL_SetRenderDrawBlendMode(s_renderer, SDL_BLENDMODE_BLEND);
  if (TTF_Init() == -1) {
    fprintf(stderr, "TTF_Init error: %s\n", TTF_GetError());
  }

  s_sounds[0] = generate_sine_wave(880, 50, 20000);
  s_sounds[1] = generate_sine_wave(440, 50, 20000);
  s_sounds[2] = generate_white_noise(120, 20000);
  s_sounds[3] = generate_sine_wave(440, 80, 20000);
  s_sounds[4] = generate_sine_wave(220, 80, 20000);
  s_sounds[5] = generate_sine_wave(440, 200, 20000);

  lua_newtable(L);
  lua_pushcfunction(L, l_engine_log);
  lua_setfield(L, -2, "log");
  lua_pushcfunction(L, l_engine_clear);
  lua_setfield(L, -2, "clear");
  lua_pushcfunction(L, l_engine_set_draw_color);
  lua_setfield(L, -2, "set_draw_color");
  lua_pushcfunction(L, l_engine_draw_rect);
  lua_setfield(L, -2, "draw_rect");
  lua_pushcfunction(L, l_engine_draw_rect_outline);
  lua_setfield(L, -2, "draw_rect_outline");
  lua_pushcfunction(L, l_engine_set_font);
  lua_setfield(L, -2, "set_font");
  lua_pushcfunction(L, l_engine_draw_text);
  lua_setfield(L, -2, "draw_text");
  lua_pushcfunction(L, l_engine_is_key_down);
  lua_setfield(L, -2, "is_key_down");
  lua_pushcfunction(L, l_engine_get_mouse_pos);
  lua_setfield(L, -2, "get_mouse_pos");
  lua_pushcfunction(L, l_engine_play_sound);
  lua_setfield(L, -2, "play_sound");
  lua_pushcfunction(L, l_engine_set_sfx_volume);
  lua_setfield(L, -2, "set_sfx_volume");

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
  lua_pushinteger(L, SDL_SCANCODE_ESCAPE);
  lua_setfield(L, -2, "ESCAPE");
  lua_pushinteger(L, SDL_SCANCODE_F);
  lua_setfield(L, -2, "F");
  lua_setfield(L, -2, "keys");

  lua_setglobal(L, "engine");
}
