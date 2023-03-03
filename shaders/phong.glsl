#version 320 es

precision mediump float;

out vec4 fragColor;

uniform float Ka;   // Ambient reflection coefficient
uniform float Kd;   // Diffuse reflection coefficient
uniform float Ks;   // Specular reflection coefficient
uniform float shininessVal; // Shininess
uniform vec3 ambientColor; // Material color
uniform vec3 specularColor; // Material color
uniform vec3 lightPos; // Light position
uniform vec2 canvasSize; // canvas size
uniform vec3 surfaceNormal; // surface normal
uniform vec3 viewerPos; // viewer position
uniform vec3 offset; // offset (world coordinates)
uniform vec3 worldSize; // size (world coordinates)

uniform sampler2D mainTexture; // image texture
uniform sampler2D maskTexture; // mask texture


vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;

    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    vec4 maskTint = vec4(1.0, 1.0, 1.0, 1.0);
    float maskShineness = 10.0;
    float targetHue = 5.0 / 6.0;

    vec4 mainTextureColor = texture(
        mainTexture,
        vec2(gl_FragCoord.x / canvasSize.x, gl_FragCoord.y / canvasSize.y)
    );

    vec4 maskTextureColor = texture(
        maskTexture,
        vec2(gl_FragCoord.x / canvasSize.x, gl_FragCoord.y / canvasSize.y)
    );

    vec3 vertPos = vec3(
        (gl_FragCoord.x - canvasSize.x / 2.0) / canvasSize.x * worldSize.x,
        (gl_FragCoord.y - canvasSize.y / 2.0) / canvasSize.y * worldSize.y,
        0
    ) + offset;

    vec3 lightPosLocal = lightPos;
    vec3 viewerPosLocal = viewerPos;
    vec3 vertPosLocal = vertPos;

    vec3 N = normalize(surfaceNormal);
    vec3 L = normalize(lightPosLocal - vertPosLocal);

    // Lambert's cosine law
    float lambertian = max(dot(N, L), 0.0);
    float specular = 0.0;
    if (lambertian > 0.0) {
        vec3 R = reflect(-L, N);      // Reflected light vector
        vec3 V = normalize(viewerPosLocal - vertPosLocal); // Vector to viewer
        float specAngle = max(dot(R, V), 0.0);
        specular = pow(specAngle, shininessVal * (1.0 - maskTextureColor.a) + maskShineness * maskTextureColor.a);
    }

    float aa = maskTextureColor.a * maskTint.a;
    float aal = aa * (1.0 - lambertian);

    vec3 originalDiffuseColor = mainTextureColor.xyz;
    vec3 originalDiffuseHsv = rgb2hsv(originalDiffuseColor);
    float shiftedHue = originalDiffuseHsv.x * (1.0 - aal) + targetHue * aal;
    vec3 shiftedDiffuseColor = hsv2rgb(vec3(shiftedHue, originalDiffuseHsv.y, originalDiffuseHsv.z));

    fragColor = vec4(
        Ka * ambientColor +
        Kd * lambertian * shiftedDiffuseColor +
        Ks * specular * specularColor,
        mainTextureColor.a
    );
}