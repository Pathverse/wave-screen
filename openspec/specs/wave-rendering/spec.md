# wave-rendering

## Purpose

Compositing composed `Wave` layers into a single live animated surface.
Rendering is GPU-first through a bundled fragment shader that mirrors the
CPU height-field model, with a CPU path that guarantees the surface never
blanks — on a missing shader asset, an unsupported target, or a stale
compiled shader whose uniform layout no longer matches.

## Requirements

### Requirement: Layered wave field

`WaveField` SHALL composite a list of `Wave` layers into one animated surface,
filling the constraints it is given and repainting continuously from a ticker
clock measured in seconds.

Proven by: `proof_wave_field_renders_and_animates`.

#### Scenario: The field fills its constraints and animates

- **WHEN** a `WaveField` carrying a drifting wave is mounted inside a fixed-size
  box
- **THEN** it occupies exactly that box and reports a running animation

#### Scenario: Layers paint in order

- **WHEN** a field is given several waves
- **THEN** each is painted in list order, so later layers appear in front of
  earlier ones

### Requirement: GPU-first rendering

`WaveField` SHALL render through the bundled wave fragment shader when it is
available, driving it with uniforms for size, time, per-layer parameters, and
active ripples. The uniform vector the package writes SHALL match the layout the
shader declares, so that the GPU path cannot silently drift out of sync with the
CPU model it mirrors.

#### Scenario: The written uniform vector matches the shader's declared layout

- **WHEN** uniforms are packed for a field mixing sine, Gerstner, and metaball
  layers together with live ripples
- **THEN** the packed vector's length equals the shader's declared float count,
  and size, layer count, per-layer shape type, and ripple origin each land at
  the offset the shader reads them from

#### Scenario: An empty field still fills the whole vector

- **WHEN** uniforms are packed for a field with no waves and no ripples
- **THEN** the packed vector is still the full declared length and reports a
  layer count of zero

#### Scenario: The rendered surface matches the Dart model

- **WHEN** the full uniform vector is applied to the real compiled shader and
  the surface is drawn through it
- **THEN** the rendered crest line matches `Wave.heightAt` across the width for
  sine, Gerstner, and metaball shapes alike

### Requirement: Shader asset resolution

The fragment program SHALL be loaded at most once per process and cached, and
SHALL be resolved by trying the package-prefixed asset key first and the bare
key second, so the shader works both inside this package's own tooling and in a
dependent application.

#### Scenario: A dependent app resolves the package-prefixed key

- **WHEN** the package is consumed as a dependency
- **THEN** the shader loads from the package-prefixed asset key

#### Scenario: Loading is attempted only once

- **WHEN** several fields mount and request the shader
- **THEN** the program is loaded a single time and the cached result is reused,
  including after a failed attempt

### Requirement: Never-blank CPU fallback

Rendering SHALL degrade to a CPU-sampled path — rather than blanking or
throwing — whenever the shader is unavailable or a uniform write raises an
error. A shader load failure SHALL be non-fatal, and a uniform write that
overruns the shader's declared layout SHALL be caught and turned into a fallback
paint rather than propagating on every frame.

A shader declaring **more** uniforms than the package writes SHALL NOT be
expected to degrade. Every write stays in range, so no error is raised, and the
shader's declared uniform count is private to `dart:ui` — the package has no way
to detect that direction at runtime. It is guarded at build time instead, by the
contract test that applies the full uniform vector to the real compiled shader
and compares the rendered crest against the Dart model.

#### Scenario: A missing shader still renders

- **WHEN** the fragment program fails to load on the running target
- **THEN** the field paints its layers through the CPU path and the surface
  remains visible and animated

#### Scenario: An overrunning uniform write degrades instead of crash-flooding

- **WHEN** writing the uniform vector overruns the compiled shader's declared
  layout and raises an error
- **THEN** that frame falls back to the CPU path instead of propagating the
  error

#### Scenario: A larger shader layout is not runtime-detectable

- **WHEN** the compiled shader declares more uniforms than the package writes
- **THEN** no error is raised and no fallback occurs; the mismatch is caught by
  the build-time contract test rather than by runtime degradation

#### Scenario: The fallback honours the same model

- **WHEN** the CPU path paints a wave
- **THEN** each sampled crest is placed at the shape's baseline offset by the
  wave's composed height plus any ripple displacement, filled with the style's
  resolved colour

### Requirement: Render resource lifecycle

`WaveField` SHALL release its ticker, clock, and fragment shader when disposed.
The painter SHALL skip repainting only when handed back the very same waves,
shader, and ripple field — these are compared by identity, so a rebuild that
constructs a fresh wave list repaints even when the waves it contains are equal.

#### Scenario: Disposal releases resources

- **WHEN** a mounted `WaveField` is removed from the tree
- **THEN** its ticker, clock notifier, and shader are disposed, and no animation
  is left running

#### Scenario: The same inputs do not force a repaint

- **WHEN** the painter is handed back the identical wave list, shader, and
  ripple field instances
- **THEN** it reports that no repaint is required

#### Scenario: An equal but distinct wave list still repaints

- **WHEN** a rebuild supplies a newly constructed wave list whose waves compare
  equal to the previous ones
- **THEN** the painter still reports a repaint, because wave lists are compared
  by identity rather than element equality
