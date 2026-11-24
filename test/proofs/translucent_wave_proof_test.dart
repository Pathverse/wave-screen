@Tags(['proof_translucent_wave_compositing'])
library;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

import '../support/render_wave_shader.dart';

void main() {
  testWidgets('translucent shader layers use premultiplied source-over', (
    tester,
  ) async {
    Wave layer(Color color, double opacity) => Wave(
      shape: WaveShape.sine(amplitude: 0, frequency: 1, baseline: 0.5),
      style: WaveStyle(fill: color, opacity: opacity),
      motion: WaveMotion.still(),
    );

    final cases = [
      (
        waves: [layer(const Color(0xFFFF0000), 0.5)],
        expected: [128, 0, 0, 128],
      ),
      (waves: [layer(const Color(0x80FF0000), 1)], expected: [128, 0, 0, 128]),
      (
        waves: [
          layer(const Color(0xFFFF0000), 0.5),
          layer(const Color(0xFF00FF00), 0.5),
        ],
        expected: [64, 128, 0, 191],
      ),
      (
        waves: [
          layer(const Color(0xFFFF0000), 0.5),
          layer(const Color(0xFF00FF00), 0),
        ],
        expected: [128, 0, 0, 128],
      ),
    ];
    for (final sample in cases) {
      final rgba = await tester.runAsync(
        () => renderWaveShader(waves: sample.waves),
      );
      const bottomPixel = ((100 * 200) + 100) * 4;
      for (var c = 0; c < 4; c++) {
        expect(rgba![bottomPixel + c], closeTo(sample.expected[c], 1));
      }
    }

    final rgba = await tester.runAsync(
      () => renderWaveShader(waves: [layer(const Color(0xFFFF0000), 0.5)]),
    );
    // Row 60 has its center 0.5 logical pixels below a flat crest. The
    // smoothstep spans crest +/- 1.5 pixels, giving coverage 20/27.
    const edgePixel = ((60 * 200) + 100) * 4;
    expect(rgba![edgePixel], closeTo(255 * 0.5 * 20 / 27, 2));
    expect(rgba[edgePixel + 3], closeTo(255 * 0.5 * 20 / 27, 2));
    expect(rgba[0], 0);
    expect(rgba[3], 0);
  });
}
