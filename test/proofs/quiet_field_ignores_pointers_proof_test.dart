@Tags(['proof_quiet_field_ignores_pointers'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// Proof that interactivity is opt-in: the same field is inert without a
/// [PointerRippleEffect] and responsive with one. Observed through the public
/// `onRipple` callback — no internals inspected.
void main() {
  testWidgets('a quiet field reports nothing while an interactive one responds', (
    tester,
  ) async {
    final reported = <Offset>[];

    Future<void> mountField(List<WaveEffect> effects) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: WaveField(
                  waves: [
                    Wave(
                      shape: WaveShape.sine(amplitude: 0.06, frequency: 1.0),
                      style: const WaveStyle(fill: Color(0xFF3A7BD5)),
                      motion: WaveMotion.still(),
                      effects: effects,
                    ),
                  ],
                  onRipple: reported.add,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }

    await mountField(const <WaveEffect>[]);
    await tester.tapAt(tester.getCenter(find.byType(WaveField)));
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      reported,
      isEmpty,
      reason: 'a wave carrying no PointerRippleEffect must leave the field inert',
    );

    await mountField(const <WaveEffect>[PointerRippleEffect()]);
    await tester.tapAt(tester.getCenter(find.byType(WaveField)));
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      reported,
      isNotEmpty,
      reason: 'adding the effect must make the very same field interactive',
    );
    expect(reported.last.dx, closeTo(0.5, 1e-6));
    expect(reported.last.dy, closeTo(0.5, 1e-6));
  });
}
