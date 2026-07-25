# wave-motion

## Purpose

The time-evolution trait. A motion contributes a *phase* in radians for a given
time in seconds; the shape turns that phase into a height. Keeping phase and
geometry separate is what makes time evolution swappable — any motion can drive
any shape.

## Requirements

### Requirement: Phase contract

Every `WaveMotion` SHALL expose `phaseAt(t)` returning a phase in radians for a
time `t` in seconds, and SHALL contribute nothing to the surface beyond that
phase. Motions SHALL be immutable values with structural equality.

#### Scenario: Motion influences the surface only through phase

- **WHEN** the same shape is driven by two different motions at times that
  yield the same phase
- **THEN** both produce the same surface height

### Requirement: Drift motion

`WaveMotion.drift` SHALL advance phase linearly with time at `speed` radians
per second, producing an endlessly travelling wave.

#### Scenario: Phase advances linearly

- **WHEN** a drift motion is sampled at increasing times
- **THEN** the phase increases in proportion to elapsed time and `speed`

### Requirement: Still motion

`WaveMotion.still` SHALL hold phase at zero for all times, freezing the surface
in place.

#### Scenario: Phase never advances

- **WHEN** a still motion is sampled at any two times
- **THEN** both return a phase of zero

### Requirement: Ping-pong motion

`WaveMotion.pingPong` SHALL oscillate phase smoothly between `-sway` and
`+sway` once per `period` seconds, easing forward and then back. A non-positive
`period` SHALL be rejected at construction.

Proven by: `proof_pingpong_reverses`.

#### Scenario: Phase oscillates and reverses sign

- **WHEN** a ping-pong motion is sampled across a full period
- **THEN** the phase passes through zero and reverses sign, reaching both
  `+sway` and `-sway`

#### Scenario: Motion is periodic

- **WHEN** a ping-pong motion is sampled at a time and again one full `period`
  later
- **THEN** both samples return the same phase

#### Scenario: Non-positive period is rejected

- **WHEN** a ping-pong motion is constructed with a `period` of `0` or less
- **THEN** construction fails its assertion
