#include "engine/time.h"
#include <SDL2/SDL.h>

static Uint64 g_freq;
static Uint64 g_last;

/**
 * @brief Initialize the time.
 */
void engine_time_init(void) {
  g_freq = SDL_GetPerformanceFrequency();
  g_last = SDL_GetPerformanceCounter();
}

/**
 * @brief Tick the time.
 */
void engine_time_tick(void) { g_last = SDL_GetPerformanceCounter(); }

/**
 * @brief Get the delta time between the last tick and the current tick.
 * @return The delta time in seconds.
 */
double engine_time_delta(void) {
  Uint64 now = SDL_GetPerformanceCounter();
  double delta = (double)(now - g_last) / (double)g_freq;
  g_last = now;
  return delta;
}
