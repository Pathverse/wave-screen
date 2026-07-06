@Tags(['proof_pingpong_reverses'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M3 proof: ping-pong motion eases the phase forward then back in a smooth
/// oscillation — through zero at the half period and reversed sign beyond it.
void main() {
  test('pingpong phase oscillates and reverses over a period', () {
    final motion = WaveMotion.pingPong(sway: 1.0, period: 4.0);

    expect(motion.phaseAt(0.0), closeTo(0.0, 1e-9)); // start
    expect(motion.phaseAt(1.0), closeTo(1.0, 1e-9)); // quarter -> peak
    expect(motion.phaseAt(2.0), closeTo(0.0, 1e-9)); // half -> back to zero
    expect(motion.phaseAt(3.0), closeTo(-1.0, 1e-9)); // three-quarter -> reversed

    // Reversal: later in the cycle the phase moves opposite to earlier.
    expect(motion.phaseAt(3.0) < motion.phaseAt(1.0), isTrue);
    // Periodic.
    expect(motion.phaseAt(4.0), closeTo(motion.phaseAt(0.0), 1e-9));
  });
}
