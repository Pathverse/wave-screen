## 0.1.0

Complete rewrite — `wave_screen` is now a composable, GPU-shader-driven wave
library. **Breaking:** the entire public API changed and the `WaveSkeletonizer`
module was removed.

### Added

- Composable `Wave` built from swappable traits: `WaveShape`, `WaveStyle`,
  `WaveMotion`, and `WaveEffect`.
- `WaveShape.sine`, `WaveShape.gerstner` (sharpened ocean crests), and
  `WaveShape.metaball` (gooey merging blobs) — each a pure, testable height field
  mirrored by the fragment shader.
- `WaveMotion.drift`, `WaveMotion.pingPong` (smooth oscillation), and
  `WaveMotion.still`.
- `WaveField` — GPU fragment-shader compositor with a CPU fallback.
- `PointerRippleEffect` + interactive `WaveField`: taps and drags spawn ripples
  that displace the surface, with an `onRipple` callback.
- `WaveScreen` + a broad `WavePresets` gallery (14 curated presets including the
  classic `violet` theme, reachable via `WavePresets.byName` / `.all`).

### Removed

- `WaveSkeletonizer` and the `skeletonizer` dependency.
- The previous `Wave`/`WaveScreen` recipe/adaptation/palette API.

## 0.0.1

- Initial release of `wave_screen` (legacy API).
