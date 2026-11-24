## 0.2.0

- Fixed translucent wave compositing in the shader using premultiplied source-over alpha blending.
- Fixed undefined ripple envelope arithmetic and aligned the shader's negligible-amplitude cutoff with the Dart model.
- Fixed concurrent shader loading so fields await the same pending load and reuse its result.
- Fixed infinite ripple lifetime for negative strength and explicitly gave negative and negligible strengths zero lifetime.
- Added regression proofs for translucent compositing, ripple rendering, negligible ripple expiry, and concurrent shader loading.
- Reduced the published package contents to the library, shader assets, package documentation, and runnable web example.

## 0.1.0

- Completely rewrote `wave_screen` as a composable, GPU-shader-driven wave library with a breaking public API change.
- Added composable `Wave` objects built from swappable `WaveShape`, `WaveStyle`, `WaveMotion`, and `WaveEffect` traits.
- Added `WaveShape.sine`, `WaveShape.gerstner` for sharpened ocean crests, and `WaveShape.metaball` for gooey merging blobs, each with a pure, testable height field mirrored by the fragment shader.
- Added `WaveMotion.drift`, `WaveMotion.pingPong` for smooth oscillation, and `WaveMotion.still`.
- Added `WaveField` with GPU fragment-shader compositing and a CPU fallback.
- Added `PointerRippleEffect` and interactive `WaveField` surfaces where taps and drags spawn ripples and report their normalized position through `onRipple`.
- Added `WaveScreen` and 14 curated `WavePresets`, including the classic `violet` theme, reachable through `WavePresets.byName` and `WavePresets.all`.
- Removed `WaveSkeletonizer` and the `skeletonizer` dependency.
- Removed the previous `Wave`/`WaveScreen` recipe/adaptation/palette API.

## 0.0.1

- Initial release of `wave_screen` (legacy API).
