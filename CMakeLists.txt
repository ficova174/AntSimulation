cmake_minimum_required(VERSION 3.16)
project(AntSimulation LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_options(-Wall -Wextra -Werror -pedantic -Wshadow -O0 -g)

# Add the include directory for header files
include_directories(include)

set(SOURCES src/main.cpp src/game.cpp src/map.cpp src/viewport.cpp src/ant.cpp)

find_package(SDL3 REQUIRED)
find_package(SDL3_image REQUIRED)

add_executable(AntSimulation ${SOURCES})

target_link_libraries(AntSimulation PRIVATE SDL3::SDL3 SDL3_image::SDL3_image)
