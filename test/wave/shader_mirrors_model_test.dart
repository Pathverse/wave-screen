import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';
import 'package:wave_screen/src/wave/shader/wave_shader.dart';
import 'package:wave_screen/src/wave/shader/wave_uniforms.dart';

/// The package's central architectural claim: the GLSL height field in
/// `shaders/wave.frag` mirrors the Dart `Wave.heightAt` model. Every other proof
/// asserts against the Dart model, so if the two ever drifted apart the whole
/// suite would be measuring something the GPU does not render.
///
/// Uniforms are applied and the rect drawn directly, so there is no painter
/// fallback anywhere in the path — these pixels are the shader's own output. The
/// shader fills where `uv.y > crest` through a smoothstep spanning ~1.5px, so
/// alpha crosses 50% exactly at the crest line, which is what is read back.
void main() {
  const width = 200;
  const height = 120;
  const size = Size(200, 120);

  Future<Uint8List?> renderThroughShader(WidgetTester tester, Wave wave) {
    return tester.runAsync<Uint8List>(() async {
      final program = await WaveShaderLoader.load();
      final shader = program!.fragmentShader();
      WaveUniforms.apply(shader, size: size, waves: [wave], t: 0.0);

      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(Offset.zero & size, Paint()..shader = shader);
      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      image.dispose();
      picture.dispose();
      shader.dispose();
      return data!.buffer.asUint8List();
    });
  }

  double? measuredCrest(Uint8List rgba, int column) {
    for (var row = 0; row < height; row++) {
      final alpha = rgba[(((row * width) + column) * 4) + 3];
      if (alpha >= 128) {
        return (row + 0.5) / height;
      }
    }
    return null;
  }

  final cases = <String, WaveShape>{
    'sine': WaveShape.sine(amplitude: 0.15, frequency: 1.0, baseline: 0.5),
    'gerstner': WaveShape.gerstner(
      amplitude: 0.15,
      frequency: 1.0,
      steepness: 0.9,
      baseline: 0.5,
    ),
    'metaball': WaveShape.metaball(
      blobCount: 3,
      amplitude: 0.18,
      radius: 0.15,
      baseline: 0.6,
    ),
  };

  cases.forEach((name, shape) {
    testWidgets('the shader renders the $name crest the Dart model computes', (
      tester,
    ) async {
      final wave = Wave(
        shape: shape,
        style: const WaveStyle(fill: Color(0xFFE0217A)),
        motion: WaveMotion.still(),
      );

      final rgba = await renderThroughShader(tester, wave);
      expect(rgba, isNotNull, reason: 'the shader must rasterize');

      for (final column in [0, 25, 50, 75, 100, 150, 199]) {
        final ux = (column + 0.5) / width;
        final expected = shape.baseline + wave.heightAt(ux, 0.0);
        final actual = measuredCrest(rgba!, column);

        expect(
          actual,
          isNotNull,
          reason: '$name: column $column must contain a crest edge',
        );
        expect(
          actual!,
          closeTo(expected, 2.0 / height),
          reason: '$name: at ux=$ux the shader crest must match Dart heightAt',
        );
      }
    });
  });
}
