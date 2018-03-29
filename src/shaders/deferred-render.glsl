#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;

uniform mat4 u_View;
uniform vec4 u_CamPos;   

const vec4 lightPos = vec4(-2, 2, -3, 1);

//NOISE FUNCTION (Found online from https://github.com/ashima/webgl-noise)
float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

//Custom fractal brownian motion based on above noise function
float fbm(vec3 p) {
    float n = 0.0;
    float w = 0.4;
    for (int i = 0; i < 5; i++) {
        n += noise(p) * w;
        w *= 0.5;
        p *= 2.0;
        p += vec3(100);
    }
    return n;
}

void main() {
	// read from GBuffers
	vec4 gb2 = texture(u_gb2, fs_UV); //albedo
	vec4 gb0 = texture(u_gb0, fs_UV); //norm xyz, camera z depth

	if(gb0.z < 0.1) {
		out_Col = vec4(fbm(vec3((fs_UV.x*15.0)+u_Time/10.0, fs_UV.y*7.5, u_Time/3.0))*vec3(0.01, 0.01, 0.08), 1.0);
		//out_Col = vec4(0.0);
	} else {
		// Material base color (before shading)
	    vec4 diffuseColor = vec4(gb2.xyz, 1.0);
	    vec4 norm = normalize(vec4(gb0.xyz, 1.0));

	    // Cast ray from screen space to world space and find light direction
	    vec4 ref = u_CamPos + gb0.w*vec4(0,0,1,1); //eye + t * F
	    float len = length(ref-u_CamPos);
	    float alpha = 1.0; //fov/2.0
	    vec4 V = vec4(0,1,0,1)*len*tan(alpha); // U*len*tan(alpha)
	    vec4 H = vec4(1,0,0,1)*len*2.2*tan(alpha); // R*len*aspect*tan(alpha);
	    vec2 uv = vec2((fs_UV.x-0.5)*2.0, (fs_UV.y-0.5)*2.0);
	    vec4 fragPos = ref + uv.x*H + uv.y*V;
	    vec4 lightVec = u_View*lightPos - fragPos;

	    // Calculate the diffuse term for shader
	    float diffuseTerm = dot(normalize(norm), normalize(lightVec));
	    // Avoid negative lighting values
	    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

	    float ambientTerm = 0.2;
	    float lightIntensity = diffuseTerm + ambientTerm;

	    // Material specular color
	    vec4 specularColor = vec4(1.0,1.0,0.6,1.0);
	    // Calculate the specular term for shader
	    vec4 refl = normalize(normalize(-fragPos)+normalize(lightVec));
	    float specularTerm = pow(max(dot(refl,norm),0.0),25.0);

	    // Compute final shaded color
	    out_Col = vec4(diffuseColor.rgb * lightIntensity + specularColor.rgb * specularTerm, diffuseColor.a);
	}
}