## ADDED Requirements

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
