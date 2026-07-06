@Tags(['proof_pointer_spawns_ripple'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M3 proof: an interactive [WaveField] (a wave carrying a [PointerRippleEffect])
/// emits a ripple at the normalized pointer position on both tap and drag,
/// reported through the onRipple callback.
void main() {
  testWidgets('tap and drag each spawn ripples at the pointer', (tester) async {
    final spawns = <Offset>[];
    final wave = Wave(
      shape: WaveShape.sine(amplitude: 0.06, frequency: 1.0),
      style: const WaveStyle(fill: Color(0xFF3A7BD5)),
      motion: WaveMotion.drift(speed: 0.3),
      effects: const [PointerRippleEffect()],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: WaveField(waves: [wave], onRipple: spawns.add),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    // A tap at the center emits a ripple at normalized (0.5, 0.5).
    await tester.tapAt(tester.getCenter(find.byType(WaveField)));
    await tester.pump();
    expect(spawns, isNotEmpty);
    expect(spawns.first.dx, closeTo(0.5, 0.1));

    // Dragging emits further ripples along the path.
    final tapsAfterTap = spawns.length;
    await tester.drag(find.byType(WaveField), const Offset(40, 0));
    await tester.pump();
    expect(spawns.length, greaterThan(tapsAfterTap));
  });
}
