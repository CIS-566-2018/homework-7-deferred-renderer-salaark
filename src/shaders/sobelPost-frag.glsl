#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;
uniform sampler2D u_gb0;

const vec2 invScreen = vec2(1.0/1438.0, 1.0/534.0);

const vec2 gaussFilter[7] = vec2[](
	vec2(-3.0,	0.015625),
	vec2(-2.0,	0.09375),
	vec2(-1.0,	0.234375),
	vec2(0.0,	0.3125),
	vec2(1.0,	0.234375),
	vec2(2.0,	0.09375),
	vec2(3.0,	0.015625)
);

float rgb2luma(vec3 rgb) {
    return sqrt(dot(rgb, vec3(0.299, 0.587, 0.114)));
}

// Sobel filter only colors edges based on luminance
void main() {
	vec3 color = texture(u_frame, fs_UV).xyz;

	// Luma at the current fragment
	float lumaCenter = rgb2luma(color);

	// Luma at the four direct neighbours of the current fragment.
	float lumaDown = rgb2luma(textureOffset(u_frame,fs_UV,ivec2(0,-1)).rgb);
	float lumaUp = rgb2luma(textureOffset(u_frame,fs_UV,ivec2(0,1)).rgb);
	float lumaLeft = rgb2luma(textureOffset(u_frame,fs_UV,ivec2(-1,0)).rgb);
	float lumaRight = rgb2luma(textureOffset(u_frame,fs_UV,ivec2(1,0)).rgb);

	// Find the maximum and minimum luma around the current fragment.
	float lumaMin = min(lumaCenter,min(min(lumaDown,lumaUp),min(lumaLeft,lumaRight)));
	float lumaMax = max(lumaCenter,max(max(lumaDown,lumaUp),max(lumaLeft,lumaRight)));

	// Compute the delta.
	float lumaRange = lumaMax - lumaMin;

	// If the luma variation is lower that a threshold (or if we are in a really dark area), we are not on an edge.
	if(lumaRange < max(0.0312,lumaMax*0.125)) {
	    out_Col = vec4(color/8.0, 1.0);
	} else {
		color = vec3(0.0);
		for( int i = 0; i < 7; i++ ) {
			color += texture( u_frame, vec2( fs_UV.x+gaussFilter[i].x*invScreen.x, fs_UV.y+gaussFilter[i].x*invScreen.y ) ).xyz*gaussFilter[i].y;
		}
		out_Col = vec4(color, 1.0);
	}
}
