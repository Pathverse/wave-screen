## Context

The repo already carries a working proof harness: behave scenarios each declare
one `@proof_<id>` tag, `features/steps/proof_steps.py` shells out to
`flutter test --tags proof_<id>` and inherits its verdict, and
`features/system/binding_integrity.feature` asserts a bijection between scenario
proof ids and tagged Dart tests. This change adds coverage inside that harness
rather than changing it.

## Goals / Non-Goals

**Goals**
- Every spec requirement is backed by either a bound journey proof or a unit test.
- Every `assert` in the public API has a test that fails if it is deleted.
- The never-blank rendering guarantee is asserted against real painted pixels.

**Non-Goals**
- No production behaviour change. If a test cannot pass without editing `lib/`,
  the test is wrong or the spec is wrong — not the implementation.
- No new capability, no new public API.
- No attempt to execute the GPU shader path in CI.

## Decisions

### Journey altitude, not unit mirroring

The `good-bdd` dart-flutter fragment is explicit that a behave scenario is one
coarse user journey sitting above N unit tests, and that mirroring unit tests as
scenarios is the redundancy the outer/inner split exists to avoid. So only three
new behave journeys are added — each a user-visible outcome:

| Journey | Proof id |
|---|---|
| a mounted surface really paints its wave colour | `proof_surface_paints_visible_waves` |
| a field with no ripple effect ignores pointers | `proof_quiet_field_ignores_pointers` |
| a screen layers its child above the waves | `proof_screen_layers_child_above_waves` |

Everything else — assertion guards, equality, math edges, `shouldRepaint`,
disposal, clamping, catalogue spread — is inner-loop unit work.

### Fail-first under retrospective coverage

The core rule is "no production code without a failing test first". This change
writes **no production code**: the behaviour shipped in 0.1.0. Classic RED (test
fails because behaviour is absent) therefore does not apply to the unit work, and
claiming otherwise would be dishonest.

Two disciplines replace it:

1. **Genuine RED for the journeys.** Each scenario is written and run *before*
   its proof exists. `flutter test --tags <unknown>` exits 79 ("No tests match"),
   so the scenario fails for a real, observed reason before the proof is written.
   This is the binding's own teeth, not a simulated red.
2. **Mutation checks for the unit tests.** A test of existing behaviour passes on
   first run, which the baseline flags as suspect. Each non-obvious new unit test
   is therefore verified by temporarily breaking the behaviour it covers and
   confirming the test goes red, then restoring. This proves the test is not
   vacuous — the property first-run-red would otherwise have proven.

### Proving rendering against pixels

Asserting that rendering happened requires observing output, not internals. The
journey proof mounts a field inside a keyed `RepaintBoundary`, captures it with
`toImage()` under `tester.runAsync`, and scans the raw RGBA for the wave's fill
colour.

**Corrected mid-implementation.** This was first written on the assumption that
`flutter test` does not load the fragment program, so a widget-level capture
would exercise the CPU fallback. That assumption is false: a probe confirmed
`ui.FragmentProgram.fromAsset` succeeds under `flutter test`, and a mutation that
reversed the CPU fallback's paint order was **not** caught by the widget-level
test — proving it was measuring the GPU path all along.

The split that replaces it:

- **Journey proof** (`proof_surface_paints_visible_waves`) pins the user-visible
  outcome only — a mounted field really fills pixels with its wave colour rather
  than leaving an empty box. It deliberately does not claim which path rendered.
- **Unit test** drives `WaveFieldPainter` with `shader: null` onto a
  `PictureRecorder`, which is the only deterministic way to reach the fallback.
  It asserts both never-blank (every wave's colour present) and paint order.

The mutation that survived the first version is killed by the second, which is
the evidence that the rewrite fixed a real hole rather than relabelling it.

### Restating the unverifiable scenario

"The field paints a shader-filled rect rather than per-layer CPU paths" cannot be
observed in a headless suite. It is replaced by the uniform-layout contract,
which is what actually guards GPU correctness and is already checkable — the
existing `wave_uniforms_test.dart` asserts the packed vector against
`WaveUniforms.floatCount` and per-block offsets. The requirement's intent is
unchanged; only its evidence becomes real.

## Risks / Trade-offs

- **A stale-shader uniform mismatch stays unproven.** Forcing that failure needs
  a second, deliberately mismatched `.frag` asset, which would ship inside the
  published package. The owner chose to leave this open rather than ship a dead
  asset; the fallback's other trigger (no shader at all) is covered.
- **Gates are local-only.** The repo has no CI test workflow — only an example
  Pages deploy — so nothing here runs on push. Noted for a follow-up change.
- **The example suite needs its own invocation.** `flutter test` from the repo
  root does not descend into `example/`, so the asset-key proof must be run from
  `example/`. A CI workflow would need both.

### Second pass — reaching the shader itself

The first pass recorded "the GPU path stays unexecuted in CI" as an accepted
limitation. That was wrong, and the mutation work disproved it: the fragment
program loads under `flutter test`, and a shader-drawn rect rasterizes through
`PictureRecorder.toImage`, so GPU output **is** observable. Two gaps closed as a
result:

- **The shader mirrors the Dart model.** This is the package's central claim —
  every other proof asserts against Dart `sampleAt`, so if the GLSL drifted the
  whole suite would be measuring the wrong surface. Uniforms are applied and the
  rect drawn directly (no painter, so no fallback can substitute), then the crest
  line is recovered from the alpha channel: the shader's
  `smoothstep(crest - aa, crest + aa, uv.y)` crosses 50% exactly at the crest, so
  the first row with alpha ≥ 128 gives the rendered crest to sub-pixel accuracy.
  Compared against `Wave.heightAt` at seven columns, for sine, Gerstner, and
  metaball. Inverting the GLSL crest composition fails all three.
- **Package-prefixed asset resolution.** Provable from the *consuming* side:
  `example/` depends on the package by path, and its bundle carries the shader
  under the prefixed key only. The test asserts the bare key does not resolve
  there, which makes the prefixed key demonstrably the one doing the work.
- **Pixel scanning can be brittle.** Mitigated by asserting "some pixel carries
  the fill colour" rather than a golden image, so it is robust to antialiasing
  and layout shifts.
- **Mutation checks are manual.** They are performed and reported per test, not
  automated; a future change could adopt a mutation runner.
