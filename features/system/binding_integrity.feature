Feature: BDD proof binding integrity
  Every scenario proof id must map one-to-one to a bound Flutter test, so a
  scenario can never pass vacuously against a missing or duplicated proof.

  Scenario: every proof tag maps one-to-one to a bound Flutter test
    Given the feature suite and the Flutter proof tests
    When the proof bindings are cross-checked
    Then every scenario proof id resolves to exactly one tagged Flutter test
    And every tagged Flutter test is claimed by exactly one scenario
