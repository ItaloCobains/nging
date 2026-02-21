cmake_minimum_required(VERSION 3.20)
project(nging VERSION 0.1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Symlink compile_commands.json to project root for clangd (Go to Definition)
if(CMAKE_EXPORT_COMPILE_COMMANDS)
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E create_symlink
            ${CMAKE_BINARY_DIR}/compile_commands.json
            ${CMAKE_SOURCE_DIR}/compile_commands.json
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  )
endif()

# -- Dependencies via pkg-config --

find_package(PkgConfig REQUIRED)

pkg_check_modules(SDL2       REQUIRED sdl2)
pkg_check_modules(SDL2_IMAGE REQUIRED SDL2_image)
pkg_check_modules(SDL2_TTF   REQUIRED SDL2_ttf)
pkg_check_modules(SDL2_MIXER REQUIRED SDL2_mixer)
pkg_check_modules(LUA        REQUIRED lua5.4)

# -- Source files --

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS src/*.c)

add_executable(nging ${SOURCES})

# -- Include paths --

target_include_directories(nging PRIVATE
    include
    ${SDL2_INCLUDE_DIRS}
    ${SDL2_IMAGE_INCLUDE_DIRS}
    ${SDL2_TTF_INCLUDE_DIRS}
    ${SDL2_MIXER_INCLUDE_DIRS}
    ${LUA_INCLUDE_DIRS}
)

# -- Link directories (so linker finds libs, e.g. on macOS Homebrew) --

target_link_directories(nging PRIVATE
    ${SDL2_LIBRARY_DIRS}
    ${SDL2_IMAGE_LIBRARY_DIRS}
    ${SDL2_TTF_LIBRARY_DIRS}
    ${SDL2_MIXER_LIBRARY_DIRS}
    ${LUA_LIBRARY_DIRS}
)

# -- Link libraries --

target_link_libraries(nging PRIVATE
    ${SDL2_LIBRARIES}
    ${SDL2_IMAGE_LIBRARIES}
    ${SDL2_TTF_LIBRARIES}
    ${SDL2_MIXER_LIBRARIES}
    ${LUA_LIBRARIES}
    m   # math
)

# -- Compiler flags --

target_compile_options(nging PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Wno-unused-parameter
    $<$<CONFIG:Debug>:-g3 -O0 -fsanitize=address,undefined>
    $<$<CONFIG:Release>:-O2>
)

target_link_options(nging PRIVATE
    $<$<CONFIG:Debug>:-fsanitize=address,undefined>
)

# -- Copy Lua scripts to build dir after build --

add_custom_command(TARGET nging POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/lua
        $<TARGET_FILE_DIR:nging>/lua
    COMMENT "Copying Lua scripts to build directory"
)
