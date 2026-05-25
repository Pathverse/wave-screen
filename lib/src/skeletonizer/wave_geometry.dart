import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'config.dart';

typedef WaveOffsetSampler = double Function(double x);

const double _travelingWavePhaseBiasScale = 0.08;

class WaveGeometry {
  static Path buildRectPath({
    required Rect rect,
    required Radius radius,
    required double progress,
    required double amplitude,
    required double frequency,
    required WaveDeformation deformation,
    required WaveSynchronization synchronization,
    required double phase,
  }) {
    final resolvedRadius = math.min(radius.x, rect.height / 2);
    final topPhase = _phase(progress, synchronization, phase);
    final bottomPhase = deformation == WaveDeformation.fullOutline
        ? topPhase + math.pi / 3
        : topPhase;
    return _buildPath(
      rect: rect,
      radius: resolvedRadius,
      deformation: deformation,
      topOffset: (x) => _offset(
        x: x,
        width: rect.width,
        amplitude: amplitude,
        frequency: frequency,
        phase: topPhase,
      ),
      bottomOffset: (x) => _offset(
        x: x,
        width: rect.width,
        amplitude: amplitude,
        frequency: frequency,
        phase: bottomPhase,
      ),
    );
  }

  static Path buildTravelingRectPath({
    required Rect rect,
    required Radius radius,
    required double progress,
    required double amplitude,
    required double frequency,
    required double spread,
    required WaveDeformation deformation,
    required WaveSynchronization synchronization,
    required double phase,
  }) {
    final resolvedRadius = math.min(radius.x, rect.height / 2);
    final centerX = rect.left + (rect.width * progress);
    final phaseShift = synchronization == WaveSynchronization.global
        ? 0.0
        : phase * math.pi * 2;
    return _buildPath(
      rect: rect,
      radius: resolvedRadius,
      deformation: deformation,
      topOffset: (x) => travelingWaveOffset(
        x: x,
        width: rect.width,
        centerX: centerX,
        amplitude: amplitude,
        frequency: frequency,
        spread: spread,
        phase: phaseShift,
      ),
      bottomOffset: (x) => travelingWaveOffset(
        x: x,
        width: rect.width,
        centerX: centerX,
        amplitude: amplitude,
        frequency: frequency,
        spread: spread,
        phase: phaseShift + (math.pi / 3),
      ),
    );
  }

  static Path buildSampledRectPath({
    required Rect rect,
    required Radius radius,
    required WaveDeformation deformation,
    required WaveOffsetSampler topOffset,
    required WaveOffsetSampler bottomOffset,
  }) {
    final resolvedRadius = math.min(radius.x, rect.height / 2);
    return _buildPath(
      rect: rect,
      radius: resolvedRadius,
      deformation: deformation,
      topOffset: topOffset,
      bottomOffset: bottomOffset,
    );
  }

  static double waveOffset({
    required double x,
    required double width,
    required double amplitude,
    required double frequency,
    required double progress,
    required WaveSynchronization synchronization,
    required double phase,
  }) {
    return _offset(
      x: x,
      width: width,
      amplitude: amplitude,
      frequency: frequency,
      phase: _phase(progress, synchronization, phase),
    );
  }

  static double travelingWaveOffset({
    required double x,
    required double width,
    required double centerX,
    required double amplitude,
    required double frequency,
    required double spread,
    required double phase,
  }) {
    if (width == 0 || spread <= 0 || amplitude <= 0) {
      return 0;
    }

    final distance = (x - centerX) / width;
    final normalizedDistance = distance.abs() / spread;
    if (normalizedDistance >= 1) {
      return 0;
    }

    final envelope = 1 - _smoothStep(normalizedDistance);
    final sharpness = 1 + ((frequency.abs() - 1).clamp(0.0, 1.5) * 0.35);
    final edgeBump = _edgeBump(normalizedDistance, frequency);
    final phaseBias = 1 + (math.sin(phase) * _travelingWavePhaseBiasScale);
    final profile = math.max(0.0, math.pow(envelope, sharpness).toDouble() + edgeBump);
    return -amplitude * profile * phaseBias;
  }

  static double _smoothStep(double value) {
    final clamped = value.clamp(0.0, 1.0);
    return clamped * clamped * (3 - (2 * clamped));
  }

  static double _edgeBump(double normalizedDistance, double frequency) {
    if (normalizedDistance <= 0.58 || normalizedDistance >= 1) {
      return 0;
    }

    final rippleDistance = (normalizedDistance - 0.58) / 0.42;
    final window = math.sin(rippleDistance * math.pi);
    final ripple = math.sin(
      ((rippleDistance * (1.15 + (frequency.abs() * 0.15))) - 0.2) * math.pi,
    );
    return math.max(0.0, window * ripple) * 0.12;
  }

  static Iterable<Offset> _topPoints(
    Rect rect,
    double radius,
    int sampleCount,
    WaveOffsetSampler offset,
  ) sync* {
    for (int index = 1; index <= sampleCount; index++) {
      final x = rect.left + radius + ((rect.width - (radius * 2)) * index / sampleCount);
      yield Offset(x, rect.top + offset(x));
    }
  }

  static Iterable<Offset> _bottomPoints(
    Rect rect,
    double radius,
    int sampleCount,
    WaveOffsetSampler offset,
  ) sync* {
    for (int index = sampleCount; index >= 0; index--) {
      final x = rect.left + radius + ((rect.width - (radius * 2)) * index / sampleCount);
      yield Offset(x, rect.bottom + offset(x));
    }
  }

  static Path _buildPath({
    required Rect rect,
    required double radius,
    required WaveDeformation deformation,
    required WaveOffsetSampler topOffset,
    required WaveOffsetSampler bottomOffset,
  }) {
    final sampleCount = math.max(24, (rect.width / 8).round());
    final path = Path();
    path.moveTo(rect.left + radius, rect.top + topOffset(rect.left + radius));

    for (final point in _topPoints(rect, radius, sampleCount, topOffset)) {
      path.lineTo(point.dx, point.dy);
    }

    path.quadraticBezierTo(
      rect.right,
      rect.top + topOffset(rect.right),
      rect.right,
      rect.top + radius,
    );

    if (deformation == WaveDeformation.topEdge) {
      path.lineTo(rect.right, rect.bottom - radius);
      path.quadraticBezierTo(rect.right, rect.bottom, rect.right - radius, rect.bottom);
      path.lineTo(rect.left + radius, rect.bottom);
      path.quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - radius);
      path.lineTo(rect.left, rect.top + radius);
    } else {
      path.lineTo(rect.right, rect.bottom - radius);
      path.quadraticBezierTo(
        rect.right,
        rect.bottom + bottomOffset(rect.right),
        rect.right - radius,
        rect.bottom + bottomOffset(rect.right - radius),
      );

      for (final point in _bottomPoints(rect, radius, sampleCount, bottomOffset)) {
        path.lineTo(point.dx, point.dy);
      }

      path.quadraticBezierTo(
        rect.left,
        rect.bottom + bottomOffset(rect.left),
        rect.left,
        rect.bottom - radius,
      );
      path.lineTo(rect.left, rect.top + radius);
    }

    path.quadraticBezierTo(
      rect.left,
      rect.top,
      rect.left + radius,
      rect.top + topOffset(rect.left + radius),
    );
    path.close();
    return path;
  }

  static double _phase(
    double progress,
    WaveSynchronization synchronization,
    double phase,
  ) {
    return synchronization == WaveSynchronization.global
        ? progress * math.pi * 2
        : (progress * math.pi * 2) + (phase * math.pi * 2);
  }

  static double _offset({
    required double x,
    required double width,
    required double amplitude,
    required double frequency,
    required double phase,
  }) {
    final normalized = width == 0 ? 0.0 : x / width;
    final baseWave = math.sin((normalized * math.pi * 2 * frequency) + phase);
    final harmonic = math.cos((normalized * math.pi * 2 * (frequency * 0.5)) - (phase * 1.3));
    return ((baseWave * 0.72) + (harmonic * 0.28)) * amplitude;
  }
}