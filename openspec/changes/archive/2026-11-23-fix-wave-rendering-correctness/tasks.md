# Tasks

## 1. Shader compositing

- [x] 1.1 Use premultiplied source-over and add a bound compiled-shader proof for single, overlapping, transparent, and partially covered layers. Verify the compositing proof passes.

## 2. Ripple envelope and expiry

- [x] 2.1 Replace negative-base shader pow, mirror the amplitude cutoff, and guard negligible-strength lifetime. Add bound shader-envelope and expiry proofs and verify they pass.

## 3. Shared shader loading

- [x] 3.1 Cache the pending shader-load future while preserving asset order and failure caching. Add a bound first-load concurrency proof and verify it passes alongside lifecycle tests.

## 4. Integration verification

- [x] 4.1 Run the full Flutter suite, analyzer, feature binding integrity check, focused behave journeys, and strict OpenSpec validation. Resolve regressions and verify all checks pass.
