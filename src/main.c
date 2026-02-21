#include <stdio.h>
#include <stdlib.h>
#include <SDL2/SDL.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

/* Forward declarations */
static lua_State *engine_lua_init(void);
static void       engine_lua_close(lua_State *L);
static int        engine_lua_run_script(lua_State *L, const char *path);

/* Lua binding: engine.log(msg) */
static int l_engine_log(lua_State *L) {
    const char *msg = luaL_checkstring(L, 1);
    printf("[lua] %s\n", msg);
    return 0;
}

/* Register engine bindings into a "engine" table visible from Lua */
static void engine_lua_register_bindings(lua_State *L) {
    lua_newtable(L);

    lua_pushcfunction(L, l_engine_log);
    lua_setfield(L, -2, "log");

    lua_setglobal(L, "engine");
}

static lua_State *engine_lua_init(void) {
    lua_State *L = luaL_newstate();
    if (!L) {
        fprintf(stderr, "Failed to create Lua state\n");
        return NULL;
    }
    luaL_openlibs(L);
    engine_lua_register_bindings(L);
    return L;
}

static int engine_lua_run_script(lua_State *L, const char *path) {
    if (luaL_dofile(L, path) != LUA_OK) {
        fprintf(stderr, "Lua error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 1);
        return -1;
    }
    return 0;
}

static void engine_lua_close(lua_State *L) {
    if (L) lua_close(L);
}

int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;

    /* SDL init */
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) {
        fprintf(stderr, "SDL_Init error: %s\n", SDL_GetError());
        return EXIT_FAILURE;
    }

    SDL_Window *window = SDL_CreateWindow(
        "nging",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        800, 600,
        SDL_WINDOW_SHOWN
    );
    if (!window) {
        fprintf(stderr, "SDL_CreateWindow error: %s\n", SDL_GetError());
        SDL_Quit();
        return EXIT_FAILURE;
    }

    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        fprintf(stderr, "SDL_CreateRenderer error: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }

    /* Lua init and boot script */
    lua_State *L = engine_lua_init();
    if (!L) {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }

    engine_lua_run_script(L, "lua/scripts/main.lua");

    /* Main loop */
    int running = 1;
    SDL_Event event;

    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) running = 0;
            if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE) running = 0;
        }

        SDL_SetRenderDrawColor(renderer, 30, 30, 30, 255);
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);
    }

    engine_lua_close(L);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return EXIT_SUCCESS;
}
