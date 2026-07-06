import 'dart:math' as math;

import 'wave_effect.dart';

/// A pointer-driven ripple. Placed in a [Wave]'s effects, it makes the enclosing
/// `WaveField` interactive: taps and drags spawn ripples that radiate out from
/// the pointer and fade. The displacement is a pure function of position and
/// age, so both the CPU and GPU paths — and tests — agree.
class PointerRippleEffect extends WaveEffect {
  /// Peak height displacement (normalized to field height) at impact.
  final double strength;

  /// Amplitude decay per second.
  final double decay;

  /// Outward propagation speed, in normalized x per second.
  final double speed;

  /// Spatial wavelength of the ripple, in normalized x.
  final double wavelength;

  const PointerRippleEffect({
    this.strength = 0.08,
    this.decay = 1.6,
    this.speed = 0.6,
    this.wavelength = 0.18,
  })  : assert(decay > 0, 'decay must be greater than zero.'),
        assert(wavelength > 0, 'wavelength must be greater than zero.');

  /// The height displacement this ripple contributes at normalized [x] for a
  /// ripple that originated at [originX] and has existed for [age] seconds.
  double displacementAt({
    required double x,
    required double originX,
    required double age,
  }) {
    final amplitude = strength * math.exp(-decay * age);
    if (amplitude < 1e-4) {
      return 0.0;
    }
    final offset = (x - originX).abs() - (speed * age);
    final ring = math.cos((2 * math.pi * offset) / wavelength);
    final envelope = math.exp(-math.pow(offset / (wavelength * 1.5), 2).toDouble());
    return amplitude * ring * envelope;
  }

  /// Seconds after which this ripple's amplitude is negligible.
  double get lifetime => math.log(strength / 1e-4).clamp(0, double.infinity) / decay;

  @override
  bool operator ==(Object other) =>
      other is PointerRippleEffect &&
      other.strength == strength &&
      other.decay == decay &&
      other.speed == speed &&
      other.wavelength == wavelength;

  @override
  int get hashCode => Object.hash(strength, decay, speed, wavelength);
}
