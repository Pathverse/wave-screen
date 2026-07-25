import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// Ripple construction guards and the normalization the field applies to
/// reported pointer positions.
void main() {
  group('construction guards', () {
    test('rejects a non-positive decay', () {
      expect(
        () => PointerRippleEffect(decay: 0.0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => PointerRippleEffect(decay: -1.0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a non-positive wavelength', () {
      expect(
        () => PointerRippleEffect(wavelength: 0.0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => PointerRippleEffect(wavelength: -0.2),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  testWidgets('a pointer dragged beyond the field clamps into [0, 1]', (
    tester,
  ) async {
    final reported = <Offset>[];

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
                    effects: const [PointerRippleEffect()],
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

    final centre = tester.getCenter(find.byType(WaveField));
    final gesture = await tester.startGesture(centre);
    await tester.pump(const Duration(milliseconds: 16));

    // Drag far past the bottom-right corner: the pointer is captured, so moves
    // outside the box still arrive.
    await gesture.moveTo(centre + const Offset(600, 600));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();

    expect(reported, isNotEmpty);
    expect(reported.last.dx, 1.0);
    expect(reported.last.dy, 1.0);

    // Drag far past the top-left corner on a fresh gesture.
    final second = await tester.startGesture(centre);
    await tester.pump(const Duration(milliseconds: 16));
    await second.moveTo(centre - const Offset(600, 600));
    await tester.pump(const Duration(milliseconds: 16));
    await second.up();

    expect(reported.last.dx, 0.0);
    expect(reported.last.dy, 0.0);
  });
}
