# nging — Engine 2D (C + Lua)

Engine de jogos 2D em C com scripting em Lua (SDL2, Lua 5.4).

## macOS — Primeira vez

### 1. Dependências (Homebrew)

```bash
brew install sdl2 sdl2_image sdl2_ttf sdl2_mixer lua@5.4 pkg-config cmake
```

Para o `pkg-config` encontrar o Lua 5.4:

```bash
brew link --force lua@5.4
```

(Se der conflito, use no `CMakeLists.txt` o módulo `lua-5.4` ou ajuste `PKG_CONFIG_PATH`.)

### 2. Build e compile_commands.json (clangd)

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
```

O CMake cria um symlink `compile_commands.json` na raiz do projeto para o clangd (Go to Definition nas libs).

### 3. VS Code / Cursor

- **Extensão:** instale **clangd** (`llvm-vs-code-extensions.vscode-clangd`). O IntelliSense da extensão C/C++ fica desabilitado para não conflitar.
- **Go to Definition:** funciona no seu código e nos headers de SDL2/Lua depois do configure + symlink.
- **Debug:** use a configuração **"C Debug (macOS LLDB)"** no launch. O `preLaunchTask` faz o build antes de rodar.

## Estrutura

- `src/` — C (engine, bindings Lua, SDL2)
- `lua/` — scripts Lua (ex.: `lua/scripts/main.lua`)
- `include/` — headers do projeto (se houver)

## Build rápido

```bash
cmake --build build
./build/nging
```

Ou no VS Code: **Run and Debug** → **C Debug (macOS LLDB)**.
