// wave.frag — GPU height-field renderer for wave_screen.
//
// Renders up to MAX_LAYERS stacked wave surfaces. Each layer fills the region
// below its crest with its fill colour, composited back-to-front. The crest
// height field mirrors the Dart WaveShape models (sine / gerstner / metaball) so
// the CPU-side `Wave.heightAt` and the GPU render agree.
#include <flutter/runtime_effect.glsl>

const int MAX_LAYERS = 8;
const int MAX_BLOBS = 8;
const int MAX_RIPPLES = 8;
const float TWO_PI = 6.28318530717958647692;

uniform vec2 uSize;         // pixel size of the paint area
uniform float uLayerCount;  // active layer count (<= MAX_LAYERS)

// Per-layer geometry A: x = baseline (0..1 of height), y = amplitude (0..1),
// z = frequency (cycles across width), w = phase (radians).
uniform vec4 uGeometry[MAX_LAYERS];
// Per-layer geometry B: x = shapeType (0 sine, 1 gerstner, 2 metaball),
// y = steepness (gerstner), z = blobCount (metaball), w = radius (metaball).
uniform vec4 uGeometryB[MAX_LAYERS];
// Per-layer fill colour, straight RGBA.
uniform vec4 uColor[MAX_LAYERS];
// Pointer ripple parameters: x = strength, y = decay, z = speed, w = wavelength.
uniform vec4 uRippleParams;
uniform float uRippleCount;
// Per-ripple state: x = originX (0..1), y = age (seconds).
uniform vec4 uRipple[MAX_RIPPLES];

out vec4 fragColor;

// Summed pointer-ripple displacement at horizontal ux (normalized height units).
float rippleDisplacement(float ux) {
  int n = int(uRippleCount + 0.5);
  if (n <= 0) {
    return 0.0;
  }
  float strength = uRippleParams.x;
  float decay = uRippleParams.y;
  float speed = uRippleParams.z;
  float wl = max(uRippleParams.w, 1e-4);
  float sum = 0.0;
  for (int i = 0; i < MAX_RIPPLES; i++) {
    if (i >= n) {
      break;
    }
    float age = uRipple[i].y;
    float amp = strength * exp(-decay * age);
    float offset = abs(ux - uRipple[i].x) - (speed * age);
    float ring = cos((TWO_PI * offset) / wl);
    float env = exp(-pow(offset / (wl * 1.5), 2.0));
    sum += amp * ring * env;
  }
  return sum;
}

// Crest offset (in normalized height units) for a layer at horizontal ux.
float crestOffset(vec4 g, vec4 gb, float ux) {
  float theta = (ux * TWO_PI * g.z) + g.w;
  int shapeType = int(gb.x + 0.5);

  if (shapeType == 1) {
    // Gerstner: gamma-sharpened sine (steepness 0 == sine).
    float u = 0.5 * (1.0 + sin(theta));
    float sharpened = pow(u, 1.0 + gb.y);
    return g.y * ((2.0 * sharpened) - 1.0);
  }

  if (shapeType == 2) {
    // Metaball: smooth union of evenly-spaced drifting Gaussian blobs.
    float drift = g.w / TWO_PI;
    int n = int(gb.z + 0.5);
    float radius = max(gb.w, 1e-4);
    float product = 1.0;
    for (int i = 0; i < MAX_BLOBS; i++) {
      if (i >= n) {
        break;
      }
      float center = fract(((float(i) + 0.5) / float(n)) + drift);
      float raw = abs(ux - center);
      float dist = min(raw, 1.0 - raw);
      float bump = exp(-pow(dist / radius, 2.0));
      product *= (1.0 - bump);
    }
    return -g.y * (1.0 - product);
  }

  // Sine.
  return g.y * sin(theta);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize; // 0..1, y grows downward
  vec4 color = vec4(0.0);
  int count = int(uLayerCount + 0.5);

  for (int i = 0; i < MAX_LAYERS; i++) {
    if (i >= count) {
      break;
    }
    vec4 g = uGeometry[i];
    vec4 gb = uGeometryB[i];
    float crest = g.x + crestOffset(g, gb, uv.x) + rippleDisplacement(uv.x);
    // Anti-aliased fill over roughly one pixel around the crest line. Skia's
    // SkSL runtime effects forbid derivative functions (fwidth), so the pixel
    // size is derived from the paint area instead.
    float aa = 1.5 / max(uSize.y, 1.0);
    float fill = smoothstep(crest - aa, crest + aa, uv.y);
    vec4 lc = uColor[i];
    color = mix(color, lc, lc.a * fill);
  }

  fragColor = color;
}
