# Proposal

## Why

Translucent waves have incorrect shader alpha, ripple envelopes use undefined GLSL arithmetic, and concurrent fields can miss a pending shader load. Negative ripple strength also creates an infinite lifetime despite contributing no CPU displacement.

## What Changes

- Composite shader layers using premultiplied source-over.
- Square ripple envelope arguments by multiplication and mirror the Dart negligible-amplitude cutoff.
- Share the pending shader-load future and cache its completed success or failure.
- Give finite strengths at or below the useful-amplitude threshold zero lifetime.
- Add focused behavioral regressions and scenario bindings.

## Capabilities

### New Capabilities

### Modified Capabilities

- `wave-rendering` gains explicit translucent compositing and concurrent load guarantees.
- `wave-interaction` defines negligible-strength expiry and finite displacement behind the ripple front.

## Impact

Changes affect the fragment shader, internal loader, ripple lifetime, and regression tests. The public constructor signatures and asset resolution order are preserved.

## Non-goals

GPU capacity policy, ripple ownership, rebuild preservation, playback controls, styling expansion, and performance tuning require separate work.
