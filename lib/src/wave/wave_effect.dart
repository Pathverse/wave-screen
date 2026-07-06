import 'package:flutter/foundation.dart';

/// A composable overlay applied to a wave — interaction (pointer ripples) or
/// decoration (foam). The effect system is fleshed out in a later milestone;
/// this base exists so [Wave] can already carry an (empty) effect list.
@immutable
abstract class WaveEffect {
  const WaveEffect();
}
