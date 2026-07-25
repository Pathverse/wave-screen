import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';
import 'package:wave_screen/src/wave/shader/wave_shader.dart';
import 'package:wave_screen/src/wave/wave_field_painter.dart';

/// Repaint decisions, disposal, and the compositing order of the CPU fallback.
void main() {
  Wave waveWith(Color colour, {double amplitude = 0.1}) => Wave(
        shape: WaveShape.sine(amplitude: amplitude, frequency: 1.0),
        style: WaveStyle(fill: colour),
        motion: WaveMotion.still(),
      );

  group('shouldRepaint', () {
    test('is false when the same inputs are handed back', () {
      final clock = ValueNotifier<double>(0.0);
      addTearDown(clock.dispose);
      final waves = [waveWith(const Color(0xFF112233))];

      final current = WaveFieldPainter(waves: waves, clock: clock, shader: null);
      final previous = WaveFieldPainter(waves: waves, clock: clock, shader: null);

      expect(current.shouldRepaint(previous), isFalse);
    });

    test('is true for an equal but distinct wave list', () {
      final clock = ValueNotifier<double>(0.0);
      addTearDown(clock.dispose);

      // Wave lists are compared by identity, not element equality, so a rebuild
      // that constructs a fresh list repaints even when the waves are equal.
      final current = WaveFieldPainter(
        waves: [waveWith(const Color(0xFF112233))],
        clock: clock,
        shader: null,
      );
      final previous = WaveFieldPainter(
        waves: [waveWith(const Color(0xFF112233))],
        clock: clock,
        shader: null,
      );

      expect(current.waves, previous.waves);
      expect(current.shouldRepaint(previous), isTrue);
    });

    test('is true when the wave list changes', () {
      final clock = ValueNotifier<double>(0.0);
      addTearDown(clock.dispose);

      final current = WaveFieldPainter(
        waves: [waveWith(const Color(0xFF112233))],
        clock: clock,
        shader: null,
      );
      final previous = WaveFieldPainter(
        waves: [waveWith(const Color(0xFF445566))],
        clock: clock,
        shader: null,
      );

      expect(current.shouldRepaint(previous), isTrue);
    });
  });

  testWidgets('the fragment program is loaded once and cached', (tester) async {
    final first = await tester.runAsync(() => WaveShaderLoader.load());
    final second = await tester.runAsync(() => WaveShaderLoader.load());

    expect(first, isNotNull);
    expect(
      identical(first, second),
      isTrue,
      reason: 'the program must be loaded at most once and the result reused',
    );
  });

  testWidgets('disposing a mounted field stops its animation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: WaveField(
              waves: [
                Wave(
                  shape: WaveShape.sine(amplitude: 0.1, frequency: 1.0),
                  style: const WaveStyle(fill: Color(0xFF3A7BD5)),
                  motion: WaveMotion.drift(speed: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.hasRunningAnimations, isTrue);

    // Replace the field with nothing: its ticker must be released with it.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(WaveField), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  // The fragment program DOES load under `flutter test`, so mounting a widget
  // exercises the GPU path, not the fallback. Driving the painter directly with
  // `shader: null` is the only way to reach the fallback deterministically.
  testWidgets('the CPU fallback paints every wave, in list order', (
    tester,
  ) async {
    const first = Color(0xFFE0217A);
    const second = Color(0xFF00A86B);
    const size = Size(100, 60);

    Future<Uint8List> renderFallback(List<Wave> waves) async {
      final clock = ValueNotifier<double>(0.0);
      addTearDown(clock.dispose);

      final bytes = await tester.runAsync<Uint8List>(() async {
        final recorder = ui.PictureRecorder();
        WaveFieldPainter(waves: waves, clock: clock, shader: null)
            .paint(Canvas(recorder), size);
        final picture = recorder.endRecording();
        final image = await picture.toImage(
          size.width.toInt(),
          size.height.toInt(),
        );
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        picture.dispose();
        return data!.buffer.asUint8List();
      });
      return bytes!;
    }

    bool hasColour(Uint8List rgba, Color colour) {
      for (var i = 0; i + 3 < rgba.length; i += 4) {
        if (rgba[i] == (colour.r * 255).round() &&
            rgba[i + 1] == (colour.g * 255).round() &&
            rgba[i + 2] == (colour.b * 255).round()) {
          return true;
        }
      }
      return false;
    }

    // Every wave's path closes down to the bottom edge, so the bottom row is
    // covered by all of them — the colour surviving there was drawn last.
    Color bottomCentre(Uint8List rgba) {
      final offset = ((59 * 100) + 50) * 4;
      return Color.fromARGB(
        rgba[offset + 3],
        rgba[offset],
        rgba[offset + 1],
        rgba[offset + 2],
      );
    }

    final ordered = await renderFallback([
      waveWith(first, amplitude: 0.2),
      waveWith(second, amplitude: 0.05),
    ]);

    // Never-blank: with no shader at all, both waves still reach the canvas.
    expect(hasColour(ordered, first), isTrue);
    expect(hasColour(ordered, second), isTrue);
    expect(
      bottomCentre(ordered),
      second,
      reason: 'the last wave in the list must paint in front',
    );

    final reversed = await renderFallback([
      waveWith(second, amplitude: 0.2),
      waveWith(first, amplitude: 0.05),
    ]);
    expect(
      bottomCentre(reversed),
      first,
      reason: 'reversing the list must reverse which wave paints in front',
    );
  });
}
