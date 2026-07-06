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

  /// A sharpened, Gerstner-style crest of the given [amplitude] and [frequency].
  /// [steepness] `0` is identical to a sine; higher values sharpen the crests
  /// and flatten the troughs.
  const factory WaveShape.gerstner({
    required double amplitude,
    required double frequency,
    double steepness,
    double baseline,
  }) = GerstnerWaveShape;

  /// A gooey crest built from [blobCount] evenly-spaced merging blobs of the
  /// given [radius]. Nearby blobs bridge into one bulge; the bulge peaks at
  /// [amplitude]. Blobs drift with the motion phase.
  const factory WaveShape.metaball({
    required int blobCount,
    required double amplitude,
    double radius,
    double baseline,
  }) = MetaballWaveShape;

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

/// A sharpened, Gerstner-style crest. The profile is a gamma-shaped sine: with
/// [steepness] `0` it equals a sine; larger values narrow the crests and widen
/// the troughs, approximating the trochoidal ocean look as a pure height field.
@immutable
class GerstnerWaveShape extends WaveShape {
  final double amplitude;
  final double frequency;
  final double steepness;

  @override
  final double baseline;

  const GerstnerWaveShape({
    required this.amplitude,
    required this.frequency,
    this.steepness = 0.6,
    this.baseline = 0.5,
  }) : assert(steepness >= 0, 'steepness must be non-negative.');

  @override
  double sampleAt(double x, double phase) {
    final theta = (x * _twoPi * frequency) + phase;
    final u = 0.5 * (1 + math.sin(theta));
    final sharpened = math.pow(u, 1 + steepness).toDouble();
    return amplitude * ((2 * sharpened) - 1);
  }

  @override
  bool operator ==(Object other) =>
      other is GerstnerWaveShape &&
      other.amplitude == amplitude &&
      other.frequency == frequency &&
      other.steepness == steepness &&
      other.baseline == baseline;

  @override
  int get hashCode => Object.hash(amplitude, frequency, steepness, baseline);
}

/// A gooey crest made of [blobCount] evenly-spaced blobs that drift with the
/// motion phase. Each blob is a Gaussian bump of the given [radius]; blobs are
/// combined with a smooth union so nearby blobs merge into one bulge peaking at
/// [amplitude], while distant blobs stay separate.
@immutable
class MetaballWaveShape extends WaveShape {
  final int blobCount;
  final double amplitude;
  final double radius;

  @override
  final double baseline;

  const MetaballWaveShape({
    required this.blobCount,
    required this.amplitude,
    this.radius = 0.12,
    this.baseline = 0.5,
  })  : assert(blobCount > 0, 'blobCount must be positive.'),
        assert(radius > 0, 'radius must be greater than zero.');

  @override
  double sampleAt(double x, double phase) {
    final drift = phase / _twoPi;
    var product = 1.0;
    for (var i = 0; i < blobCount; i++) {
      final center = (((i + 0.5) / blobCount) + drift) % 1.0;
      final raw = (x - center).abs();
      final distance = math.min(raw, 1 - raw); // wrap around the edges
      final bump = math.exp(-math.pow(distance / radius, 2).toDouble());
      product *= 1 - bump;
    }
    return -amplitude * (1 - product);
  }

  @override
  bool operator ==(Object other) =>
      other is MetaballWaveShape &&
      other.blobCount == blobCount &&
      other.amplitude == amplitude &&
      other.radius == radius &&
      other.baseline == baseline;

  @override
  int get hashCode => Object.hash(blobCount, amplitude, radius, baseline);
}
