@Tags(['proof_wave_screen_preset_renders'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M1 proof: a preset produces a full-bleed [WaveScreen] whose composited
/// [WaveField] carries exactly the preset's waves and fills the given space.
void main() {
  testWidgets('WaveScreen renders the preset waves across its constraints', (
    tester,
  ) async {
    final preset = WavePresets.aurora;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: WaveScreen(preset: preset),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    final field = find.byType(WaveField);
    expect(field, findsOneWidget);
    expect(tester.widget<WaveField>(field).waves.length, preset.waves.length);
    expect(tester.getSize(field), const Size(400, 600));
  });
}
