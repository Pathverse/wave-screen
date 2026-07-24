## Why

The `wave_screen` specs were reconstructed from the delivered 0.1.0 revamp, and
that reconstruction exposed a coverage gap. Nine behave scenarios bind to nine
Flutter proofs, and a set of unit tests covers value semantics — but a large
share of specified behaviour is asserted nowhere:

- **No assertion guard is tested at all.** Every `assert` in the public API
  (`WaveStyle.opacity` range, `GerstnerWaveShape.steepness`,
  `MetaballWaveShape.blobCount`/`radius`, `PingPongMotion.period`,
  `PointerRippleEffect.decay`/`wavelength`) can be removed today without a
  single test failing.
- **Effect-list equality is untested.** `Wave`'s `listEquals` over `effects` is
  what drives `WaveField` repaint decisions; nothing exercises it.
- **The never-blank guarantee is unproven.** The CPU fallback is the package's
  central resilience promise, and no test asserts that a surface actually paints
  when the shader is absent.
- **Opt-in interactivity is unproven.** Nothing asserts that a field *without* a
  `PointerRippleEffect` leaves pointers alone.
- **Lifecycle behaviour is unproven.** Disposal and `shouldRepaint` are
  unasserted.

One specified scenario is also not machine-verifiable as written: `flutter test`
runs headless, so the GPU path never executes there and "the field paints a
shader-filled rect" can never be observed in the suite. Specifying an outcome no
suite can ever check is a standing false promise, so it is restated as the
contract that actually guards GPU correctness — the packed uniform vector
matching the shader's declared layout.

## What Changes

Coverage only — **no production behaviour changes**. The public API, rendering
model, and widget tree are untouched.

- Add three behave journeys with bound Flutter proofs, at journey altitude
  (never mirroring unit tests):
  - a mounted surface really paints its wave colour into pixels,
  - a field with no ripple effect ignores pointers,
  - a `WaveScreen` layers its child above the animated waves.
- Add unit-level suites for the inner loop: assertion guards, effect-list
  equality, metaball edge wrapping, ping-pong periodicity, baseline/offset
  independence, `shouldRepaint`, disposal, shader load-once caching, pointer
  clamping, and gallery catalogue spread.
- Assert the GLSL height field against the Dart model for all three shapes —
  the package's central architectural claim, previously unchecked.
- Assert package-prefixed shader asset resolution from the example app, the only
  place that consumes the package as a real dependency.
- Restate one `wave-rendering` scenario so it asserts a checkable contract.
- Register every new proof id in `dart_test.yaml`.

## Capabilities

### New Capabilities

None. This change adds no capability and no requirement.

### Modified Capabilities

- `wave-rendering`: two requirements are corrected against observed behaviour.
  **GPU-first rendering** keeps its intent but replaces its unverifiable scenario
  with the uniform-layout contract that guards it. **Render resource lifecycle**
  is corrected because the spec claimed an *equal* wave list avoids a repaint,
  while the painter compares lists by **identity** — so an equal but freshly
  constructed list does repaint.

## Impact

- `features/` — three new journey scenarios.
- `test/proofs/` — three new bound proofs.
- `test/wave/`, `test/screen/` — new unit suites.
- `example/test/` — one new suite, run from `example/` (the root `flutter test`
  does not descend into it).
- `dart_test.yaml` — three new proof tags.
- `openspec/specs/wave-rendering/spec.md` — two requirements modified on archive.
- No change to `lib/`, `shaders/`, or `pubspec.yaml`.
