@Tags(['proof_wave_traits_drive_surface'])
library;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M1 proof: shape + motion traits determine the wave surface. The height field
/// is a real pure function (the shader mirrors it). A drifting wave's surface at
/// a fixed point moves through time; a still wave's surface holds constant.
void main() {
  test('drift changes the surface over time while still holds it', () {
    final drifting = Wave(
      shape: WaveShape.sine(amplitude: 0.3, frequency: 1.5),
      style: const WaveStyle(fill: Color(0xFF3B2CC5)),
      motion: WaveMotion.drift(speed: 1.0),
    );
    final still = Wave(
      shape: WaveShape.sine(amplitude: 0.3, frequency: 1.5),
      style: const WaveStyle(fill: Color(0xFF3B2CC5)),
      motion: WaveMotion.still(),
    );

    const x = 0.25;
    expect(
      drifting.heightAt(x, 0.0),
      isNot(closeTo(drifting.heightAt(x, 0.5), 1e-6)),
      reason: 'a drifting wave must evolve over time',
    );
    expect(
      still.heightAt(x, 0.0),
      closeTo(still.heightAt(x, 0.5), 1e-9),
      reason: 'a still wave must not evolve over time',
    );
  });
}
