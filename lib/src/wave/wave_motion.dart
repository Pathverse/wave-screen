import 'package:flutter/foundation.dart';

/// How a wave surface evolves over time. A motion contributes a *phase* (in
/// radians) for a given time `t` (seconds); the shape turns that phase into a
/// height. This keeps time-evolution a swappable trait, independent of geometry.
@immutable
abstract class WaveMotion {
  const WaveMotion();

  /// A wave that travels: phase advances linearly with time at [speed]
  /// radians per second.
  const factory WaveMotion.drift({double speed}) = DriftMotion;

  /// A wave frozen in place: phase never advances.
  const factory WaveMotion.still() = StillMotion;

  /// The phase, in radians, contributed at time [t] (seconds).
  double phaseAt(double t);
}

/// Linear, endlessly travelling motion.
@immutable
class DriftMotion extends WaveMotion {
  final double speed;

  const DriftMotion({this.speed = 1.0});

  @override
  double phaseAt(double t) => speed * t;

  @override
  bool operator ==(Object other) =>
      other is DriftMotion && other.speed == speed;

  @override
  int get hashCode => speed.hashCode;
}

/// A wave that does not move.
@immutable
class StillMotion extends WaveMotion {
  const StillMotion();

  @override
  double phaseAt(double t) => 0.0;

  @override
  bool operator ==(Object other) => other is StillMotion;

  @override
  int get hashCode => 0;
}
