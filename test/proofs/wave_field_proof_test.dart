@Tags(['proof_wave_field_renders_and_animates'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M1 proof: a composed [WaveField] mounts, fills the box it is given, and
/// runs a repeating animation when it carries a drifting wave.
void main() {
  testWidgets('WaveField fills its constraints and animates over time', (
    tester,
  ) async {
    final wave = Wave(
      shape: WaveShape.sine(amplitude: 0.3, frequency: 1.2),
      style: const WaveStyle(fill: Color(0xFF3B2CC5)),
      motion: WaveMotion.drift(speed: 0.5),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 200,
              child: WaveField(waves: [wave]),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(tester.getSize(find.byType(WaveField)), const Size(300, 200));
    expect(tester.hasRunningAnimations, isTrue);
  });
}
