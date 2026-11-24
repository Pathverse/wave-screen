# wave-interaction

## Purpose

Pointer-driven interaction layered onto a wave surface as a composable effect.
A `PointerRippleEffect` placed in a wave's effect list makes the enclosing
`WaveField` interactive: taps and drags radiate ripples that displace the
surface and fade. Displacement is a pure function of position and age, so the
CPU path, the GPU path, and tests all agree on the same values.

## Requirements

### Requirement: Pointer ripple displacement

`PointerRippleEffect` SHALL compute displacement as a pure function of a
normalized position, the ripple's normalized origin, and its age in seconds,
parameterised by `strength` (peak displacement at impact), `decay` (amplitude
decay per second), `speed` (outward propagation in normalized x per second),
and `wavelength` (spatial extent). A non-positive `decay` or `wavelength` SHALL
be rejected at construction.

Proven by: `proof_ripple_decays_and_propagates`.

#### Scenario: The ripple peaks at its wavefront

- **WHEN** a ripple is sampled across positions at a fixed age
- **THEN** the displacement peaks at the wavefront and falls away on either
  side of it

#### Scenario: The wavefront travels outward

- **WHEN** the same ripple is sampled at increasing ages
- **THEN** the position of its peak moves outward from the origin in proportion
  to `speed`

#### Scenario: The ripple fades

- **WHEN** a ripple's age grows large
- **THEN** its displacement decays toward zero and is reported as negligible

#### Scenario: Invalid ripple parameters are rejected

- **WHEN** a ripple effect is constructed with a non-positive `decay` or
  `wavelength`
- **THEN** construction fails its assertion

### Requirement: Interactivity is opt-in through the effect list

A `WaveField` SHALL become pointer-interactive if and only if at least one of
its waves carries a `PointerRippleEffect`. A field with no such effect SHALL
not intercept pointer events. The field SHALL re-evaluate this when its wave
list changes.

#### Scenario: A field without ripple effects ignores pointers

- **WHEN** a field is built from waves that carry no `PointerRippleEffect`
- **THEN** it installs no pointer listener and taps pass through it

#### Scenario: Swapping in a rippled wave enables interaction

- **WHEN** a mounted field is rebuilt with a wave list that now carries a
  `PointerRippleEffect`
- **THEN** the field rebuilds its ripple state and begins responding to
  pointers

### Requirement: Pointer-driven ripple spawning

An interactive `WaveField` SHALL spawn a ripple on pointer down and on pointer
move, at the pointer position normalized against the field's size and clamped
to `[0, 1]` on both axes, and SHALL report that normalized position through an
optional `onRipple` callback. No ripple SHALL be spawned when the field has an
empty size.

Proven by: `proof_pointer_spawns_ripple`.

#### Scenario: A tap emits a ripple at the pointer

- **WHEN** a developer taps an interactive field
- **THEN** a ripple is spawned at the normalized tap position and reported
  through `onRipple`

#### Scenario: A drag emits ripples along its path

- **WHEN** a developer drags across an interactive field
- **THEN** each pointer movement emits a ripple at its normalized position

#### Scenario: Positions outside the field are clamped

- **WHEN** a pointer position falls outside the field's bounds
- **THEN** the reported normalized position is clamped into `[0, 1]`

### Requirement: Live ripple accumulation and pruning

Live ripples SHALL accumulate so that their displacements sum at any sampled
position, and SHALL be dropped once their age exceeds the effect's lifetime —
the point at which amplitude has decayed below usefulness — so that sustained
interaction does not grow the field without bound.

#### Scenario: Overlapping ripples sum

- **WHEN** two ripples are live at once
- **THEN** the displacement at a position is the sum of both contributions

#### Scenario: Expired ripples are pruned

- **WHEN** the clock advances past a ripple's lifetime
- **THEN** that ripple is removed from the live set

### Requirement: Finite ripple envelope

For finite valid parameters, ripple displacement SHALL remain finite on both sides of the travelling front and agree between the Dart model and compiled shader. Amplitudes below 0.0001 SHALL contribute zero displacement.

Proven by `proof_ripple_shader_envelope`.

#### Scenario: Sampling behind the front
- **WHEN** a live ripple is sampled nearer its origin than the distance travelled by its front
- **THEN** its displacement is finite and the rendered crest matches the Dart displacement

### Requirement: Negligible ripple expiry

A ripple with finite strength at or below 0.0001 SHALL have zero lifetime and SHALL be removed when its age exceeds zero. Negative strengths SHALL contribute zero displacement.

Proven by `proof_negligible_ripple_expiry`.

#### Scenario: Negative or negligible strength
- **WHEN** a negative, zero, or negligible-strength ripple is spawned and the clock advances
- **THEN** its lifetime is zero and the live ripple is pruned
