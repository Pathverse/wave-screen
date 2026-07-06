import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../wave/wave.dart';

/// A named, curated arrangement of a background and a stack of [Wave] layers,
/// consumed by `WaveScreen` and produced by `WavePresets`.
@immutable
class WaveScreenPreset {
  final List<Wave> waves;
  final Gradient? background;
  final Color? backgroundColor;

  const WaveScreenPreset({
    required this.waves,
    this.background,
    this.backgroundColor,
  });
}
