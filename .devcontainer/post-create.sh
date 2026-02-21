#!/usr/bin/env bash
set -e

echo "==> Setting up nging build environment..."

# Remove old build if corrupted
rm -rf build

# Create build directory and configure with CMake
mkdir -p build
cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_COMPILER=gcc

# Symlink compile_commands.json to root for clangd/IntelliSense
ln -sf build/compile_commands.json compile_commands.json 2>/dev/null || true

echo "==> ✓ Build environment ready"
echo "==> To compile: cmake --build build"
echo "==> To compile with verbose: cmake --build build -- VERBOSE=1"
