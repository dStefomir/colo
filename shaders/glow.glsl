#version 460 core

#include <flutter/runtime_effect.glsl>

uniform float iTime;
uniform vec2 iResolution;
uniform vec3 glowColor;

out vec4 fragColor;

const int MAX_STEPS = 30;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 1e-5;

float getGlow(float dist, float radius, float intensity){
    return pow(radius / max(dist, 1e-3), intensity);
}

vec3 rayDirection(float fieldOfView, vec2 fragCoord) {
    vec2 xy = fragCoord - iResolution.xy / 2.0;
    float z = (0.5 * iResolution.y) / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3(xy, -z));
}

mat3 lookAt(vec3 camera, vec3 targetDir, vec3 up){
    vec3 zaxis = normalize(targetDir);
    vec3 xaxis = normalize(cross(zaxis, up));
    vec3 yaxis = cross(xaxis, zaxis);

    return mat3(xaxis, yaxis, -zaxis);
}

vec3 rotate(vec3 p, vec4 q){
    return 2.0 * cross(q.xyz, p * q.w + cross(q.xyz, p)) + p;
}

float torusSDF( vec3 p, vec2 t ){
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

float getSDF(vec3 position) {
    float angle = iTime;
    vec3 axis = normalize(vec3(1.0, 1.0, 1.0));
    position = rotate(position, vec4(axis * sin(-angle*0.5), cos(-angle*0.5)));
    return torusSDF(position, vec2(1.0, 0.2));

}

float distanceToScene(vec3 cameraPos, vec3 rayDir, float start, float end, inout float glow) {
    float depth = start;
    float dist;

    for (int i = 0; i < MAX_STEPS; i++) {
        dist = getSDF(cameraPos + depth * rayDir);
        glow += getGlow(dist, 1e-3, 0.47);
        if(dist < EPSILON){
            return depth;
        }

        depth += dist;

        if(depth >= end){
            return end;
        }
    }

    return end;
}

vec3 ACESFilm(vec3 x){
    return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}

vec4 mainImage( in vec2 fragCoord ){

    vec3 rayDir = rayDirection(75.0, fragCoord);
    vec3 cameraPos = vec3(1.6);

    vec3 target = -normalize(cameraPos);
    vec3 up = vec3(0.0, 1.0, 0.0);

    mat3 viewMatrix = lookAt(cameraPos, target, up);

    rayDir = viewMatrix * rayDir;

    float glow = -0.11;

    float dist = distanceToScene(cameraPos, rayDir, MIN_DIST, MAX_DIST, glow);

    vec3 col = glow * glowColor;

    col = ACESFilm(col);

    col = pow(col, vec3(5.4545));

    fragColor = vec4(col, 0.0);

    return fragColor;
}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    fragColor = mainImage(pos);
}