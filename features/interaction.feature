Feature: M3 Interaction — ping-pong motion and pointer ripples
  As a Flutter developer
  I want oscillating motion and pointer-driven ripples
  So that wave surfaces feel alive and respond to touch.

  # Motion and ripple math stay pure functions (computed-model proofs). The
  # pointer wiring is proven at the widget layer via an observable callback.

  @proof_pingpong_reverses
  Scenario: ping-pong motion eases forward then back
    Given the pingpong motion journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving the phase oscillates through zero and reverses sign over a period

  @proof_ripple_decays_and_propagates
  Scenario: a pointer ripple propagates outward and decays
    Given the ripple effect journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving the ripple peaks at its wavefront, moves outward with age, and fades away

  @proof_pointer_spawns_ripple
  Scenario: tapping and dragging a field spawns ripples at the pointer
    Given the pointer ripple journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving a tap and a drag each emit ripples at the normalized pointer position
