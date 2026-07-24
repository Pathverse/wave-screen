import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// The motion contract: phase is the only channel through which time reaches a
/// surface, ping-pong is genuinely periodic, and the guards hold.
void main() {
  test('pingPong rejects a non-positive period', () {
    expect(
      () => WaveMotion.pingPong(sway: 1.0, period: 0.0),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => WaveMotion.pingPong(sway: 1.0, period: -3.0),
      throwsA(isA<AssertionError>()),
    );
  });

  test('pingPong phase is periodic across one full period', () {
    final motion = WaveMotion.pingPong(sway: 0.8, period: 4.0);

    for (final t in [0.0, 0.7, 1.9, 3.3]) {
      expect(motion.phaseAt(t), closeTo(motion.phaseAt(t + 4.0), 1e-12));
    }
  });

  test('pingPong reaches both extremes within a period', () {
    final motion = WaveMotion.pingPong(sway: 0.8, period: 4.0);

    // A quarter period in is the positive extreme, three quarters the negative.
    expect(motion.phaseAt(1.0), closeTo(0.8, 1e-12));
    expect(motion.phaseAt(3.0), closeTo(-0.8, 1e-12));
  });

  test('motions yielding the same phase produce the same surface height', () {
    final shape = WaveShape.sine(amplitude: 0.4, frequency: 1.5);
    const style = WaveStyle(fill: Color(0xFF112233));

    // Drift at 1 rad/s reaches phase 2.0 at t=2.0; a still wave is always at 0.
    final drifting = Wave(shape: shape, style: style, motion: WaveMotion.drift(speed: 1.0));
    final frozen = Wave(shape: shape, style: style, motion: WaveMotion.still());

    expect(drifting.heightAt(0.4, 0.0), closeTo(frozen.heightAt(0.4, 9.9), 1e-12));

    // And a ping-pong at t=0 is also at phase zero, so it agrees too.
    final swaying = Wave(
      shape: shape,
      style: style,
      motion: WaveMotion.pingPong(sway: 1.0, period: 5.0),
    );
    expect(swaying.heightAt(0.4, 0.0), closeTo(frozen.heightAt(0.4, 0.0), 1e-12));
  });

  test('drift phase is linear and still phase never advances', () {
    final drift = WaveMotion.drift(speed: math.pi);
    expect(drift.phaseAt(2.0), closeTo(2 * math.pi, 1e-12));
    expect(WaveMotion.still().phaseAt(123.4), 0.0);
  });
}
