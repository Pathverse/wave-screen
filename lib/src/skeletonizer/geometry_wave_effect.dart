import 'package:flutter/material.dart';

import 'config.dart';
import 'effect.dart';
import 'wave_geometry.dart';

@immutable
abstract class GeometryWaveEffect extends SkeletonizerEffect {
  final WaveDeformation deformation;
  final WaveSynchronization synchronization;

  const GeometryWaveEffect({
    required super.duration,
    required this.deformation,
    required this.synchronization,
    super.lowerBound = 0,
    super.upperBound = 1,
    super.reverse = false,
  });

  double resolvedAmplitude(Rect rect);

  double resolvedFrequency(Rect rect);

  double sampleOffset({
    required Rect rect,
    required double x,
    required double progress,
    required double phase,
  }) {
    return WaveGeometry.waveOffset(
      x: x,
      width: rect.width,
      amplitude: resolvedAmplitude(rect),
      frequency: resolvedFrequency(rect),
      progress: progress,
      synchronization: synchronization,
      phase: phase,
    );
  }

  Path buildPath({
    required Rect rect,
    required Radius radius,
    required double progress,
    required double phase,
  }) {
    return WaveGeometry.buildRectPath(
      rect: rect,
      radius: radius,
      progress: progress,
      amplitude: resolvedAmplitude(rect),
      frequency: resolvedFrequency(rect),
      deformation: deformation,
      synchronization: synchronization,
      phase: phase,
    );
  }
}