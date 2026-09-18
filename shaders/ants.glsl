#[compute]
#version 450

layout(push_constant, std430) uniform Params {
    int world_size;
    float world_to_phero_ratio;
    float time_elapsed;
} params;

struct Ant {
    vec2 position;
    float angle;
    int size;
    vec2 _pad; // bc struct must have offset multiple of its biggest element (vec2 position)
};

layout(std430, set = 0, binding = 0) buffer Ants {
    Ant ants[];
};

layout(rgba8, set = 0, binding = 1) uniform restrict image2D pheromones;

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

void main() {
    uint id = gl_GlobalInvocationID.x;
    Ant ant = ants[id];

    float speed = 100.0;
    float rotation_speed = 10.0;

    vec2 left_antenna_local = vec2(15.0, -6.0);
    vec2 right_antenna_local = vec2(15.0, 6.0);
    vec2 pheromones_gland_local = vec2(-12.0, 0.0);

    mat2 rotation_angle = mat2(
        vec2(cos(ant.angle), sin(ant.angle)),
        vec2(-sin(ant.angle), cos(ant.angle))
    );

    vec2 left_antenna_rotated = rotation_angle * left_antenna_local;
    vec2 right_antenna_rotated = rotation_angle * right_antenna_local;
    vec2 pheromones_gland_rotated = rotation_angle * pheromones_gland_local;

    vec2 left_antenna_rotated_scaled = params.world_to_phero_ratio * left_antenna_rotated;
    vec2 right_antenna_rotated_scaled = params.world_to_phero_ratio * right_antenna_rotated;
    vec2 pheromones_gland_rotated_scaled = params.world_to_phero_ratio * pheromones_gland_rotated;

    vec4 left_antenna_pheromones = imageLoad(pheromones, ivec2(params.world_to_phero_ratio * ant.position + left_antenna_rotated_scaled));
    vec4 right_antenna_pheromones = imageLoad(pheromones, ivec2(params.world_to_phero_ratio * ant.position + right_antenna_rotated_scaled));
    imageStore(pheromones, ivec2(params.world_to_phero_ratio * ant.position + pheromones_gland_rotated_scaled), vec4(1.0, 0.0, 0.0, 1.0));

    bool is_pheromones = left_antenna_pheromones.r >= 0.01 || right_antenna_pheromones.r >= 0.01;
    bool turn_left = left_antenna_pheromones.r > right_antenna_pheromones.r;
    bool turn_right = left_antenna_pheromones.r < right_antenna_pheromones.r;

    if (is_pheromones) {
        if (turn_left) {
            // Pay attention to godot axis and rotation direction
            ant.angle -= rotation_speed * params.time_elapsed;
        } else if (turn_right) {
            ant.angle += rotation_speed * params.time_elapsed;
        }
    } // else if (left_antenna_pheromones.r < 0.01 && right_antenna_pheromones < 0.01) {
    //     random_direction;
    // }

    vec2 forward = rotation_angle * vec2(1.0, 0.0);
    ant.position += forward * speed * params.time_elapsed;

    vec2 dir = vec2(cos(ant.angle), sin(ant.angle));
    if (ant.position.x < ant.size / 2.0) {
        ant.position.x = ant.size / 2.0;
        dir.x = abs(dir.x);
        ant.angle = atan(dir.y, dir.x);
    } else if (ant.position.x > params.world_size - ant.size / 2.0) {
        ant.position.x = params.world_size - ant.size / 2.0;
        dir.x = -abs(dir.x);
        ant.angle = atan(dir.y, dir.x);
    }
    if (ant.position.y < ant.size / 2.0) {
        ant.position.y = ant.size / 2.0;
        dir.y = abs(dir.y);
        ant.angle = atan(dir.y, dir.x);
    } else if (ant.position.y > params.world_size - ant.size / 2.0) {
        ant.position.y = params.world_size - ant.size / 2.0;
        dir.y = -abs(dir.y);
        ant.angle = atan(dir.y, dir.x);
    }

    ants[id] = ant;
}
