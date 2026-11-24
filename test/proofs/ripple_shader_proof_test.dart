@Tags(['proof_ripple_shader_envelope'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/src/wave/ripple_field.dart';
import 'package:wave_screen/wave_screen.dart';

import '../support/render_wave_shader.dart';

void main() {
  testWidgets(
    'the shader crest follows the ripple model behind and ahead of the front',
    (tester) async {
      final wave = Wave(
        shape: WaveShape.sine(amplitude: 0, frequency: 1),
        style: const WaveStyle(),
        motion: WaveMotion.still(),
      );
      for (final strength in [0.08, -0.08, 0.00001]) {
        final effect = PointerRippleEffect(strength: strength);
        final field = RippleField(effect)..spawn(0.5, 0);
        for (final age in [0.0, 0.1, 0.4, 5.0]) {
          final rgba = await tester.runAsync(
            () => renderWaveShader(waves: [wave], t: age, rippleField: field),
          );
          for (final column in [10, 60, 90, 100, 110, 140, 190]) {
            final x = (column + 0.5) / 200;
            final displacement = field.displacementAt(x, age);
            expect(displacement.isFinite, isTrue);
            final row = List.generate(120, (i) => i).firstWhere(
              (row) => rgba![((row * 200 + column) * 4) + 3] >= 128,
              orElse: () => -1,
            );
            expect(row, greaterThanOrEqualTo(0));
            expect((row + 0.5) / 120, closeTo(0.5 + displacement, 2 / 120));
          }
        }
      }
    },
  );
}
