# wave-composition

## Purpose

The trait-composition model at the centre of `wave_screen`: a `Wave` is an
immutable object assembled from swappable traits — geometry (`WaveShape`),
appearance (`WaveStyle`), time evolution (`WaveMotion`), and composable
overlays (`WaveEffect`). Each trait is independently replaceable, so the same
geometry can be restyled, re-timed, or made interactive without touching the
others.

## Requirements

### Requirement: Trait-composed wave object

A `Wave` SHALL be an immutable value composed of exactly four trait slots:
a required `shape`, `style`, and `motion`, plus a `effects` list that defaults
to empty. Replacing one trait SHALL leave the remaining traits unchanged.

#### Scenario: Composing a wave from traits

- **WHEN** a developer constructs a `Wave` with a shape, style, and motion and
  supplies no effects
- **THEN** the wave carries those three traits and an empty effect list

#### Scenario: Swapping a single trait

- **WHEN** a developer builds a second wave that differs only in its `style`
- **THEN** the shape and motion of the two waves remain equal, and only the
  appearance differs

### Requirement: Composed surface height

A `Wave` SHALL expose `heightAt(x, t)` returning the surface height at
normalized horizontal position `x` in `[0, 1]` and time `t` in seconds,
defined as its `shape` sampled with the phase its `motion` supplies at `t`.
This composition is what makes geometry and time evolution independent traits.

Proven by: `proof_wave_traits_drive_surface`.

#### Scenario: A drifting wave's surface evolves

- **WHEN** a wave carrying a drifting motion is sampled at the same position at
  two different times
- **THEN** the two heights differ, proving motion advances the shape's phase

#### Scenario: A still wave's surface holds

- **WHEN** a wave carrying still motion is sampled at the same position at two
  different times
- **THEN** the two heights are identical

### Requirement: Value equality across the trait model

`Wave` and every trait type SHALL implement structural value equality and a
matching `hashCode`, with the effect list compared element-wise. Widgets rely
on this to decide whether a rebuild changes the rendered surface.

#### Scenario: Structurally identical waves compare equal

- **WHEN** two separately constructed waves carry equal shape, style, motion,
  and effects
- **THEN** they compare equal and produce the same hash code

#### Scenario: A differing effect list breaks equality

- **WHEN** two waves are identical except that one carries an extra effect
- **THEN** they do not compare equal

### Requirement: Appearance trait

`WaveStyle` SHALL describe appearance alone, as a solid `fill` colour and an
`opacity` multiplier constrained to `[0, 1]`, and SHALL expose a resolved
colour with that opacity folded into the fill's alpha channel. An opacity
outside `[0, 1]` SHALL be rejected at construction.

#### Scenario: Opacity folds into the resolved colour

- **WHEN** a style is built with a fully opaque fill and an opacity of `0.5`
- **THEN** the resolved colour carries half the fill's alpha and the same
  colour channels

#### Scenario: Out-of-range opacity is rejected

- **WHEN** a style is constructed with an opacity outside `[0, 1]`
- **THEN** construction fails its assertion rather than producing an invalid
  style

### Requirement: Effect trait base

`WaveEffect` SHALL be an immutable base type that a `Wave` can carry in its
effect list, so that interaction and decoration overlays compose onto a wave
without altering its shape, style, or motion traits.

#### Scenario: A wave carries effects without changing its other traits

- **WHEN** a developer adds an effect to an existing wave's effect list
- **THEN** the wave's shape, style, and motion are unchanged, and its composed
  height still derives from shape and motion alone
