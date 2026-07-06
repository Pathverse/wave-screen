Feature: M2 Shapes — Gerstner and metaball surfaces
  As a Flutter developer
  I want richer wave geometries beyond a plain sine
  So that surfaces can look like sharp ocean crests or gooey merging blobs.

  # Both new shapes stay in the height-field model (sampleAt), so proofs exercise
  # the real Dart computation the shader mirrors — no shader pixels asserted.

  @proof_gerstner_sharpens_crest
  Scenario: a Gerstner surface sharpens crests relative to a sine
    Given the gerstner shape journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving the Gerstner crest peaks like a sine but flattens between crests

  @proof_metaball_blobs_merge
  Scenario: metaball blobs bulge at their centers and merge as radius grows
    Given the metaball shape journey is bound to an integration proof
    When the bound integration proof is executed
    Then it passes, proving nearby blobs bridge into one gooey crest while far blobs stay separate
