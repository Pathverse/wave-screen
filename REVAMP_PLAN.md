# wave_screen — Revamp Plan (v0.1.0, breaking)

> Durable decision record for the complete revamp of `wave_screen`.
> Reference (old): `../wave-screen`. New implementation: this repo (`wave-screen-2`).
> Built under Pathverse **flow-v1b** governance. This document is the pre-Phase-1
> scope lock; it is the source of truth for reconstructing the decisions below.

## Governance

- Constitution: pathverse-agent-governance `docs/constitution.md` (factors 2,3,7,8,10,12).
- Flow: `CLARIFY (BDD) → IMPLEMENT (TDD) → STRUCTURE → COVERAGE → COMMIT (zmem)`.
- Stack: `dart-flutter` (skills: `good-bdd-dart-flutter`, `good-tdd-dart-flutter`).
- Behavior is proven by behave scenarios bound to Flutter integration proofs
  (`@proof:<id>` ↔ `proof_<id>`-tagged tests), never by inspecting source text.

## Locked decisions (from scope-lock Q&A)

1. **Rendering engine:** GPU **fragment shader** (`FragmentProgram`). The shader
   receives uniforms (time, resolution, per-layer shape params, pointer) and
   evaluates a per-pixel height field → SDF fill. Metaball/gooey and Gerstner are
   natural fits; pointer ripple = extra uniforms.
2. **Public API model:** maximum granularity — a **`Wave` is an object composed of
   swappable traits**: `WaveShape` (geometry), `WaveStyle` (appearance),
   `WaveMotion` (time evolution), `List<WaveEffect>` (interaction/decoration).
3. **Compatibility:** clean-slate, breaking. No back-compat with old API.
4. **Module scope:** `Wave` + `WaveScreen` revamped. **`WaveSkeletonizer` REMOVED**
   (no adoption) — delete `lib/src/skeletonizer/*`, its export, the `skeletonizer`
   dependency, and its example pages/tests.
5. **New visual capabilities (all in scope):** expanded named preset library,
   gooey/metaball waves, pointer-interactive ripples, Gerstner/realistic ocean.
6. **Naming vocabulary (confirmed):** `Wave`, `WaveShape`, `WaveStyle`,
   `WaveMotion`, `WaveEffect`, `WaveField`, `WaveScreen`.
7. **Execution:** milestone-by-milestone. Each milestone passes the FULL governance
   gate (scenarios → TDD → structure → coverage → zmem commit) and stops for review
   before the next.
8. **Example requirement:** every milestone **appends a full showcase** to the
   example app (cumulative, never replacing prior showcases) demonstrating that
   milestone's capabilities running live. This is a per-milestone exit criterion.

## Target public API (illustrative)

```dart
class Wave {
  final WaveShape  shape;
  final WaveStyle  style;
  final WaveMotion motion;
  final List<WaveEffect> effects;
}

// SHAPE — height-field generator fed to the shader
WaveShape.sine({layers, amplitude, frequency, ...});     // current-style look
WaveShape.gerstner({steepness, wavelength, ...});        // realistic ocean (M2)
WaveShape.metaball({blobs, radius, gooeyness, ...});     // gooey/fluid (M2)

// STYLE — pure appearance
WaveStyle({fill: Color|Gradient, stroke?, blur?, crestHighlight?, opacity});

// MOTION — time evolution
WaveMotion.drift({speed, direction});
WaveMotion.pingPong({period, pause});
WaveMotion.still();

// EFFECTS — composable overlays (M3)
PointerRippleEffect({strength, decay});
FoamEffect({...});

// Widgets
WaveField(waves: [Wave(...), ...]);                      // composites via shader
WaveScreen(preset: WavePresets.lagoon);                  // curated arrangement
WaveScreen(background: ..., waves: [Wave(...), ...]);    // full control
```

## Proposed module structure

```
lib/wave_screen.dart          → public exports (Wave, traits, WaveField, WaveScreen, presets)
lib/src/wave/                 → Wave object + trait types + WaveField widget
lib/src/wave/shader/          → .frag source + FragmentProgram loader/uniform packing
lib/src/screen/               → WaveScreen widget + WavePresets
shaders/                      → compiled shader assets (pubspec `flutter: shaders:`)
```

## Milestones

Each milestone = full governance flow + appended example showcase + zmem commit.

- **M1 Foundation** — shader core + trait model (`Wave`, `WaveShape.sine`,
  `WaveStyle`, `WaveMotion.drift`/`still`), `WaveField`, `WaveScreen` with a few
  presets. Reaches parity with today's Wave/WaveScreen, on GPU. Remove the
  skeletonizer module + dependency. Example: append a "Foundation" showcase page.
- **M2 Shapes** — add `WaveShape.gerstner` + `WaveShape.metaball` (gooey).
  Example: append a "Shapes" showcase.
- **M3 Interaction** — pointer ripple + `WaveEffect` system + `WaveMotion.pingPong`.
  Example: append an "Interaction" showcase.
- **M4 Presets & release** — expanded `WavePresets` library, docs, README/CHANGELOG,
  publish prep. Example: append a "Preset Gallery" showcase.

## Open implementation risks (resolved during build, not now)

- Uniform-count vs. layer-count limits → may need multi-pass draws or texture-packed
  params. Decided in M1 IMPLEMENT.
- Fragment-shader availability/fallback on all targets (web/Impeller vs others) →
  confirm during M1; the reference already disabled blur on web, so web parity is a
  known sensitivity.
- behave→Flutter proof harness bring-up (no `.zmem`/behave scaffold exists yet) →
  established in M1 CLARIFY.
