import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'effect.dart';
import 'geometry_wave_effect.dart';

@immutable
class WaveEffect extends GeometryWaveEffect {
  final Color baseColor;
  final Color highlightColor;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final TileMode tileMode;
  final double verticalDrift;

  const WaveEffect({
    this.baseColor = const Color(0xFF3844A8),
    this.highlightColor = const Color(0xFF89A6FF),
    super.deformation = WaveDeformation.topEdge,
    super.synchronization = WaveSynchronization.global,
    this.begin = const AlignmentDirectional(-1.1, -0.2),
    this.end = const AlignmentDirectional(1.1, 0.2),
    this.stops = const [0.08, 0.22, 0.36, 0.58, 0.84],
    this.tileMode = TileMode.clamp,
    this.verticalDrift = 0.1,
    super.lowerBound = -0.8,
    super.upperBound = 1.8,
    super.reverse = false,
    super.duration = const Duration(seconds: 9),
  });

  @override
  double resolvedAmplitude(Rect rect) => rect.height * 0.28;

  @override
  double resolvedFrequency(Rect rect) => rect.width > 180 ? 1.6 : 1.2;

  List<Color> get colors => [
    baseColor,
    Color.lerp(baseColor, highlightColor, 0.55)!,
    highlightColor,
    Color.lerp(baseColor, highlightColor, 0.45)!,
    baseColor,
  ];

  @override
  Paint createPaint(double t, Rect rect, TextDirection? textDirection) {
    return Paint()
      ..shader = LinearGradient(
        colors: colors,
        stops: stops,
        begin: begin,
        end: end,
        tileMode: tileMode,
        transform: _WaveGradientTransform(
          offset: t,
          verticalDrift: verticalDrift,
        ),
      ).createShader(rect, textDirection: textDirection);
  }

  @override
  WaveEffect lerp(SkeletonizerEffect? other, double t) {
    if (other is! WaveEffect) {
      return this;
    }

    return WaveEffect(
      duration: duration,
      lowerBound: lerpDouble(lowerBound, other.lowerBound, t)!,
      upperBound: lerpDouble(upperBound, other.upperBound, t)!,
      reverse: t <= 0.5 ? reverse : other.reverse,
      baseColor: Color.lerp(baseColor, other.baseColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      deformation: t <= 0.5 ? deformation : other.deformation,
      synchronization: t <= 0.5 ? synchronization : other.synchronization,
      begin: AlignmentGeometry.lerp(begin, other.begin, t)!,
      end: AlignmentGeometry.lerp(end, other.end, t)!,
      stops: _lerpStops(stops, other.stops, t),
      tileMode: t <= 0.5 ? tileMode : other.tileMode,
      verticalDrift: lerpDouble(verticalDrift, other.verticalDrift, t)!,
    );
  }

  static List<double> _lerpStops(List<double> left, List<double> right, double t) {
    return List<double>.generate(left.length, (index) {
      return lerpDouble(left[index], right[index], t)!;
    }, growable: false);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WaveEffect &&
            baseColor == other.baseColor &&
            highlightColor == other.highlightColor &&
          deformation == other.deformation &&
          synchronization == other.synchronization &&
            begin == other.begin &&
            end == other.end &&
            listEquals(stops, other.stops) &&
            tileMode == other.tileMode &&
            verticalDrift == other.verticalDrift &&
            lowerBound == other.lowerBound &&
            upperBound == other.upperBound &&
            reverse == other.reverse &&
            duration == other.duration;
  }

  @override
  int get hashCode {
    return Object.hash(
      baseColor,
      highlightColor,
      deformation,
      synchronization,
      begin,
      end,
      Object.hashAll(stops),
      tileMode,
      verticalDrift,
      lowerBound,
      upperBound,
      reverse,
      duration,
    );
  }
}

class _WaveGradientTransform extends GradientTransform {
  final double offset;
  final double verticalDrift;

  const _WaveGradientTransform({
    required this.offset,
    required this.verticalDrift,
  });

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final horizontalShift = bounds.width * offset;
    final verticalShift =
        bounds.height * (verticalDrift * 0.5) * (1 + math.sin(offset * math.pi));
    return Matrix4.translationValues(horizontalShift, verticalShift, 0.0);
  }
}