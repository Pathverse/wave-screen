# wave-screen

## Purpose

The drop-in surface: a full-bleed animated wave background composed from a
named, curated arrangement of layers, plus the gallery of ready-made
arrangements that makes it usable without tuning any traits.

## Requirements

### Requirement: Curated screen arrangement

`WaveScreenPreset` SHALL be an immutable, named arrangement bundling a list of
`Wave` layers with an optional background gradient and an optional background
colour, consumed by `WaveScreen` and produced by the preset gallery.

#### Scenario: A preset bundles layers and a background

- **WHEN** a preset is constructed with waves and a background gradient
- **THEN** it carries both, and a screen built from it renders the gradient
  behind those waves

### Requirement: Full-bleed preset screen

`WaveScreen` SHALL render a preset as a full-bleed animated background: the
preset's background colour and gradient behind a `WaveField` expanded across
the screen's constraints, with an optional `child` layered on top of the waves.

Proven by: `proof_wave_screen_preset_renders`.

#### Scenario: A preset renders across the constraints

- **WHEN** a developer mounts a `WaveScreen` with a gallery preset
- **THEN** the preset's waves render across the full extent of the screen's
  constraints and animate

#### Scenario: A child is layered above the waves

- **WHEN** a `WaveScreen` is given a child
- **THEN** the child paints in front of the wave field, with the waves visible
  behind it

#### Scenario: No child is required

- **WHEN** a `WaveScreen` is mounted without a child
- **THEN** it renders the background and waves alone

### Requirement: Inline custom screen

`WaveScreen.custom` SHALL build a screen directly from a list of waves with an
optional background gradient, background colour, and child — giving full
control without naming a preset.

#### Scenario: A developer composes a screen inline

- **WHEN** a developer calls `WaveScreen.custom` with their own waves and
  background
- **THEN** the screen renders exactly those waves over that background, with no
  gallery preset involved

### Requirement: Curated preset gallery

`WavePresets` SHALL expose a broad library of named `WaveScreenPreset`s
spanning every wave shape and the interactive ripple effect. Every preset SHALL
be reachable by a unique name, and the gallery SHALL additionally expose its
presets as an ordered list and as a list of names.

Proven by: `proof_preset_gallery_is_valid`.

#### Scenario: Every preset is renderable

- **WHEN** each preset in the gallery is mounted in a `WaveScreen`
- **THEN** every one renders without error and carries at least one wave layer

#### Scenario: Names are unique and resolve

- **WHEN** the gallery's names are enumerated
- **THEN** each name is unique and resolves by lookup to the matching preset

#### Scenario: The gallery spans the shape catalogue

- **WHEN** the gallery's presets are surveyed
- **THEN** sine, Gerstner, and metaball shapes are each represented, and at
  least one preset carries a pointer ripple effect
