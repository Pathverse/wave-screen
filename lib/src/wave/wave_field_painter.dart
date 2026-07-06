import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'shader/wave_uniforms.dart';
import 'wave.dart';

/// Paints composited wave layers each frame, driven by [clock]. Uses the GPU
/// [shader] when available and a CPU path otherwise, so the surface never blanks.
class WaveFieldPainter extends CustomPainter {
  final List<Wave> waves;
  final ValueNotifier<double> clock;
  final ui.FragmentShader? shader;

  WaveFieldPainter({
    required this.waves,
    required this.clock,
    required this.shader,
  }) : super(repaint: clock);

  static const int _cpuSamples = 96;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    final activeShader = shader;
    if (activeShader != null) {
      WaveUniforms.apply(activeShader, size: size, waves: waves, t: t);
      canvas.drawRect(Offset.zero & size, Paint()..shader = activeShader);
      return;
    }
    _paintCpuFallback(canvas, size, t);
  }

  void _paintCpuFallback(Canvas canvas, Size size, double t) {
    for (final wave in waves) {
      final baseline = wave.shape.baseline;
      final path = Path()..moveTo(0, size.height);
      for (var s = 0; s <= _cpuSamples; s++) {
        final x = s / _cpuSamples;
        final crest = (baseline + wave.heightAt(x, t)) * size.height;
        path.lineTo(x * size.width, crest);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = wave.style.resolvedColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveFieldPainter oldDelegate) =>
      oldDelegate.waves != waves || oldDelegate.shader != shader;
}
