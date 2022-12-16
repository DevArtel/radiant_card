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

//vec3 hsv2rgb(vec3 hsv) {
//    float c = hsv.z * hsv.y;
//    float hPrime = hsv.x / 60.0;
//    float x = c * (1.0 - abs(mod(hPrime, 2.0) - 1.0));
//    vec3 rgb1;
//    if (0.0 <= hPrime && hPrime < 1.0) {
//        rgb1 = vec3(c, x, 0.0);
//    } else if (1.0 <= hPrime && hPrime < 2.0) {
//        rgb1 = vec3(x, c, 0.0);
//    } else if (2.0 <= hPrime && hPrime < 3.0) {
//        rgb1 = vec3(0.0, c, x);
//    } else if (3.0 <= hPrime && hPrime < 4.0) {
//        rgb1 = vec3(0.0, x, c);
//    } else if (4.0 <= hPrime && hPrime < 5.0) {
//        rgb1 = vec3(x, 0.0, c);
//    } else if (5.0 <= hPrime && hPrime < 6.0) {
//        rgb1 = vec3(c, 0.0, x);
//    }
//    float m = hsv.z - c;
//    return rgb1 + m;
//}

void main() {
    vec4 maskTint = vec4(1.0, 1.0, 1.0, 1.0);
    float maskShineness = 10.0;
    float targetHue = 5.0 / 6.0;

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