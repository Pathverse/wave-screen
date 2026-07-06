import 'dart:ui' as ui;

import '../wave.dart';
import '../wave_shape.dart';

/// Packs [Wave] layers into the `wave.frag` uniform layout. The float order here
/// must match the uniform declaration order in `shaders/wave.frag`:
/// `uSize`(2) + `uLayerCount`(1) + `uGeometry`(vec4 × 8) + `uGeometryB`(vec4 × 8)
/// + `uColor`(vec4 × 8).
class WaveUniforms {
  WaveUniforms._();

  /// Maximum layers the shader supports (`MAX_LAYERS` in `wave.frag`).
  static const int maxLayers = 8;

  static const int _geometryBase = 3;
  static const int _geometryBBase = _geometryBase + maxLayers * 4;
  static const int _colorBase = _geometryBBase + maxLayers * 4;

  static const double _sine = 0;
  static const double _gerstner = 1;
  static const double _metaball = 2;

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
      final gbi = _geometryBBase + i * 4;
      final ci = _colorBase + i * 4;
      if (i < count) {
        _writeLayer(shader, waves[i], t, gi, gbi, ci);
      } else {
        for (var k = 0; k < 4; k++) {
          shader
            ..setFloat(gi + k, 0.0)
            ..setFloat(gbi + k, 0.0)
            ..setFloat(ci + k, 0.0);
        }
      }
    }
  }

  static void _writeLayer(
    ui.FragmentShader shader,
    Wave wave,
    double t,
    int gi,
    int gbi,
    int ci,
  ) {
    final shape = wave.shape;
    final phase = wave.motion.phaseAt(t);
    final color = wave.style.resolvedColor;

    var shapeType = _sine;
    var amplitude = 0.0;
    var frequency = 0.0;
    var steepness = 0.0;
    var blobCount = 0.0;
    var radius = 0.0;
    if (shape is SineWaveShape) {
      amplitude = shape.amplitude;
      frequency = shape.frequency;
    } else if (shape is GerstnerWaveShape) {
      shapeType = _gerstner;
      amplitude = shape.amplitude;
      frequency = shape.frequency;
      steepness = shape.steepness;
    } else if (shape is MetaballWaveShape) {
      shapeType = _metaball;
      amplitude = shape.amplitude;
      blobCount = shape.blobCount.toDouble();
      radius = shape.radius;
    }

    shader
      ..setFloat(gi, shape.baseline)
      ..setFloat(gi + 1, amplitude)
      ..setFloat(gi + 2, frequency)
      ..setFloat(gi + 3, phase)
      ..setFloat(gbi, shapeType)
      ..setFloat(gbi + 1, steepness)
      ..setFloat(gbi + 2, blobCount)
      ..setFloat(gbi + 3, radius)
      ..setFloat(ci, color.r)
      ..setFloat(ci + 1, color.g)
      ..setFloat(ci + 2, color.b)
      ..setFloat(ci + 3, color.a);
  }
}
