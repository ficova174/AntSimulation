#[compute]
#version 450

layout(push_constant, std430) uniform Params {
    float time_elapsed;
} params;

struct Ant {
    vec2 position;
    float angle;
    float _pad; // bc struct must have offset multiple of its biggest element (vec2)
};

layout(std430, set = 0, binding = 0) buffer Ants {
    Ant ants[];
};

layout(rgba8, set = 0, binding = 1) uniform restrict image2D pheromones;

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

void main() {
    return;
}
