import 'dart:math' as math;

import 'package:flutter/foundation.dart';

const double _twoPi = 2 * math.pi;

/// The geometry trait of a wave: a height field sampled at a normalized
/// horizontal position with a motion-supplied phase. The GPU shader mirrors
/// this exact model so CPU-side [sampleAt] and the rendered surface agree.
@immutable
abstract class WaveShape {
  const WaveShape();

  /// A single clean sine surface of the given [amplitude] and [frequency]
  /// (cycles across the full width). [baseline] is the normalized vertical
  /// anchor of the crest line, `0` at the top and `1` at the bottom.
  const factory WaveShape.sine({
    required double amplitude,
    required double frequency,
    double baseline,
  }) = SineWaveShape;

  /// Sample the surface height (in amplitude units) at normalized [x] in
  /// `[0, 1]` with the given [phase] in radians. This is the crest offset only;
  /// vertical placement is carried separately by [baseline].
  double sampleAt(double x, double phase);

  /// The normalized vertical anchor of the crest line, `[0, 1]`.
  double get baseline;
}

/// A pure single-frequency sine surface.
@immutable
class SineWaveShape extends WaveShape {
  final double amplitude;
  final double frequency;

  @override
  final double baseline;

  const SineWaveShape({
    required this.amplitude,
    required this.frequency,
    this.baseline = 0.5,
  });

  @override
  double sampleAt(double x, double phase) =>
      amplitude * math.sin((x * _twoPi * frequency) + phase);

  @override
  bool operator ==(Object other) =>
      other is SineWaveShape &&
      other.amplitude == amplitude &&
      other.frequency == frequency &&
      other.baseline == baseline;

  @override
  int get hashCode => Object.hash(amplitude, frequency, baseline);
}
