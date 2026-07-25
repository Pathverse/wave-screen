@Tags(['proof_surface_paints_visible_waves'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// Proof that a mounted field really paints: the rendered boundary is captured
/// and scanned for the wave's own colour. This pins the user-visible outcome
/// (the surface is not an empty box), not which render path produced it — the
/// fragment program does load under `flutter test`, so the CPU fallback is
/// covered deterministically at unit level instead.
void main() {
  testWidgets('a mounted field fills pixels with its wave colour', (
    tester,
  ) async {
    const fill = Color(0xFFE0217A);
    final boundaryKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF000000),
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: 200,
                height: 120,
                child: WaveField(
                  waves: [
                    Wave(
                      shape: WaveShape.sine(amplitude: 0.1, frequency: 1.0),
                      style: const WaveStyle(fill: fill),
                      motion: WaveMotion.still(),
                    ),
                  ],
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
    var painted = 0;
    for (var i = 0; i + 3 < rgba.length; i += 4) {
      if (rgba[i] == 0xE0 && rgba[i + 1] == 0x21 && rgba[i + 2] == 0x7A) {
        painted++;
      }
    }

    expect(
      painted,
      greaterThan(0),
      reason: "the mounted field must fill real pixels with the wave's colour "
          'rather than leaving the box empty',
    );
  });
}
