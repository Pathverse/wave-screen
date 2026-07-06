import 'pointer_ripple_effect.dart';

/// Accumulates the live ripples spawned by pointer interaction and sums their
/// displacement. Pure Dart (no widgets) so it is unit-testable on its own.
class RippleField {
  final PointerRippleEffect effect;
  final List<_ActiveRipple> _ripples = <_ActiveRipple>[];

  RippleField(this.effect);

  /// Spawn a ripple originating at normalized [originX] at time [now] (seconds).
  void spawn(double originX, double now) {
    _ripples.add(_ActiveRipple(originX, now));
  }

  /// Total displacement at normalized [x] at time [now], summed over all live
  /// ripples.
  double displacementAt(double x, double now) {
    var sum = 0.0;
    for (final ripple in _ripples) {
      sum += effect.displacementAt(
        x: x,
        originX: ripple.originX,
        age: now - ripple.startTime,
      );
    }
    return sum;
  }

  /// Drop ripples whose amplitude has decayed below usefulness by [now].
  void prune(double now) {
    _ripples.removeWhere((r) => (now - r.startTime) > effect.lifetime);
  }

  bool get isEmpty => _ripples.isEmpty;

  int get activeCount => _ripples.length;

  /// The most recent live ripples, up to [limit], newest last.
  List<({double originX, double startTime})> recent(int limit) {
    final start = _ripples.length > limit ? _ripples.length - limit : 0;
    return [
      for (var i = start; i < _ripples.length; i++)
        (originX: _ripples[i].originX, startTime: _ripples[i].startTime),
    ];
  }
}

class _ActiveRipple {
  final double originX;
  final double startTime;

  const _ActiveRipple(this.originX, this.startTime);
}
