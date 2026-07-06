import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

void main() {
  group('WaveMotion', () {
    test('drift advances phase linearly with time', () {
      final motion = WaveMotion.drift(speed: 2.0);
      expect(motion.phaseAt(0.0), 0.0);
      expect(motion.phaseAt(0.5), closeTo(1.0, 1e-12));
      expect(motion.phaseAt(1.0), closeTo(2.0, 1e-12));
    });

    test('still holds phase at zero for all time', () {
      final motion = WaveMotion.still();
      expect(motion.phaseAt(0.0), 0.0);
      expect(motion.phaseAt(3.7), 0.0);
    });
  });

  group('WaveShape.sine', () {
    test('samples a pure sine of amplitude and frequency', () {
      final shape = WaveShape.sine(amplitude: 1.0, frequency: 1.0);
      expect(shape.sampleAt(0.0, 0.0), closeTo(0.0, 1e-12));
      expect(shape.sampleAt(0.25, 0.0), closeTo(1.0, 1e-12));
      expect(shape.sampleAt(0.5, 0.0), closeTo(0.0, 1e-12));
    });

    test('phase offset shifts the sample', () {
      final shape = WaveShape.sine(amplitude: 2.0, frequency: 1.0);
      expect(shape.sampleAt(0.0, math.pi / 2), closeTo(2.0, 1e-12));
    });
  });

  group('Wave', () {
    test('composes motion phase into the shape height', () {
      final wave = Wave(
        shape: WaveShape.sine(amplitude: 1.0, frequency: 1.0),
        style: const WaveStyle(fill: Color(0xFF3B2CC5)),
        motion: WaveMotion.drift(speed: math.pi),
      );
      // At t=0 phase is 0, so height matches the raw shape.
      expect(wave.heightAt(0.25, 0.0), closeTo(1.0, 1e-12));
      // Advancing time changes the composed height (drift).
      expect(wave.heightAt(0.25, 0.5), isNot(closeTo(1.0, 1e-9)));
    });
  });
}
