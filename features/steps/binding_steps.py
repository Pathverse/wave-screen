"""Conformance steps proving the scenario<->proof binding is a bijection.

This is the static half of Gate C (binding integrity). Scanning tags is correct
HERE because this is the conformance tier, not the executable behavior loop:
- every `@proof_<id>` scenario resolves to exactly one `proof_<id>`-tagged Dart
  test,
- every such Dart test is claimed by exactly one scenario,
- no proof id is duplicated on either side.
"""

import re
from pathlib import Path

from behave import given, when, then

PACKAGE_ROOT = Path(__file__).resolve().parents[2]
FEATURES_DIR = PACKAGE_ROOT / "features"
TEST_DIR = PACKAGE_ROOT / "test"

_FEATURE_TAG = re.compile(r"@(proof_[A-Za-z0-9_]+)")
_DART_TAG = re.compile(r"@Tags\(\[\s*'(proof_[A-Za-z0-9_]+)'\s*\]\)")


def _scan(paths, pattern):
    ids = []
    for path in paths:
        text = path.read_text(encoding="utf-8")
        ids.extend(pattern.findall(text))
    return ids


@given('the feature suite and the Flutter proof tests')
def step_collect(context):
    context.feature_ids = _scan(FEATURES_DIR.rglob("*.feature"), _FEATURE_TAG)
    context.dart_ids = (
        _scan(TEST_DIR.rglob("*.dart"), _DART_TAG) if TEST_DIR.exists() else []
    )


@when('the proof bindings are cross-checked')
def step_cross_check(context):
    context.feature_set = set(context.feature_ids)
    context.dart_set = set(context.dart_ids)


@then('every scenario proof id resolves to exactly one tagged Flutter test')
def step_scenarios_resolve(context):
    dupes = [i for i in context.feature_set if context.feature_ids.count(i) > 1]
    assert not dupes, f"duplicate proof ids across scenarios: {sorted(dupes)}"
    orphans = sorted(context.feature_set - context.dart_set)
    assert not orphans, f"scenarios bound to missing Flutter proofs: {orphans}"


@then('every tagged Flutter test is claimed by exactly one scenario')
def step_tests_claimed(context):
    dupes = [i for i in context.dart_set if context.dart_ids.count(i) > 1]
    assert not dupes, f"duplicate proof tags across Dart tests: {sorted(dupes)}"
    unclaimed = sorted(context.dart_set - context.feature_set)
    assert not unclaimed, f"Flutter proofs not claimed by any scenario: {unclaimed}"
