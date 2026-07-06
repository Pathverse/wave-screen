@Tags(['proof_gerstner_sharpens_crest'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M2 proof: the Gerstner shape peaks at the same crest as a sine of the same
/// amplitude/frequency, but sharpens — sitting below the sine at the sine's
/// zero-crossing (flatter troughs, sharper peaks).
void main() {
  test('gerstner peaks like a sine but flattens between crests', () {
    final gerstner = WaveShape.gerstner(
      amplitude: 1.0,
      frequency: 1.0,
      steepness: 0.8,
    );
    final sine = WaveShape.sine(amplitude: 1.0, frequency: 1.0);

    // Crest of both is at x = 0.25 (theta = pi/2).
    expect(gerstner.sampleAt(0.25, 0.0), closeTo(1.0, 1e-9));
    expect(sine.sampleAt(0.25, 0.0), closeTo(1.0, 1e-9));

    // At the sine's zero-crossing the sharpened profile dips well below zero.
    expect(sine.sampleAt(0.0, 0.0), closeTo(0.0, 1e-9));
    expect(gerstner.sampleAt(0.0, 0.0), lessThan(-0.1));
  });
}
