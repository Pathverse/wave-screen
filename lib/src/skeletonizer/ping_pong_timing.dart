double _clampUnit(double value) {
  return value.clamp(0.0, 1.0).toDouble();
}

class PingPongTimingProfile {
  static const List<double> outboundFrameDurations = <double>[
    120,
    110,
    100,
    90,
    80,
    70,
  ];

  static const double impactFrameDuration = 140;

  static const List<double> returnFrameDurations = <double>[
    90,
    100,
    120,
    140,
    170,
    220,
  ];

  const PingPongTimingProfile();

  double outbound(double value) {
    return _mapSegmentProgress(_clampUnit(value), outboundFrameDurations);
  }

  double reflectedReturn(double value) {
    return _mapSegmentProgress(_clampUnit(value), returnFrameDurations);
  }

  static double _mapSegmentProgress(double value, List<double> frameDurations) {
    if (frameDurations.isEmpty) {
      return value;
    }
    if (value <= 0) {
      return 0;
    }
    if (value >= 1) {
      return 1;
    }

    final totalDuration = frameDurations.fold<double>(0, (sum, item) => sum + item);
    final targetDuration = totalDuration * value;
    final stepSize = 1 / frameDurations.length;
    var elapsed = 0.0;

    for (var index = 0; index < frameDurations.length; index++) {
      final frameDuration = frameDurations[index];
      final nextElapsed = elapsed + frameDuration;
      if (targetDuration <= nextElapsed) {
        final localDuration = targetDuration - elapsed;
        final frameT = frameDuration == 0 ? 0.0 : localDuration / frameDuration;
        return ((index + frameT) * stepSize).clamp(0.0, 1.0).toDouble();
      }
      elapsed = nextElapsed;
    }

    return 1;
  }
}