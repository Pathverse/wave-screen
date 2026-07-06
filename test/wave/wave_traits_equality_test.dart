import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// Value semantics for the trait types — so equal configurations compare equal
/// (and drive `WaveField`/painter repaint decisions correctly).
void main() {
  test('WaveMotion has value equality', () {
    expect(WaveMotion.drift(speed: 1.0), WaveMotion.drift(speed: 1.0));
    expect(
      WaveMotion.drift(speed: 1.0).hashCode,
      WaveMotion.drift(speed: 1.0).hashCode,
    );
    expect(WaveMotion.drift(speed: 1.0) == WaveMotion.drift(speed: 2.0), isFalse);
    expect(WaveMotion.still(), WaveMotion.still());
    expect(WaveMotion.still().hashCode, WaveMotion.still().hashCode);
    expect(WaveMotion.drift(speed: 1.0) == WaveMotion.still(), isFalse);
  });

  test('WaveShape.sine has value equality', () {
    final a = WaveShape.sine(amplitude: 0.3, frequency: 1.0);
    final b = WaveShape.sine(amplitude: 0.3, frequency: 1.0);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == WaveShape.sine(amplitude: 0.4, frequency: 1.0), isFalse);
    expect(a == WaveShape.sine(amplitude: 0.3, frequency: 1.0, baseline: 0.2),
        isFalse);
  });

  test('WaveStyle has value equality and folds opacity into alpha', () {
    const a = WaveStyle(fill: Color(0xFF112233));
    const b = WaveStyle(fill: Color(0xFF112233));
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == const WaveStyle(fill: Color(0xFF000000)), isFalse);
    expect(const WaveStyle(fill: Color(0xFFFFFFFF), opacity: 0.5).resolvedColor.a,
        closeTo(0.5, 1e-6));
  });

  test('Wave has value equality over its traits', () {
    Wave build({double amplitude = 0.3}) => Wave(
          shape: WaveShape.sine(amplitude: amplitude, frequency: 1.0),
          style: const WaveStyle(fill: Color(0xFF112233)),
          motion: WaveMotion.still(),
        );
    expect(build(), build());
    expect(build().hashCode, build().hashCode);
    expect(build() == build(amplitude: 0.9), isFalse);
  });
}
