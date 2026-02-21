FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Core build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    clang \
    clang-format \
    clang-tidy \
    cmake \
    make \
    ninja-build \
    pkg-config \
    git \
    curl \
    wget \
    unzip \
    gdb \
    valgrind \
    # Lua 5.4
    lua5.4 \
    liblua5.4-dev \
    luarocks \
    # SDL2 and extensions
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev \
    libsdl2-net-dev \
    # OpenGL / GLEW / GLFW
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libglew-dev \
    libglfw3-dev \
    # Audio
    libopenal-dev \
    # Compression
    zlib1g-dev \
    # Image loading (stb alternative with system libs)
    libpng-dev \
    libjpeg-dev \
    # Python (for build scripts)
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install LuaRocks packages commonly used in game engines
RUN luarocks install luasocket 2>/dev/null || true \
    && luarocks install inspect 2>/dev/null || true

# Set up pkg-config for Lua 5.4 (some tools look for 'lua' not 'lua5.4')
RUN ln -sf /usr/bin/lua5.4 /usr/local/bin/lua \
    && ln -sf /usr/bin/luac5.4 /usr/local/bin/luac

WORKDIR /workspace

# Copy project files into container
COPY . .

# Fix permissions for vscode user
RUN chown -R vscode:vscode /workspace
