Feature: M1 Foundation — composable shader-driven waves
  As a Flutter developer
  I want to compose a Wave from swappable traits and render it on the GPU
  So that I can place configurable animated wave surfaces and screens.

  # Proof contract (M1): each scenario is bound to a real `flutter test` that
  # mounts the actual widgets and/or exercises the real Wave height-field
  # computation and asserts on observed outcomes. No shader pixels are asserted.

  @proof_wave_field_renders_and_animates
  Scenario: a developer places a WaveField and it fills its box and animates
    Given the wave field journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving the WaveField fills its constraints and animates over time

  @proof_wave_traits_drive_surface
  Scenario: shape and motion traits determine the wave surface over time
    Given the wave traits journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving a drifting wave's surface changes while a still wave's holds

  @proof_wave_screen_preset_renders
  Scenario: a developer uses a preset and gets a full-bleed animated screen
    Given the wave screen preset journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving WaveScreen renders the preset's waves across its constraints
