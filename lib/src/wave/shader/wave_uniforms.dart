import 'dart:typed_data';
import 'dart:ui' as ui;

import '../ripple_field.dart';
import '../wave.dart';
import '../wave_shape.dart';

/// Packs [Wave] layers and pointer ripples into the `wave.frag` uniform layout.
/// The float order here must match the uniform declaration order in
/// `shaders/wave.frag`:
/// `uSize`(2) + `uLayerCount`(1) + `uGeometry`(vec4 × 8) + `uGeometryB`(vec4 × 8)
/// + `uColor`(vec4 × 8) + `uRippleParams`(vec4) + `uRippleCount`(1) +
/// `uRipple`(vec4 × 8). [floatCount] is the single source of truth for how many
/// floats the shader declares; a mismatch is what makes a stale shader crash.
class WaveUniforms {
  WaveUniforms._();

  /// Maximum layers the shader supports (`MAX_LAYERS` in `wave.frag`).
  static const int maxLayers = 8;

  /// Maximum concurrent ripples the shader renders (`MAX_RIPPLES`).
  static const int maxRipples = 8;

  static const int _geometryBase = 3;
  static const int _geometryBBase = _geometryBase + maxLayers * 4;
  static const int _colorBase = _geometryBBase + maxLayers * 4;
  static const int _rippleParamsBase = _colorBase + maxLayers * 4;
  static const int _rippleCountIndex = _rippleParamsBase + 4;
  static const int _rippleBase = _rippleCountIndex + 1;

  /// Total number of float uniforms the shader declares.
  static const int floatCount = _rippleBase + maxRipples * 4;

  static const double _sine = 0;
  static const double _gerstner = 1;
  static const double _metaball = 2;

  /// Builds the full uniform float vector for [waves] sampled at time [t]
  /// (seconds) over a [size] area, plus any live ripples from [rippleField].
  /// Pure and deterministic — no shader required.
  static Float32List pack({
    required ui.Size size,
    required List<Wave> waves,
    required double t,
    RippleField? rippleField,
  }) {
    final data = Float32List(floatCount);
    final count = waves.length.clamp(0, maxLayers);
    data[0] = size.width;
    data[1] = size.height;
    data[2] = count.toDouble();

    for (var i = 0; i < count; i++) {
      _packLayer(data, waves[i], t, _geometryBase + i * 4,
          _geometryBBase + i * 4, _colorBase + i * 4);
    }

    _packRipples(data, rippleField, t);
    return data;
  }

  /// Writes the packed uniforms into [shader].
  static void apply(
    ui.FragmentShader shader, {
    required ui.Size size,
    required List<Wave> waves,
    required double t,
    RippleField? rippleField,
  }) {
    final data = pack(size: size, waves: waves, t: t, rippleField: rippleField);
    for (var i = 0; i < data.length; i++) {
      shader.setFloat(i, data[i]);
    }
  }

  static void _packLayer(
    Float32List data,
    Wave wave,
    double t,
    int gi,
    int gbi,
    int ci,
  ) {
    final shape = wave.shape;
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

    data[gi] = shape.baseline;
    data[gi + 1] = amplitude;
    data[gi + 2] = frequency;
    data[gi + 3] = wave.motion.phaseAt(t);
    data[gbi] = shapeType;
    data[gbi + 1] = steepness;
    data[gbi + 2] = blobCount;
    data[gbi + 3] = radius;
    data[ci] = color.r;
    data[ci + 1] = color.g;
    data[ci + 2] = color.b;
    data[ci + 3] = color.a;
  }

  static void _packRipples(
    Float32List data,
    RippleField? rippleField,
    double t,
  ) {
    final effect = rippleField?.effect;
    data[_rippleParamsBase] = effect?.strength ?? 0.0;
    data[_rippleParamsBase + 1] = effect?.decay ?? 1.0;
    data[_rippleParamsBase + 2] = effect?.speed ?? 0.0;
    data[_rippleParamsBase + 3] = effect?.wavelength ?? 1.0;

    final ripples = rippleField?.recent(maxRipples) ?? const [];
    final count = ripples.length.clamp(0, maxRipples);
    data[_rippleCountIndex] = count.toDouble();

    for (var i = 0; i < count; i++) {
      final ri = _rippleBase + i * 4;
      data[ri] = ripples[i].originX;
      data[ri + 1] = t - ripples[i].startTime;
    }
  }
}
