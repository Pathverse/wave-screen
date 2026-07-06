import 'package:flutter/widgets.dart';

import '../wave/wave.dart';
import '../wave/wave_field.dart';
import 'wave_screen_preset.dart';

/// A full-bleed animated wave background. Supply a curated [WaveScreenPreset] or
/// build one inline with [WaveScreen.custom]. An optional [child] is layered on
/// top of the waves.
class WaveScreen extends StatelessWidget {
  final WaveScreenPreset preset;
  final Widget? child;

  const WaveScreen({super.key, required this.preset, this.child});

  /// Build a screen from loose waves without naming a preset.
  WaveScreen.custom({
    super.key,
    required List<Wave> waves,
    Gradient? background,
    Color? backgroundColor,
    this.child,
  }) : preset = WaveScreenPreset(
         waves: waves,
         background: background,
         backgroundColor: backgroundColor,
       );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: preset.backgroundColor,
        gradient: preset.background,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          WaveField(waves: preset.waves),
          ?child,
        ],
      ),
    );
  }
}
