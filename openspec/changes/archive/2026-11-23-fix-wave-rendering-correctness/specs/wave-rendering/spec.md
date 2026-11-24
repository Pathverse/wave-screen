## ADDED Requirements

### Requirement: Translucent layer compositing

Wave layers SHALL composite in list order using source-over alpha blending, including partial crest coverage and resolved style opacity.

Proven by `proof_translucent_wave_compositing`.

#### Scenario: A half-opaque layer covers transparent space
- **WHEN** a half-opaque wave fully covers a pixel over transparent space
- **THEN** the output alpha is one half and the RGB channels are premultiplied by that alpha

#### Scenario: Translucent layers overlap
- **WHEN** two half-opaque waves fully cover the same pixel
- **THEN** the output alpha is three quarters and the later layer composites over the earlier layer

### Requirement: Concurrent shader availability

Concurrent shader requests SHALL await the same load attempt and receive the same completed program or failure result. Later requests SHALL reuse that result.

Proven by `proof_concurrent_shader_load`.

#### Scenario: Multiple fields request a pending shader
- **WHEN** several fields request the shader before its initial load completes
- **THEN** all requests receive the loaded program once it becomes available

#### Scenario: Loading fails
- **WHEN** all shader asset candidates fail
- **THEN** concurrent and later requests receive the cached failure result without starting another attempt
