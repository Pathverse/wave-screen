@Tags(['proof_negligible_ripple_expiry'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/src/wave/ripple_field.dart';
import 'package:wave_screen/wave_screen.dart';

void main() {
  test('negative and negligible ripples expire after the clock advances', () {
    for (final strength in [-0.08, 0.0, 0.00001, 0.0001]) {
      final effect = PointerRippleEffect(strength: strength);
      final field = RippleField(effect)..spawn(0.5, 0);
      expect(effect.lifetime, 0);
      expect(effect.displacementAt(x: 0.5, originX: 0.5, age: 0.1), 0);
      field.prune(0.001);
      expect(field.activeCount, 0);
    }
    const ordinary = PointerRippleEffect();
    expect(ordinary.lifetime, closeTo(4.1779, 0.001));
  });
}
