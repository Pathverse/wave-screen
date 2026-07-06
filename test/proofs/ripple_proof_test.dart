@Tags(['proof_ripple_decays_and_propagates'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M3 proof: a pointer ripple is a pure function of position and age. It carries
/// real displacement at impact, its wavefront moves outward as it ages, and it
/// fades to nothing long after.
void main() {
  test('ripple propagates outward and decays', () {
    final ripple = PointerRippleEffect(
      strength: 0.1,
      decay: 1.5,
      speed: 0.6,
      wavelength: 0.2,
    );

    // Real displacement at impact near the origin.
    expect(
      ripple.displacementAt(x: 0.0, originX: 0.0, age: 0.0).abs(),
      greaterThan(0.05),
    );

    // Fades away long after the tap.
    expect(
      ripple.displacementAt(x: 0.0, originX: 0.0, age: 10.0).abs(),
      lessThan(0.001),
    );

    // Propagation: a point away from the origin responds more strongly once the
    // wavefront reaches it than at the instant of impact.
    const away = 0.3;
    final atArrival =
        ripple.displacementAt(x: away, originX: 0.0, age: away / 0.6);
    final atImpact =
        ripple.displacementAt(x: away, originX: 0.0, age: 0.0);
    expect(atArrival.abs(), greaterThan(atImpact.abs()));
  });
}
