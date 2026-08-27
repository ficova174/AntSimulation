#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) uniform restrict readonly image2D input_image;

layout(rgba8, set = 0, binding = 1) uniform restrict writeonly image2D output_image;

void main() {
    
}
