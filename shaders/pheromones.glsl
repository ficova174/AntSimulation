#[compute]
#version 450

layout(push_constant, std430) uniform Params {
    bool clicked;
    vec2 center_pos;
    float radius;
    bool blend_add;
} mouse;

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) uniform restrict readonly image2D input_image;

layout(rgba8, set = 0, binding = 1) uniform restrict writeonly image2D output_image;

void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    vec4 current_v = imageLoad(input_image, uv);

    if (mouse.clicked && distance(mouse.center_pos, vec2(uv)) <= mouse.radius) {
        float dir = mouse.blend_add ? 1.0 : -1.0;
        float change = 0.1 * dir;

        current_v.r = clamp(current_v.r + change, 0.0, 1.0);
        current_v.b = clamp(current_v.b - change, 0.0, 1.0);
    } else {
        float change = 0.01;

        current_v.r = clamp(current_v.r - change, 0.0, 1.0);
        current_v.b = clamp(current_v.b + change, 0.0, 1.0);
    }

    imageStore(output_image, uv, current_v);
}
