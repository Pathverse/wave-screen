// wave.frag — GPU height-field renderer for wave_screen.
//
// Renders up to MAX_LAYERS stacked sine-wave surfaces. Each layer fills the
// region below its crest with its fill colour, composited back-to-front. The
// crest height field mirrors the Dart `WaveShape.sine` model so the CPU-side
// `Wave.heightAt` and the GPU render agree.
#include <flutter/runtime_effect.glsl>

const int MAX_LAYERS = 8;
const float TWO_PI = 6.28318530717958647692;

uniform vec2 uSize;         // pixel size of the paint area
uniform float uLayerCount;  // active layer count (<= MAX_LAYERS)

// Per-layer geometry: x = baseline (0..1 of height), y = amplitude (0..1),
// z = frequency (cycles across width), w = phase (radians).
uniform vec4 uGeometry[MAX_LAYERS];
// Per-layer fill colour, premultiply-friendly straight RGBA.
uniform vec4 uColor[MAX_LAYERS];

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize; // 0..1, y grows downward
  vec4 color = vec4(0.0);
  int count = int(uLayerCount + 0.5);

  for (int i = 0; i < MAX_LAYERS; i++) {
    if (i >= count) {
      break;
    }
    vec4 g = uGeometry[i];
    float crest = g.x + g.y * sin((uv.x * TWO_PI * g.z) + g.w);
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
