## 1. BDD journeys (outer loop, fail-first)

- [x] 1.1 Add the three journey scenarios to `features/` with their
      `@proof_<id>` tags, before any proof exists
- [x] 1.2 Register the three proof ids in `dart_test.yaml`
- [x] 1.3 Run `uvx behave` and capture RED — each new scenario failed because
      its bound `flutter test --tags` exited 79 (no matching test), and
      `binding_integrity` independently flagged all three as unbound
- [x] 1.4 Write the surface-rendering proof — capture the rendered boundary and
      assert wave-coloured pixels exist
      (`test/proofs/surface_paints_visible_waves_proof_test.dart`)
- [x] 1.5 Write `test/proofs/quiet_field_ignores_pointers_proof_test.dart` —
      a field with no ripple effect reports nothing on tap, an otherwise
      identical interactive one reports a centred ripple
- [x] 1.6 Write `test/proofs/screen_layers_child_proof_test.dart` — an opaque
      child covering the screen hides the wave colour entirely
- [x] 1.7 Re-run `uvx behave` and capture GREEN — 13 scenarios, 0 failed

## 2. TDD inner loop — trait contract

- [x] 2.1 `effects` defaults to empty and a wave carrying effects keeps its
      shape, style, motion, and composed height unchanged
- [x] 2.2 Effect-list equality: waves differing only by an effect are unequal
- [x] 2.3 `WaveStyle` rejects an opacity outside `[0, 1]` and accepts the bounds
- [x] 2.4 `sampleAt` returns a crest offset independent of `baseline`

## 3. TDD inner loop — shape guards and math

- [x] 3.1 `WaveShape.gerstner` rejects a negative `steepness`
- [x] 3.2 `WaveShape.metaball` rejects a non-positive `blobCount` and `radius`
- [x] 3.3 Metaball blob centres wrap across the horizontal edges under drift
- [x] 3.4 A sine completes exactly `frequency` cycles across the full width

## 4. TDD inner loop — motion contract

- [x] 4.1 `WaveMotion.pingPong` rejects a non-positive `period`
- [x] 4.2 Ping-pong phase is periodic across one full `period` and reaches
      both extremes
- [x] 4.3 Motions yielding the same phase produce the same surface height

## 5. TDD inner loop — rendering lifecycle

- [x] 5.1 `shouldRepaint` is false for the same instances, true when waves
      change, and true for an equal-but-distinct list (identity comparison)
- [x] 5.2 Disposing a mounted field stops its animation and releases its ticker
- [x] 5.3 The CPU fallback paints every wave's colour, in list order, driven
      directly with `shader: null`
- [x] 5.4 The fragment program is loaded once and cached

## 6. TDD inner loop — interaction guards

- [x] 6.1 `PointerRippleEffect` rejects a non-positive `decay` and `wavelength`
- [x] 6.2 Pointer positions dragged beyond the field clamp into `[0, 1]`

## 7. TDD inner loop — gallery catalogue

- [x] 7.1 Every gallery name is unique and resolves via `byName`
- [x] 7.2 The gallery spans sine, Gerstner, and metaball, and at least one
      preset carries a pointer ripple effect

## 8. Verification and gates

- [x] 8.1 Mutation-check each non-obvious new test — 7 mutations run, 6 killed
      on the first attempt. The 7th (CPU fallback paint order) **survived**,
      exposing that the widget-level capture was measuring the GPU path because
      the fragment program does load under `flutter test`. The test was rewritten
      to drive the painter with `shader: null`; the mutation is now killed.
- [x] 8.2 Gate A/B: `flutter test` green — 64 tests, up from 31
- [x] 8.3 Gate C: `uvx behave --dry-run` exits 0 (13 scenarios, 40 steps, none
      undefined) and `binding_integrity` passes the bijection
- [x] 8.4 `flutter analyze` — no issues found
- [x] 8.5 Record the BDD_PROOF and TDD_PROOF blocks

## 9. Second pass — gaps closed

- [x] 9.1 Package-prefixed asset resolution is now proven from the consuming
      side: `example/test/shader_asset_key_test.dart` asserts the bare in-repo
      key does **not** resolve in the example app while the package-prefixed one
      does, so the prefixed key is demonstrably load-bearing. Mutation: typoing
      the key fails the example suite while the root suite still passes — which
      is exactly the bug class the gap named.
- [x] 9.2 The shader's own output is now asserted against the Dart model:
      `test/wave/shader_mirrors_model_test.dart` applies uniforms, draws through
      the shader with no fallback in the path, reads the crest line back out of
      the rendered alpha channel (the smoothstep crosses 50% exactly at the
      crest), and compares it to `Wave.heightAt` at seven columns for all three
      shapes. Mutation: inverting the GLSL crest composition fails all three.
      This closes the package's central architectural claim, which nothing had
      been checking.

## 10. Stale-shader mismatch — assessed and reconciled

- [x] 10.1 Assessed the divergence between the fallback requirement and
      `_paintShader`. The requirement promised that *any* uniform-layout mismatch
      degrades. Only one direction can: a shader declaring **fewer** floats makes
      `setFloat` overrun a `Float32List` and raise a `RangeError` (caught by
      `on Error`), whereas a shader declaring **more** leaves every write in
      range, raises nothing, and renders a wrong surface silently. The declared
      count lives in `FragmentProgram._uniformFloatCount`, which is private, so
      that direction is undetectable at runtime — the requirement as written was
      unimplementable.
- [x] 10.2 Amended the `wave-rendering` delta to promise only the achievable
      behaviour, and to state the larger-layout case as an explicit limitation
      guarded at build time by `shader_mirrors_model_test.dart`. Docs only — no
      production change, no dummy asset shipped.
- [ ] 10.3 Still untested: the `try`/`catch` degradation branch itself.
      Fabricating a mismatched shader is impossible — `FragmentShader._` is
      private and `base class` forbids `implements`, so no fake can be
      constructed; only a real mismatched `.frag` would do it, and that would
      ship in the package. Accepted.
- [ ] 10.4 Noted but not acted on: `on Error` is broad enough to swallow a
      genuine bug in `WaveUniforms.pack` and degrade to CPU permanently with no
      diagnostic — no `debugPrint`, no `FlutterError.reportError`. Narrowing the
      catch and reporting once would need its own fail-first change.

## 11. Repo-level gap noted, owner declined

- [x] 11.1 There is **no CI test workflow** — `.github/workflows/` contains only
      `deploy-example-pages.yml`, so neither `flutter test`, `uvx behave`, nor the
      example suite runs on push. Raised with the owner, who decided CI is not
      needed. Every gate in this change is therefore local-only, and the
      `example/test` suite needs its own `flutter test` run from `example/`
      because the root run does not descend into it.

## 12. Close-out

- [x] 12.1 Synced the three MODIFIED `wave-rendering` requirements into
      `openspec/specs/wave-rendering/spec.md`, so the main specs no longer state
      the two things this change proved false (repaint-by-equality, and full
      uniform-mismatch degradation). Main specs validate strict.
- [ ] 12.2 Change folder retained rather than archived — archiving drops the
      folder and grounds decisions into zmem, which is a separate deliberate
      step (`/pv-archive`).
