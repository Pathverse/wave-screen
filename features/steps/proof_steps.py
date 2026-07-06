"""Generic behave steps that bind a scenario to a Flutter integration proof.

behave (Python) cannot drive the Flutter app in-process, so the real system is
reached by executing a bound `flutter test --tags proof_<id>` and inheriting its
verdict. No Dart source is inspected here: the `@proof_<id>` tag on the scenario
is the single source of truth for the binding.
"""

import shutil
import subprocess
from pathlib import Path

from behave import given, when, then

# features/steps/proof_steps.py -> parents[2] == repo root (the Flutter package).
PACKAGE_ROOT = Path(__file__).resolve().parents[2]


def _flutter_executable():
    # Resolve the real launcher (flutter.bat on Windows) so subprocess can find
    # it without a shell — a bare "flutter" raises FileNotFoundError on Windows.
    resolved = shutil.which("flutter")
    assert resolved, "flutter not found on PATH — required for verify-mode"
    return resolved


def _proof_tag(context):
    tags = [t for t in context.scenario.tags if t.startswith("proof_")]
    assert len(tags) == 1, (
        f"scenario must carry exactly one @proof_<id> tag, found {tags or 'none'}"
    )
    return tags[0]


@given('the {journey} is bound to an integration proof')
def step_bound(context, journey):
    # Binding must be declared: resolve (and validate) the proof tag now.
    context.proof_tag = _proof_tag(context)


@when('the bound integration proof is executed')
def step_execute(context):
    context.result = subprocess.run(
        [_flutter_executable(), "test", "--tags", context.proof_tag],
        cwd=str(PACKAGE_ROOT),
        capture_output=True,
        text=True,
    )


@then('it passes, proving {claim}')
def step_passes(context, claim):
    result = context.result
    assert result.returncode == 0, (
        f"bound proof '{context.proof_tag}' failed (exit {result.returncode}) "
        f"while proving: {claim}\n{result.stdout}\n{result.stderr}"
    )
