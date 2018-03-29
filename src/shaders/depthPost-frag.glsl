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

// Depth of field performs Gaussian blur based on depth
void main() {

	vec4 color = vec4(0.0);
	vec4 gb0 = texture(u_gb0, fs_UV);

	//if(abs(gb0.w-1.0) > 0.1) {
	if(true) {
		for( int i = 0; i < 7; i++ ) {
			color += texture( u_frame, vec2( fs_UV.x+gaussFilter[i].x*invScreen.x, fs_UV.y+gaussFilter[i].x*invScreen.y ) )*gaussFilter[i].y;
		}
	} else {
		color = texture(u_frame, fs_UV);
	}
 
	out_Col = color;
}
