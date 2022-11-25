#version 320 es

precision mediump float;

layout (location = 0) out vec4 fragColor;

layout (location = 0) uniform float Ka;   // Ambient reflection coefficient
layout (location = 1) uniform float Kd;   // Diffuse reflection coefficient
layout (location = 2) uniform float Ks;   // Specular reflection coefficient
layout (location = 3) uniform float shininessVal; // Shininess
layout (location = 4) uniform vec3 ambientColor; // Material color
layout (location = 5) uniform vec3 diffuseColor; // Material color - UNUSED
layout (location = 6) uniform vec3 specularColor; // Material color
layout (location = 7) uniform vec3 lightPos; // Light position
layout (location = 8) uniform vec2 viewportSize; // viewport size
layout (location = 9) uniform vec3 surfaceNormal; // surface normal
layout (location = 10) uniform vec3 viewerPos; // viewer position

layout (location = 11) uniform vec2 textureSize2;
layout (location = 12) uniform sampler2D mainTexture; // image texture
layout (location = 13) uniform sampler2D maskTexture; // mask texture


void main() {
    vec4 maskTint = vec4(1.0, 1.0, 1.0, 0.5);
    float maskShineness = 20.0;

    float scaleFactor = min(viewportSize.x, viewportSize.y);

    vec4 mainTextureColor = texture(
        mainTexture,
        vec2(gl_FragCoord.x / viewportSize.x, gl_FragCoord.y / viewportSize.y)
    );

    vec4 maskTextureColor = texture(
        maskTexture,
        vec2(gl_FragCoord.x / viewportSize.x, gl_FragCoord.y / viewportSize.y)
    );

    vec3 vertPos = vec3(
        (gl_FragCoord.x - viewportSize.x / 2.0) / scaleFactor,
        (gl_FragCoord.y - viewportSize.y / 2.0) / scaleFactor,
        0
    );

    vec3 N = normalize(surfaceNormal);
    vec3 L = normalize(lightPos - vertPos);

    // Lambert's cosine law
    float lambertian = max(dot(N, L), 0.0);
    float specular = 0.0;
    if (lambertian > 0.0) {
        vec3 R = reflect(-L, N);      // Reflected light vector
        vec3 V = normalize(viewerPos - vertPos); // Vector to viewer
        float specAngle = max(dot(R, V), 0.0);
        specular = pow(specAngle, shininessVal * (1.0 - maskTextureColor.a) + maskShineness * maskTextureColor.a);
    }

    fragColor = vec4(
        Ka * ambientColor +
        Kd * lambertian * (mainTextureColor.xyz * (1.0 - maskTextureColor.a * maskTint.a) + maskTint.xyz * maskTextureColor.a * maskTint.a) +
        Ks * specular * specularColor,
        mainTextureColor.a
    );
}
