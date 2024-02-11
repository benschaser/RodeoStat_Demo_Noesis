cmake_minimum_required(VERSION 3.20)
project(rodeostat-testing)

# produces compile_commands.json: useful for IDE's
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# project wide compilation settings
add_compile_options(-std=c++17 -ggdb -O3)

# divide project into src and testing folders
add_subdirectory(src)
add_subdirectory(test)