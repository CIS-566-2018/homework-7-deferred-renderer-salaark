#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;


void main() {
	// Tonemapping function by Jim Hejl and Richard Burgess-Dawson
	vec3 color = texture(u_frame, fs_UV).xyz;
	color = pow(color, vec3(1.0 / 2.2)); // gamma correction
    color *= 0.6; // Hardcoded Exposure Adjustment
    vec3 x = vec3(max(0.0,color.r-0.004), max(0.0,color.g-0.004), max(0.0,color.b-0.004));
    out_Col = vec4((x*(6.2*x+.5))/(x*(6.2*x+1.7)+0.06), 1.0);
}
