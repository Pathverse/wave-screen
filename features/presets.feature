Feature: M4 Presets — a curated gallery
  As a Flutter developer
  I want a broad library of ready-made wave presets
  So that I can drop in a polished animated background without tuning traits.

  @proof_preset_gallery_is_valid
  Scenario: the preset gallery exposes many valid, uniquely named presets
    Given the preset gallery journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving every gallery preset is renderable and reachable by a unique name
