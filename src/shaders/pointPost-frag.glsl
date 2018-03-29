#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;
uniform sampler2D u_gb0;

// Shader that resembles the pointilism art style
void main() {
	out_Col = vec4(0.988235, 0.94902, 0.870588, 1.0);
	vec2 near_UV = vec2(round(fs_UV.x*100.0), round(fs_UV.y*100.0));
	// Use saturation/lightness to determine size
	vec3 color = texture(u_frame, near_UV/100.0).xyz;
	float Cmax = max(max(color.r, color.g), color.b);
	float Cmin = min(min(color.r, color.g), color.b);
	float delt = Cmax-Cmin;
	float L = max((Cmax+Cmin)/2.0, 0.3);
	//float S = delt/(1.0-abs(2.0*L-1.0));
	if(distance(fs_UV*100.0, near_UV) < L) {
		out_Col = texture(u_frame, near_UV/100.0);
	}
}
