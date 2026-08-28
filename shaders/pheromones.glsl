#[compute]
#version 450

layout(push_constant, std430) uniform PushConstants {
    vec2 center_pos;
    int radius;
    bool blend_sub;
} mouse_click;

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) uniform restrict readonly image2D input_image;

layout(rgba8, set = 0, binding = 1) uniform restrict writeonly image2D output_image;

void main() {
    
}
