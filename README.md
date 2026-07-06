# wave_screen

[![Deploy Example To GitHub Pages](https://github.com/Pathverse/wave-screen/actions/workflows/deploy-example-pages.yml/badge.svg)](https://github.com/Pathverse/wave-screen/actions/workflows/deploy-example-pages.yml)

`wave_screen` renders **composable, GPU-shader-driven animated wave surfaces** for
Flutter. A `Wave` is built from swappable traits — a **shape** (geometry), a
**style** (appearance), a **motion** (time evolution), and optional **effects**
(interaction) — and composited on the GPU via a fragment shader (with a CPU
fallback so it never blanks).

## Install

```yaml
dependencies:
  wave_screen: ^0.1.0
```

## Quick start

Drop in a curated preset as a full-bleed background:

```dart
import 'package:wave_screen/wave_screen.dart';

WaveScreen(preset: WavePresets.ocean);
```

Or compose a field from raw traits:

```dart
WaveField(
  waves: [
    Wave(
      shape: WaveShape.gerstner(amplitude: 0.06, frequency: 1.0, steepness: 1.1),
      style: const WaveStyle(fill: Color(0xFF2384A0)),
      motion: WaveMotion.drift(speed: 0.3),
    ),
    Wave(
      shape: WaveShape.metaball(blobCount: 4, radius: 0.2, amplitude: 0.12),
      style: const WaveStyle(fill: Color(0xFF57C4D6)),
      motion: WaveMotion.pingPong(sway: 1.2, period: 6),
    ),
  ],
);
```

## The trait model

| Trait | Options |
|---|---|
| `WaveShape` | `.sine(amplitude, frequency, baseline)` · `.gerstner(…, steepness)` (sharpened ocean crests) · `.metaball(blobCount, radius, amplitude)` (gooey merging blobs) |
| `WaveStyle` | `WaveStyle(fill: Color, opacity)` |
| `WaveMotion` | `.drift(speed)` · `.pingPong(sway, period)` (smooth back-and-forth) · `.still()` |
| `WaveEffect` | `PointerRippleEffect(strength, decay, speed, wavelength)` |

Every shape is a pure height field: `shape.sampleAt(x, phase)` (and
`wave.heightAt(x, t)`) returns the exact value the shader renders, so behavior is
testable without a GPU.

## Interaction

Give any wave a `PointerRippleEffect` and its enclosing `WaveField` becomes
interactive — taps and drags send ripples across the surface:

```dart
WaveField(
  waves: [
    Wave(
      shape: WaveShape.sine(amplitude: 0.05, frequency: 0.9),
      style: const WaveStyle(fill: Color(0xFF1C6E8C)),
      motion: WaveMotion.drift(speed: 0.25),
      effects: const [PointerRippleEffect()],
    ),
  ],
  onRipple: (normalizedPosition) { /* optional */ },
);
```

## Presets

`WavePresets` ships a broad curated gallery — sine, Gerstner and metaball themes
plus interactive presets. Access them by name:

```dart
WaveScreen(preset: WavePresets.byName['tidepool']!);

for (final preset in WavePresets.all) { /* … */ }
```

Themes include `aurora`, `violet`, `dusk`, `sunset`, `neon`, `mist`, `abyss`,
`ocean`, `lagoon`, `ember`, `jelly`, `lava`, `tidepool`, and `pulse`.

## Rendering

Waves render on the GPU through `shaders/wave.frag`. If the shader cannot be
loaded (some platforms, or a stale build) the widget transparently falls back to
an equivalent CPU painter, so the surface always shows.

## Run the example

```bash
cd example
flutter pub get
flutter run -d chrome
```

The example is a gallery of the milestones: **Foundation**, **Shapes**,
**Interaction**, and the full **Preset Gallery**.

## License

Apache-2.0. See [LICENSE](LICENSE).
