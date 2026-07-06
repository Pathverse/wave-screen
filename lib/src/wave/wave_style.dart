import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The appearance trait of a wave: how the surface is filled. Kept independent
/// of geometry and motion so the same shape can be restyled freely.
@immutable
class WaveStyle {
  /// Solid fill colour of the wave body.
  final Color fill;

  /// Overall opacity multiplier applied to [fill], in `[0, 1]`.
  final double opacity;

  const WaveStyle({
    this.fill = const Color(0xFF3B2CC5),
    this.opacity = 1.0,
  }) : assert(opacity >= 0 && opacity <= 1, 'opacity must be within [0, 1].');

  /// The fill colour with [opacity] folded into its alpha channel.
  Color get resolvedColor => fill.withValues(alpha: fill.a * opacity);

  @override
  bool operator ==(Object other) =>
      other is WaveStyle && other.fill == fill && other.opacity == opacity;

  @override
  int get hashCode => Object.hash(fill, opacity);
}
