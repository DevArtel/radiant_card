#version 320 es

precision mediump float;

layout(location = 0) out vec4 fragColor;

// layout(location = 0) in vec3 normalInterp;  // Surface normal
// layout(location = 1) in vec3 gl_FragCoord;       // Vertex position
// layout(location = 0) uniform int mode;   // Rendering mode
layout(location = 0) uniform float Ka;   // Ambient reflection coefficient
layout(location = 1) uniform float Kd;   // Diffuse reflection coefficient
layout(location = 2) uniform float Ks;   // Specular reflection coefficient
layout(location = 3) uniform float shininessVal; // Shininess
// Material color
layout(location = 4) uniform vec3 ambientColor;
layout(location = 5) uniform vec3 diffuseColor;
layout(location = 6) uniform vec3 specularColor;
layout(location = 7) uniform vec3 lightPos; // Light position

void main() {
  //vec3 vertPos = vec3(gl_FragCoord.x, gl_FragCoord.y, gl_FragCoord.z);
  vec3 vertPos = vec3(0.0, 0.0, 0.0);
  // vec3 N = normalize(normalInterp);
  vec3 N = vec3(0.0, 0.0, -1.0);
  vec3 L = normalize(lightPos - vertPos);

  // Lambert's cosine law
  float lambertian = max(dot(N, L), 0.0);
  float specular = 0.0;
  if(lambertian > 0.0) {
    vec3 R = reflect(-L, N);      // Reflected light vector
    vec3 V = normalize(-vertPos); // Vector to viewer
    // Compute the specular term
    float specAngle = max(dot(R, V), 0.0);
    specular = pow(specAngle, shininessVal);
  }
  fragColor = vec4(Ka * ambientColor +
                      Kd * lambertian * diffuseColor +
                      Ks * specular * specularColor, 1.0);

  // only ambient
  // if(mode == 2) fragColor = vec4(Ka * ambientColor, 1.0);
  // only diffuse
  // if(mode == 3) fragColor = vec4(Kd * lambertian * diffuseColor, 1.0);
  // only specular
  // if(mode == 4) fragColor = vec4(Ks * specular * specularColor, 1.0);
}
