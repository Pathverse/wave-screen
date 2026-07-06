import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// Value semantics for the M2 shapes, and a field rendering mixed shapes (which
/// drives the shader's per-shape uniform packing).
void main() {
  test('gerstner with steepness 0 equals a plain sine sample', () {
    final gerstner = WaveShape.gerstner(
      amplitude: 1.0,
      frequency: 1.0,
      steepness: 0.0,
    );
    final sine = WaveShape.sine(amplitude: 1.0, frequency: 1.0);
    for (final x in [0.0, 0.15, 0.5, 0.9]) {
      expect(gerstner.sampleAt(x, 0.3), closeTo(sine.sampleAt(x, 0.3), 1e-9));
    }
  });

  test('GerstnerWaveShape has value equality', () {
    final a = WaveShape.gerstner(amplitude: 0.3, frequency: 1.0, steepness: 0.6);
    final b = WaveShape.gerstner(amplitude: 0.3, frequency: 1.0, steepness: 0.6);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(
      a == WaveShape.gerstner(amplitude: 0.3, frequency: 1.0, steepness: 0.9),
      isFalse,
    );
  });

  test('MetaballWaveShape has value equality', () {
    final a = WaveShape.metaball(blobCount: 3, amplitude: 0.3, radius: 0.15);
    final b = WaveShape.metaball(blobCount: 3, amplitude: 0.3, radius: 0.15);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(
      a == WaveShape.metaball(blobCount: 4, amplitude: 0.3, radius: 0.15),
      isFalse,
    );
  });

  testWidgets('WaveField renders mixed gerstner and metaball layers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 200,
            child: WaveField(
              waves: [
                Wave(
                  shape: WaveShape.gerstner(
                    amplitude: 0.06,
                    frequency: 1.0,
                    steepness: 0.9,
                  ),
                  style: const WaveStyle(fill: Color(0xFF1C6E8C)),
                  motion: WaveMotion.drift(speed: 0.3),
                ),
                Wave(
                  shape: WaveShape.metaball(
                    blobCount: 4,
                    radius: 0.18,
                    amplitude: 0.12,
                  ),
                  style: const WaveStyle(fill: Color(0xFFC85C9C)),
                  motion: WaveMotion.drift(speed: -0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    expect(tester.getSize(find.byType(WaveField)), const Size(300, 200));
  });
}
