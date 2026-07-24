import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// The trait-composition contract: effects compose without disturbing the other
/// traits, equality spans the effect list, and appearance validates its inputs.
void main() {
  Wave build({List<WaveEffect> effects = const <WaveEffect>[]}) => Wave(
        shape: WaveShape.sine(amplitude: 0.3, frequency: 1.0),
        style: const WaveStyle(fill: Color(0xFF112233)),
        motion: WaveMotion.drift(speed: 0.5),
        effects: effects,
      );

  group('effect composition', () {
    test('effects default to an empty list', () {
      expect(build().effects, isEmpty);
    });

    test('carrying effects leaves the other traits untouched', () {
      final plain = build();
      final rippled = build(effects: const [PointerRippleEffect()]);

      expect(rippled.shape, plain.shape);
      expect(rippled.style, plain.style);
      expect(rippled.motion, plain.motion);
      // Composed height derives from shape and motion alone, so an effect must
      // not shift the surface itself.
      expect(rippled.heightAt(0.3, 1.2), plain.heightAt(0.3, 1.2));
    });

    test('a differing effect list breaks equality', () {
      expect(build(), build());
      expect(build().hashCode, build().hashCode);

      expect(build() == build(effects: const [PointerRippleEffect()]), isFalse);
      expect(
        build(effects: const [PointerRippleEffect(strength: 0.1)]) ==
            build(effects: const [PointerRippleEffect(strength: 0.2)]),
        isFalse,
      );
      expect(
        build(effects: const [PointerRippleEffect()]),
        build(effects: const [PointerRippleEffect()]),
      );
    });
  });

  group('WaveStyle validation', () {
    test('rejects an opacity above one', () {
      expect(
        () => WaveStyle(fill: const Color(0xFF112233), opacity: 1.5),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a negative opacity', () {
      expect(
        () => WaveStyle(fill: const Color(0xFF112233), opacity: -0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('accepts the closed bounds', () {
      expect(WaveStyle(fill: const Color(0xFF112233), opacity: 0.0).opacity, 0.0);
      expect(WaveStyle(fill: const Color(0xFF112233), opacity: 1.0).opacity, 1.0);
    });
  });

  test('sampleAt returns a crest offset independent of baseline', () {
    final low = WaveShape.sine(amplitude: 0.3, frequency: 1.0, baseline: 0.2);
    final high = WaveShape.sine(amplitude: 0.3, frequency: 1.0, baseline: 0.9);

    for (final x in [0.0, 0.17, 0.5, 0.83]) {
      expect(low.sampleAt(x, 0.4), closeTo(high.sampleAt(x, 0.4), 1e-12));
    }
    // Placement is carried separately, so the baselines themselves differ.
    expect(low.baseline, 0.2);
    expect(high.baseline, 0.9);
  });
}
