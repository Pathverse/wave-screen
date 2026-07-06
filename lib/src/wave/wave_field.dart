import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'shader/wave_shader.dart';
import 'wave.dart';
import 'wave_field_painter.dart';

/// Composites a list of [Wave] layers into a single animated surface. Rendering
/// runs on the GPU via the wave fragment shader; a CPU path is used as a fallback
/// until (or unless) the shader loads, so the field never blanks.
class WaveField extends StatefulWidget {
  final List<Wave> waves;

  const WaveField({super.key, required this.waves});

  @override
  State<WaveField> createState() => _WaveFieldState();
}

class _WaveFieldState extends State<WaveField>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _clock = ValueNotifier<double>(0.0);
  late final Ticker _ticker;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _loadShader();
  }

  void _onTick(Duration elapsed) {
    _clock.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
  }

  Future<void> _loadShader() async {
    final program = await WaveShaderLoader.load();
    if (!mounted || program == null) {
      return;
    }
    setState(() => _shader = program.fragmentShader());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: WaveFieldPainter(
          waves: widget.waves,
          clock: _clock,
          shader: _shader,
        ),
      ),
    );
  }
}
