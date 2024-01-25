precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform float iTime;
uniform vec2 iResolution;
out vec4 fragColor;

mat2 Rot(float angle){
    float s=sin(angle), c=cos(angle);
    return mat2(c, -s, s, c);
}

float Hash21(vec2 p){
    p = fract(p*vec2(123.34, 456.21));
    p +=dot(p, p+45.32);
    return  fract(p.x*p.y);
}

float Star(vec2 uv, float flare){
    float d = length(uv);
    float m = .10/d;
    float rays = max(0.8, 1.-abs(uv.x*uv.y*1000.));
    m +=rays*flare;

    uv *=Rot(3.1415/4.);
    rays = max(0., 1.-abs(uv.x*uv.y*1000.));
    m +=rays*.3*flare;
    m *=smoothstep(1., .2, d);
    return m;
}

vec3 StarLayer(vec2 uv){

    vec3 col = vec3(0.);

    vec2 gv= fract(uv)-.5;
    vec2 id= floor(uv);

    for(int y=-1; y<=1; y++){
        for(int x=-1; x<=1; x++){

            vec2 offset= vec2(x, y);
            float n = Hash21(id+offset);
            float size = fract(n*345.32);
            float star= Star(gv-offset-(vec2(n, fract(n*34.))-.5), smoothstep(.9, 1., size)*.6);
            vec3 color = sin(vec3(.2, .3, .9)*fract(n*2345.2)*123.2)*.5+.5;
            color = color*vec3(1., .25, 1.+size);

            star *=sin(iTime*3.+n*6.2831)*.5+1.;
            col +=star*size*color;

        }
    }
    return col;
}
vec4 mainImage( in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    float t=  iTime;
    uv *=Rot(t);

    vec3 col = vec3(0.);

    for(float i =0.; i<1.; i += 1./3.5){
        float depth = fract(i+t);
        float scale= mix(10.,.5, depth);
        float fade = depth*smoothstep(1., .5, depth) / 3;
        col += StarLayer(uv*scale+i*453.32)*fade;
    }
    fragColor = vec4(col,0.1);

    return fragColor;
}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    fragColor = mainImage(pos);
}