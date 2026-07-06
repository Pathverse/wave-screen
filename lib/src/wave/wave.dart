import 'package:flutter/foundation.dart';

import 'wave_effect.dart';
import 'wave_motion.dart';
import 'wave_shape.dart';
import 'wave_style.dart';

/// A single wave surface, described entirely by swappable traits:
/// [shape] (geometry), [style] (appearance), [motion] (time evolution), and
/// composable [effects]. Compose several [Wave]s in a `WaveField` to build a
/// layered scene.
@immutable
class Wave {
  final WaveShape shape;
  final WaveStyle style;
  final WaveMotion motion;
  final List<WaveEffect> effects;

  const Wave({
    required this.shape,
    required this.style,
    required this.motion,
    this.effects = const <WaveEffect>[],
  });

  /// The composed surface height at normalized [x] in `[0, 1]` and time [t]
  /// (seconds): the [shape] sampled with the phase the [motion] supplies at [t].
  double heightAt(double x, double t) => shape.sampleAt(x, motion.phaseAt(t));

  @override
  bool operator ==(Object other) =>
      other is Wave &&
      other.shape == shape &&
      other.style == style &&
      other.motion == motion &&
      listEquals(other.effects, effects);

  @override
  int get hashCode =>
      Object.hash(shape, style, motion, Object.hashAll(effects));
}
