# Design

## Context

See proposal.md for motivation. Uniform colors are straight RGBA. The CPU painter uses Flutter source-over blending. Shader requests currently publish an attempted flag before asset loading finishes. Ripple displacement already suppresses negative amplitudes, but lifetime takes their logarithm.

## Goals / Non-Goals

Goals are consistent premultiplied output, defined envelope arithmetic, and shared asynchronous loading. Public constructors remain usable with negative strength, whose existing displacement is zero.

Capacity and interaction policy are outside this change.

## Decisions

- Convert each shader layer to premultiplied RGBA after multiplying opacity by coverage, then apply source-over. Changing uniform encoding would require coordinating packer changes unnecessarily.
- Replace the ripple square with multiplication and apply the same negligible-amplitude cutoff as Dart. Preserve the existing useful-strength lifetime formula, with a zero-lifetime guard before logarithms for strengths at or below the threshold. Rejecting negative strength would alter construction behavior.
- Cache one Future of the asset-key loading loop. Concurrent callers await it and completed failures remain cached. Retrying failures conflicts with the established asset resolution requirement.
- Extend the existing compiled-shader contract testing approach required by the rendering spec. The broad config wording against shader pixel assertions conflicts with that specific existing requirement, so use targeted contract checks with numeric tolerances. Behavior proofs receive feature tags. Loader concurrency is tested in a fresh test file before other shader requests.

## Risks / Trade-offs

- Backend optimizers may already turn pow into multiplication. The regression still checks real rendering and the source fix removes undefined arithmetic across backends.
- Rasterization introduces quantization. Compare fully covered premultiplied pixels and crest positions with explicit tolerances.
- This bounded change handles finite negative and negligible strengths. General non-finite input validation remains a separate API policy.

## Migration Plan

Ship as a correctness fix with the bundled shader rebuilt by Flutter. No data migration is needed. Reverting the implementation and associated contracts restores the previous behavior.
