import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';
import 'package:wave_screen/src/wave/ripple_field.dart';

/// M3 value semantics and the RippleField controller, plus a field that swaps
/// its waves at runtime.
void main() {
  test('PingPongMotion has value equality', () {
    expect(
      WaveMotion.pingPong(sway: 1.0, period: 4.0),
      WaveMotion.pingPong(sway: 1.0, period: 4.0),
    );
    expect(
      WaveMotion.pingPong(sway: 1.0, period: 4.0).hashCode,
      WaveMotion.pingPong(sway: 1.0, period: 4.0).hashCode,
    );
    expect(
      WaveMotion.pingPong(sway: 1.0, period: 4.0) ==
          WaveMotion.pingPong(sway: 2.0, period: 4.0),
      isFalse,
    );
  });

  test('PointerRippleEffect has value equality and a finite lifetime', () {
    const a = PointerRippleEffect();
    const b = PointerRippleEffect();
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == const PointerRippleEffect(strength: 0.2), isFalse);
    expect(a.lifetime, greaterThan(0));
  });

  group('RippleField', () {
    test('sums live ripples and reports counts', () {
      final field = RippleField(const PointerRippleEffect());
      expect(field.isEmpty, isTrue);

      field.spawn(0.5, 0.0);
      expect(field.activeCount, 1);
      // At impact, the surface near the origin is displaced.
      expect(field.displacementAt(0.5, 0.0).abs(), greaterThan(0.0));

      field.spawn(0.2, 0.0);
      expect(field.recent(1).length, 1);
      expect(field.recent(5).length, 2);
    });

    test('prunes ripples once they decay past their lifetime', () {
      final effect = const PointerRippleEffect();
      final field = RippleField(effect)..spawn(0.5, 0.0);
      field.prune(effect.lifetime + 1.0);
      expect(field.isEmpty, isTrue);
    });
  });

  testWidgets('WaveField rebuilds its ripple wiring when waves change', (
    tester,
  ) async {
    Widget build(List<Wave> waves) => MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 200, height: 200, child: WaveField(waves: waves)),
          ),
        );

    final plain = [
      Wave(
        shape: WaveShape.sine(amplitude: 0.06, frequency: 1.0),
        style: const WaveStyle(fill: Color(0xFF3A7BD5)),
        motion: WaveMotion.drift(speed: 0.3),
      ),
    ];
    final interactive = [
      Wave(
        shape: WaveShape.sine(amplitude: 0.06, frequency: 1.0),
        style: const WaveStyle(fill: Color(0xFF3A7BD5)),
        motion: WaveMotion.pingPong(sway: 0.6, period: 5.0),
        effects: const [PointerRippleEffect()],
      ),
    ];

    await tester.pumpWidget(build(plain));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pumpWidget(build(interactive));
    await tester.pump(const Duration(milliseconds: 16));

    expect(tester.getSize(find.byType(WaveField)), const Size(200, 200));
  });
}
