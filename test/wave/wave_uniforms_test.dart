import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';
import 'package:wave_screen/src/wave/ripple_field.dart';
import 'package:wave_screen/src/wave/shader/wave_uniforms.dart';

/// Deterministic coverage of the shader uniform packer — no GPU required. The
/// float-count assertion is the guard against the shader and packer drifting
/// out of sync (the class of bug that crashes a stale shader).
void main() {
  test('pack lays out sine, gerstner and metaball layers plus ripples', () {
    final waves = [
      Wave(
        shape: WaveShape.sine(amplitude: 0.3, frequency: 1.2, baseline: 0.4),
        style: const WaveStyle(fill: Color(0xFF102030)),
        motion: WaveMotion.still(),
      ),
      Wave(
        shape: WaveShape.gerstner(
          amplitude: 0.2,
          frequency: 0.9,
          steepness: 0.7,
        ),
        style: const WaveStyle(fill: Color(0xFF203040)),
        motion: WaveMotion.still(),
      ),
      Wave(
        shape: WaveShape.metaball(blobCount: 3, amplitude: 0.25, radius: 0.2),
        style: const WaveStyle(fill: Color(0xFF304050)),
        motion: WaveMotion.still(),
      ),
    ];
    final ripples = RippleField(const PointerRippleEffect())..spawn(0.5, 0.0);

    final data = WaveUniforms.pack(
      size: const Size(300, 200),
      waves: waves,
      t: 1.0,
      rippleField: ripples,
    );

    // Full vector — matches the shader's declared uniform count exactly.
    expect(data.length, WaveUniforms.floatCount);

    // uSize + uLayerCount.
    expect(data[0], 300);
    expect(data[1], 200);
    expect(data[2], 3);

    // Per-layer shapeType lives in the geometryB block (base 35, stride 4).
    expect(data[35], 0); // sine
    expect(data[39], 1); // gerstner
    expect(data[43], 2); // metaball

    // Ripple count is non-zero and the first ripple's origin is packed.
    expect(data[WaveUniforms.floatCount - 33], 1); // uRippleCount
    expect(data[WaveUniforms.floatCount - 32], closeTo(0.5, 1e-6)); // originX
  });

  test('pack with no waves or ripples still fills the whole vector', () {
    final data = WaveUniforms.pack(
      size: const Size(100, 100),
      waves: const [],
      t: 0.0,
    );
    expect(data.length, WaveUniforms.floatCount);
    expect(data[2], 0); // layer count
  });
}
