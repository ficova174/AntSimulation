cmake_minimum_required(VERSION 3.16)
project(AntSimulation LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(SDL3 REQUIRED)
find_package(SDL3_image REQUIRED)

add_compile_options(-Wall -Wextra -Werror -pedantic -Wshadow -O0 -g)

set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/thirdParty/imgui)

add_executable(AntSimulation
    src/main.cpp
    src/game.cpp
    src/map.cpp
    src/viewport.cpp
    src/nest.cpp
    src/ant.cpp

    # Dear ImGui core
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/imgui_demo.cpp

    # Backends
    ${IMGUI_DIR}/backends/imgui_impl_sdl3.cpp
    ${IMGUI_DIR}/backends/imgui_impl_sdlrenderer3.cpp
)

target_include_directories(AntSimulation PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
)

target_link_libraries(AntSimulation PRIVATE
    SDL3::SDL3
    SDL3_image::SDL3_image
)
