#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;
uniform float u_time;
uniform vec2  u_resolution;
uniform float u_strength;
uniform float u_edgeBias;
uniform vec2  u_windDirection;

varying vec2 v_texCoord;

// ---------------- Noise ----------------

float hash(vec2 p) {
p = fract(p * vec2(127.1, 311.7));
p += dot(p, p + 34.5);
return fract(p.x * p.y);
}

float noise(vec2 p) {
vec2 i = floor(p);
vec2 f = fract(p);
vec2 u = f * f * (3.0 - 2.0 * f);

return mix(
        mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x),
        u.y
);
}

float fbm(vec2 p) {
float v = 0.0;
float a = 0.5;
for (int i = 0; i < 4; i++) {
v += a * noise(p);
p *= 2.0;
a *= 0.5;
}
return v;
}

// ---------------- Edge ----------------

float edgeFactor(vec2 uv) {
float d = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
return smoothstep(0.0, 0.35, d);
}

void main() {
    vec2 uv = v_texCoord;
    float t = clamp(u_time, 0.0, 1.0);

    // ---------- Dissolve field ----------
    float n = fbm(uv * 9.0);
    float e = edgeFactor(uv);
    float field = n + mix(0.0, 1.0 - e, u_edgeBias) * 0.8;

    float dissolve = t * 1.1 - field;

    // ---------- SOLID ----------
    if (dissolve < 0.0) {
        vec4 col = texture2D(u_texture, uv);
        col.a *= 1.0 - smoothstep(0.85, 1.0, t);
        gl_FragColor = col;
        return;
    }

    // ---------- DUST ----------
    vec2 wind = normalize(
            length(u_windDirection) > 0.0 ? u_windDirection : vec2(1.0, -0.3)
    );

    vec2 randomDir = normalize(vec2(
            hash(uv + 1.7),
            hash(uv + 8.3)
    ) * 2.0 - 1.0);

    vec2 motionDir = normalize(wind * 0.7 + randomDir * 0.3);

    float travel = dissolve * (0.35 + u_strength * 0.6);
    float jitter = (fbm(uv * 30.0 + t * 6.0) - 0.5) * 0.03;

    vec2 offset = motionDir * travel + vec2(-motionDir.y, motionDir.x) * jitter;
    vec2 sampleUv = uv - offset;

    if (any(lessThan(sampleUv, vec2(0.0))) ||
        any(greaterThan(sampleUv, vec2(1.0)))) {
        discard;
    }

    vec4 dust = texture2D(u_texture, sampleUv);

    float life = exp(-travel * 3.5);
    life *= 1.0 - smoothstep(0.8, 1.0, t);
    life *= mix(0.4, 1.0, fbm(sampleUv * 40.0));

    dust.a *= life;

    if (dust.a < 0.02) discard;

    gl_FragColor = dust;
}


