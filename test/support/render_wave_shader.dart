import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:wave_screen/src/wave/ripple_field.dart';
import 'package:wave_screen/src/wave/shader/wave_shader.dart';
import 'package:wave_screen/src/wave/shader/wave_uniforms.dart';
import 'package:wave_screen/wave_screen.dart';

Future<Uint8List> renderWaveShader({
  required List<Wave> waves,
  ui.Size size = const ui.Size(200, 120),
  double t = 0,
  RippleField? rippleField,
}) async {
  final program = await WaveShaderLoader.load();
  final shader = program!.fragmentShader();
  try {
    WaveUniforms.apply(
      shader,
      size: size,
      waves: waves,
      t: t,
      rippleField: rippleField,
    );
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
        .drawRect(ui.Offset.zero & size, ui.Paint()..shader = shader);
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        return data!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  } finally {
    shader.dispose();
  }
}
