# wave-shape

## Purpose

The geometry trait: a height field sampled at a normalized horizontal position
with a motion-supplied phase. The GPU fragment shader mirrors this exact model,
so the CPU-side `sampleAt` and the rendered surface agree — which is what lets
behaviour be proven against the real Dart computation without asserting on
shader pixels.

## Requirements

### Requirement: Height-field sampling contract

Every `WaveShape` SHALL expose `sampleAt(x, phase)` where `x` is a normalized
horizontal position in `[0, 1]` and `phase` is in radians, returning the crest
offset in amplitude units. Vertical placement SHALL be carried separately by a
`baseline` in `[0, 1]`, anchored `0` at the top and `1` at the bottom, so that
offset and placement stay independent.

#### Scenario: Sampling returns a crest offset, not an absolute position

- **WHEN** a shape is sampled at some position and phase
- **THEN** the returned value is the crest offset alone, and the shape's
  `baseline` separately supplies the normalized vertical anchor

### Requirement: Sine shape

`WaveShape.sine` SHALL produce a single clean sine surface from a required
`amplitude` and `frequency` (cycles across the full width), with `baseline`
defaulting to the vertical centre.

#### Scenario: A sine surface oscillates at its frequency

- **WHEN** a sine shape is sampled across `x` from `0` to `1`
- **THEN** the surface completes exactly `frequency` cycles and peaks at
  `amplitude`

### Requirement: Gerstner shape

`WaveShape.gerstner` SHALL produce a sharpened, ocean-like crest from an
`amplitude` and `frequency` plus a non-negative `steepness`. A `steepness` of
`0` SHALL be identical to a sine; larger values SHALL narrow the crests and
widen the troughs. A negative `steepness` SHALL be rejected at construction.

Proven by: `proof_gerstner_sharpens_crest`.

#### Scenario: Crests sharpen while troughs flatten

- **WHEN** a Gerstner surface and a sine surface of equal amplitude and
  frequency are compared across a full cycle
- **THEN** the Gerstner crest peaks like the sine but sits flatter than the
  sine between crests

#### Scenario: Zero steepness degenerates to a sine

- **WHEN** a Gerstner shape is built with `steepness` of `0`
- **THEN** its samples match the equivalent sine shape

#### Scenario: Negative steepness is rejected

- **WHEN** a Gerstner shape is constructed with a negative `steepness`
- **THEN** construction fails its assertion

### Requirement: Metaball shape

`WaveShape.metaball` SHALL produce a gooey crest from a positive `blobCount`
of evenly-spaced blobs of positive `radius`, combined by a smooth union so that
nearby blobs bridge into a single bulge peaking at `amplitude` while distant
blobs stay separate. Blob centres SHALL drift with the motion phase and SHALL
wrap around the horizontal edges. A non-positive `blobCount` or `radius` SHALL
be rejected at construction.

Proven by: `proof_metaball_blobs_merge`.

#### Scenario: Nearby blobs merge into one bulge

- **WHEN** the blob radius is large enough that adjacent blob centres overlap
- **THEN** the surface between them bridges into a single continuous crest

#### Scenario: Distant blobs stay separate

- **WHEN** the blob radius is small relative to the spacing between centres
- **THEN** the surface returns to its rest height between blobs, leaving
  distinct bulges

#### Scenario: Blob centres wrap at the edges

- **WHEN** the motion phase drifts a blob centre past the right edge
- **THEN** it re-enters from the left rather than vanishing, keeping the
  surface seamless

#### Scenario: Invalid blob parameters are rejected

- **WHEN** a metaball shape is constructed with a `blobCount` of `0` or a
  non-positive `radius`
- **THEN** construction fails its assertion
