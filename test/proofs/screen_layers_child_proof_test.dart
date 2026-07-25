@Tags(['proof_screen_layers_child_above_waves'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// Proof that a screen's child paints in front of the animated waves. Proven by
/// observing rendered pixels: an opaque child covering the screen must hide the
/// wave colour entirely.
void main() {
  testWidgets('the child renders in front of the animated wave field', (
    tester,
  ) async {
    const waveFill = Color(0xFFE0217A);
    const childColour = Color(0xFF00A86B);
    final boundaryKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: 200,
                height: 120,
                child: WaveScreen.custom(
                  backgroundColor: const Color(0xFF101010),
                  waves: [
                    Wave(
                      shape: WaveShape.sine(amplitude: 0.2, frequency: 1.0),
                      style: const WaveStyle(fill: waveFill),
                      motion: WaveMotion.still(),
                    ),
                  ],
                  child: Container(color: childColour),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    final pixels = await tester.runAsync(() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      return data;
    });

    expect(pixels, isNotNull, reason: 'the boundary must be capturable');

    final rgba = pixels!.buffer.asUint8List();
    var childPixels = 0;
    var wavePixels = 0;
    for (var i = 0; i + 3 < rgba.length; i += 4) {
      if (rgba[i] == 0x00 && rgba[i + 1] == 0xA8 && rgba[i + 2] == 0x6B) {
        childPixels++;
      }
      if (rgba[i] == 0xE0 && rgba[i + 1] == 0x21 && rgba[i + 2] == 0x7A) {
        wavePixels++;
      }
    }

    expect(childPixels, greaterThan(0), reason: 'the child must be rendered');
    expect(
      wavePixels,
      0,
      reason: 'an opaque child covering the screen must paint over the waves, '
          'proving it is layered above the wave field rather than beneath it',
    );
  });
}
