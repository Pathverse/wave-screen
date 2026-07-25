Feature: Rendering output — the surface is actually visible
  As a Flutter developer
  I want a mounted wave surface to really paint its waves
  So that placing a WaveField gives me a visible background, not an empty box.

  # Asserted against captured pixels, never internals. Note this journey does
  # not pin which path rendered: the fragment program DOES load under
  # `flutter test`, so this exercises the GPU path. The CPU fallback is driven
  # deterministically at unit level instead (see wave_render_lifecycle_test).

  @proof_surface_paints_visible_waves
  Scenario: a mounted wave surface paints its wave colour
    Given the surface rendering journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving the mounted field really fills pixels with the wave's colour
