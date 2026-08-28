#[compute]
#version 450

layout(push_constant, std430) uniform Params {
    // Mouse
    bool clicked;
    vec2 center_pos;
    float radius;
    bool blend_add;

    float time_elapsed;
} params;

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba8, set = 0, binding = 0) uniform restrict readonly image2D input_image;

layout(rgba8, set = 0, binding = 1) uniform restrict writeonly image2D output_image;

void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    vec4 current_v = imageLoad(input_image, uv);

    if (params.clicked && distance(params.center_pos, vec2(uv)) <= params.radius) {
        if (params.blend_add) {
            current_v.r = 1.0;
            current_v.b = 0.0;
        } else {
            current_v.r = 0.0;
            current_v.b = 1.0;
        }
    } else {
        // Differential equation of concentration reaction order 1
        // dC/dt = -C/tau -> C(t) = C_0 * e^(-t/tau) -> C_n+1 = C_n * e^(-delta_t/tau) -> proof by replacing t by n*delta_t and recurrence
        // dC/dt = C_max/tau - C/tau -> C(t) = C_max * (1 - e^(-t/tau)) -> C_n+1 = C_max + (C_n - C_max) * e^(-delta_t/tau)
        // -> proof by replacing t by n*delta_t and recurrence and using a trick (make appear the term you want eg -1 + 1)
        float tau = 1.0; // sec
        float change = exp(-params.time_elapsed / tau);
        current_v.r = current_v.r <= 0.10 ? current_v.r = 0.0 : current_v.r * change;
        current_v.b = current_v.b >= 0.90 ? current_v.b = 1.0 : 1.0 + (current_v.b - 1.0) * change;
    }

    imageStore(output_image, uv, current_v);
}
