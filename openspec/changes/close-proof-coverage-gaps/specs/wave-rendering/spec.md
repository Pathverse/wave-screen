## MODIFIED Requirements

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
