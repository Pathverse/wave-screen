import 'dart:ui' as ui;

import '../wave.dart';
import '../wave_shape.dart';

/// Packs [Wave] layers into the `wave.frag` uniform layout. The float order here
/// must match the uniform declaration order in `shaders/wave.frag`:
/// `uSize`(2) + `uLayerCount`(1) + `uGeometry`(vec4 × 8) + `uColor`(vec4 × 8).
class WaveUniforms {
  WaveUniforms._();

  /// Maximum layers the shader supports (`MAX_LAYERS` in `wave.frag`).
  static const int maxLayers = 8;

  static const int _geometryBase = 3;
  static const int _colorBase = _geometryBase + maxLayers * 4;

  /// Writes [waves] sampled at time [t] (seconds) over a [size] area into
  /// [shader]. Inactive layer slots are zero-filled so no uniform is left unset.
  static void apply(
    ui.FragmentShader shader, {
    required ui.Size size,
    required List<Wave> waves,
    required double t,
  }) {
    final count = waves.length.clamp(0, maxLayers);
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, count.toDouble());

    for (var i = 0; i < maxLayers; i++) {
      final gi = _geometryBase + i * 4;
      final ci = _colorBase + i * 4;
      if (i < count) {
        final wave = waves[i];
        final shape = wave.shape;
        final baseline = shape.baseline;
        final amplitude = shape is SineWaveShape ? shape.amplitude : 0.0;
        final frequency = shape is SineWaveShape ? shape.frequency : 0.0;
        final phase = wave.motion.phaseAt(t);
        final color = wave.style.resolvedColor;
        shader
          ..setFloat(gi, baseline)
          ..setFloat(gi + 1, amplitude)
          ..setFloat(gi + 2, frequency)
          ..setFloat(gi + 3, phase)
          ..setFloat(ci, color.r)
          ..setFloat(ci + 1, color.g)
          ..setFloat(ci + 2, color.b)
          ..setFloat(ci + 3, color.a);
      } else {
        for (var k = 0; k < 4; k++) {
          shader
            ..setFloat(gi + k, 0.0)
            ..setFloat(ci + k, 0.0);
        }
      }
    }
  }
}
