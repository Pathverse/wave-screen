import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'pointer_ripple_effect.dart';
import 'ripple_field.dart';
import 'shader/wave_shader.dart';
import 'wave.dart';
import 'wave_field_painter.dart';

/// Composites a list of [Wave] layers into a single animated surface. Rendering
/// runs on the GPU via the wave fragment shader; a CPU path is used as a fallback
/// so the field never blanks. When any wave carries a [PointerRippleEffect] the
/// field becomes interactive: taps and drags spawn ripples that displace the
/// surface, reported through [onRipple] as a normalized position.
class WaveField extends StatefulWidget {
  final List<Wave> waves;
  final ValueChanged<Offset>? onRipple;

  const WaveField({super.key, required this.waves, this.onRipple});

  @override
  State<WaveField> createState() => _WaveFieldState();
}

class _WaveFieldState extends State<WaveField>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _clock = ValueNotifier<double>(0.0);
  late final Ticker _ticker;
  ui.FragmentShader? _shader;
  RippleField? _rippleField;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _rippleField = _buildRippleField();
    _loadShader();
  }

  @override
  void didUpdateWidget(covariant WaveField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waves != widget.waves) {
      _rippleField = _buildRippleField();
    }
  }

  RippleField? _buildRippleField() {
    for (final wave in widget.waves) {
      for (final effect in wave.effects) {
        if (effect is PointerRippleEffect) {
          return RippleField(effect);
        }
      }
    }
    return null;
  }

  void _onTick(Duration elapsed) {
    _clock.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _rippleField?.prune(_clock.value);
  }

  Future<void> _loadShader() async {
    final program = await WaveShaderLoader.load();
    if (!mounted || program == null) {
      return;
    }
    setState(() => _shader = program.fragmentShader());
  }

  void _emitRipple(Offset local, Size size) {
    final field = _rippleField;
    if (field == null || size.isEmpty) {
      return;
    }
    final normalized = Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    );
    field.spawn(normalized.dx, _clock.value);
    widget.onRipple?.call(normalized);
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
    final content = RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: WaveFieldPainter(
          waves: widget.waves,
          clock: _clock,
          shader: _shader,
          rippleField: _rippleField,
        ),
      ),
    );

    if (_rippleField == null) {
      return content;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => _emitRipple(event.localPosition, size),
          onPointerMove: (event) => _emitRipple(event.localPosition, size),
          child: content,
        );
      },
    );
  }
}
