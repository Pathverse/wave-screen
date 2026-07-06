import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// The foundation preset library and the inline `WaveScreen.custom` builder.
void main() {
  test('every foundation preset is a valid layered background', () {
    expect(WavePresets.all.length, 3);
    for (final preset in WavePresets.all) {
      expect(preset.waves, isNotEmpty);
      // Must fit within the shader's MAX_LAYERS budget.
      expect(preset.waves.length, lessThanOrEqualTo(8));
      expect(preset.background, isNotNull);
    }
  });

  testWidgets('WaveScreen.custom builds a field from loose waves', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: WaveScreen.custom(
              backgroundColor: const Color(0xFF10131F),
              waves: [
                Wave(
                  shape: WaveShape.sine(amplitude: 0.3, frequency: 1.0),
                  style: const WaveStyle(fill: Color(0xFF3A7BD5)),
                  motion: WaveMotion.drift(speed: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(WaveScreen), findsOneWidget);
    expect(tester.widget<WaveField>(find.byType(WaveField)).waves, hasLength(1));
  });
}
