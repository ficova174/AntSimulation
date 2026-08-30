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

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

void main() {
    uint id = gl_GlobalInvocationID.x;
    float speed = 100.0;
    float rotation_speed = 10.0;

    vec2 left_antenna_local = vec2(15.0, -6.0);
    vec2 right_antenna_local = vec2(15.0, 6.0);
    vec2 pheromones_gland_local = vec2(-12.0, 0.0);
    mat2 rotation_angle = mat2(
        vec2(cos(ants[id].angle), sin(ants[id].angle)),
        vec2(-sin(ants[id].angle), cos(ants[id].angle))
    );
    vec2 left_antenna_rotated = rotation_angle * left_antenna_local;
    vec2 right_antenna_rotated = rotation_angle * right_antenna_local;
    vec2 pheromones_gland_rotated = rotation_angle * pheromones_gland_local;

    vec4 left_antenna_pheromones = imageLoad(pheromones, ivec2(ants[id].position + left_antenna_rotated));
    vec4 right_antenna_pheromones = imageLoad(pheromones, ivec2(ants[id].position + right_antenna_rotated));
    imageStore(pheromones, ivec2(ants[id].position + pheromones_gland_rotated), vec4(1.0, 0.0, 0.0, 1.0));

    bool is_pheromones = left_antenna_pheromones.r >= 0.01 || right_antenna_pheromones.r >= 0.01;
    bool turn_left = left_antenna_pheromones.r > right_antenna_pheromones.r;
    bool turn_right = left_antenna_pheromones.r < right_antenna_pheromones.r;

    if (is_pheromones) {
        if (turn_left) {
            // Pay attention to godot axis and rotation direction
            ants[id].angle -= rotation_speed * params.time_elapsed;
        } else if (turn_right) {
            ants[id].angle += rotation_speed * params.time_elapsed;
        }
    } // else if (left_antenna_pheromones.r < 0.01 && right_antenna_pheromones < 0.01) {
    //     random_direction;
    // }

    vec2 forward = rotation_angle * vec2(1.0, 0.0);
    ants[id].position += forward * speed * params.time_elapsed;
}
