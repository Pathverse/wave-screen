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
    if (activeShader != null && _paintShader(canvas, size, t, activeShader)) {
      return;
    }
    _paintCpuFallback(canvas, size, t);
  }

  /// Paints via the GPU shader. Returns `false` (so the caller falls back to the
  /// CPU path) if the shader's uniform layout does not match what we write —
  /// e.g. a stale compiled shader from an older uniform layout. Degrading is far
  /// better than crash-flooding every frame.
  bool _paintShader(Canvas canvas, Size size, double t, ui.FragmentShader s) {
    try {
      WaveUniforms.apply(s, size: size, waves: waves, t: t);
    } on Error {
      return false;
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = s);
    return true;
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
