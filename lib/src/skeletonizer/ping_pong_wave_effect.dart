import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'effect.dart';
import 'geometry_wave_effect.dart';
import 'ping_pong_timing.dart';
import 'wave_geometry.dart';

List<double> _lerpStops(List<double> left, List<double> right, double t) {
  return List<double>.generate(left.length, (index) {
    return lerpDouble(left[index], right[index], t)!;
  }, growable: false);
}

const double _progressEpsilon = 1e-9;

Duration _lerpDuration(Duration left, Duration right, double t) {
  final milliseconds = lerpDouble(
    left.inMilliseconds.toDouble(),
    right.inMilliseconds.toDouble(),
    t,
  )!;
  return Duration(milliseconds: milliseconds.round());
}

double _smoothStep(double value) {
  final clamped = value.clamp(0.0, 1.0);
  return clamped * clamped * (3 - (2 * clamped));
}

double _lerpValue(double begin, double end, double t) {
  return begin + ((end - begin) * t);
}

const PingPongTimingProfile _timingProfile = PingPongTimingProfile();

@immutable
class PingPongWaveEffect extends GeometryWaveEffect {
  final Color baseColor;
  final Color highlightColor;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final TileMode tileMode;
  final double spread;
  final double amplitudeFactor;
  final double frequency;
  final Duration pauseDuration;

  const PingPongWaveEffect({
    this.baseColor = const Color(0xFFF24B5A),
    this.highlightColor = const Color(0xFFFF97A0),
    super.deformation = WaveDeformation.topEdge,
    super.synchronization = WaveSynchronization.global,
    this.begin = const AlignmentDirectional(-0.8, 0),
    this.end = const AlignmentDirectional(0.8, 0),
    this.stops = const [0.22, 0.5, 0.78],
    this.tileMode = TileMode.clamp,
    this.spread = 0.18,
    this.amplitudeFactor = 0.26,
    this.frequency = 1.15,
    this.pauseDuration = const Duration(seconds: 2),
    super.lowerBound = 0,
    super.upperBound = 1,
    super.reverse = false,
    super.duration = const Duration(seconds: 5),
  });

  List<Color> get colors => [baseColor, highlightColor, baseColor];

  double get _impactFraction {
    final totalMillis = duration.inMilliseconds;
    if (totalMillis <= 0) {
      return 0;
    }

    return (pauseDuration.inMilliseconds.clamp(0, totalMillis) / totalMillis)
        .toDouble();
  }

  double get _travelFraction {
    return math.max(0, (1 - _impactFraction) / 2).toDouble();
  }

  double _normalizedProgress(double cycleProgress) {
    return cycleProgress.clamp(lowerBound, upperBound).toDouble();
  }

  double get _impactStart => lowerBound + _travelFraction;

  double get _impactEnd => upperBound - _travelFraction;

  double outboundProgress(double cycleProgress) {
    final normalized = _normalizedProgress(cycleProgress);
    if (_travelFraction <= _progressEpsilon) {
      return 1;
    }
    if (normalized >= _impactStart) {
      return 1;
    }

    return _timingProfile.outbound((normalized - lowerBound) / _travelFraction);
  }

  double impactProgress(double cycleProgress) {
    final normalized = _normalizedProgress(cycleProgress);
    final width = _impactEnd - _impactStart;
    if (width <= _progressEpsilon ||
        normalized <= _impactStart ||
        normalized >= _impactEnd) {
      return 0;
    }

    final t = (normalized - _impactStart) / width;
    return math.sin(t * math.pi).abs();
  }

  double reflectionProgress(double cycleProgress) {
    final normalized = _normalizedProgress(cycleProgress);
    final width = _impactEnd - _impactStart;
    if (normalized <= _impactStart || width <= _progressEpsilon) {
      return 0;
    }
    if (normalized >= _impactEnd) {
      return 1;
    }

    return _smoothStep((normalized - _impactStart) / width);
  }

  double returnProgress(double cycleProgress) {
    final normalized = _normalizedProgress(cycleProgress);
    if (_travelFraction <= _progressEpsilon || normalized <= _impactEnd) {
      return 0;
    }

    return _timingProfile.reflectedReturn(
      (normalized - _impactEnd) / _travelFraction,
    );
  }

  double outgoingCenterProgress(double cycleProgress) {
    return outboundProgress(cycleProgress);
  }

  double reflectedCenterProgress(double cycleProgress) {
    final returning = returnProgress(cycleProgress);
    if (returning <= 0) {
      return 1;
    }

    return 1 - returning;
  }

  double centerProgress(double cycleProgress) {
    final returning = returnProgress(cycleProgress);
    if (returning > 0) {
      return reflectedCenterProgress(cycleProgress);
    }
    if (reflectionProgress(cycleProgress) > 0) {
      return 1;
    }

    return outgoingCenterProgress(cycleProgress);
  }

  double visibilityProgress(double cycleProgress) {
    return 1;
  }

  double crestAmplitudeProgress(double cycleProgress) {
    final outgoing = outboundProgress(cycleProgress);
    final impact = impactProgress(cycleProgress);
    final returning = returnProgress(cycleProgress);
    if (returning > 0) {
      return 0.88 - (0.38 * returning);
    }

    return 0.58 + (outgoing * 0.42) + (impact * 0.18);
  }

  double outgoingWaveMix(double cycleProgress) {
    final returning = returnProgress(cycleProgress);
    if (returning > 0) {
      return 0.26 * (1 - returning);
    }

    return 0.62 + (0.38 * outboundProgress(cycleProgress));
  }

  double reflectedWaveMix(double cycleProgress) {
    final reflection = reflectionProgress(cycleProgress);
    if (reflection <= 0) {
      return 0;
    }

    final returning = returnProgress(cycleProgress);
    if (returning > 0) {
      return 0.82 - (0.32 * returning);
    }

    return 0.24 + (reflection * 0.52);
  }

  double wallRippleMix(double cycleProgress) {
    final impact = impactProgress(cycleProgress);
    if (impact > 0) {
      return 0.24 + (impact * 0.34);
    }

    final returning = returnProgress(cycleProgress);
    if (returning <= 0) {
      return 0;
    }

    return 0.36 * (1 - (0.6 * returning));
  }

  double _phaseShift(double phase) {
    if (synchronization == WaveSynchronization.global) {
      return 0;
    }

    return phase * math.pi * 2;
  }

  double _wallRippleOffset({
    required Rect rect,
    required double x,
    required double cycleProgress,
    required double phaseShift,
    required double amplitude,
  }) {
    final rippleMix = wallRippleMix(cycleProgress);
    if (rippleMix <= 0 || rect.width <= 0) {
      return 0;
    }

    final rippleReach = math.max(spread * 1.35, 0.16);
    final normalizedFromWall = (rect.right - x) / rect.width;
    if (normalizedFromWall < 0 || normalizedFromWall >= rippleReach) {
      return 0;
    }

    final distanceT = normalizedFromWall / rippleReach;
    final envelope = 1 - _smoothStep(distanceT);
    final travelPhase = impactProgress(cycleProgress) > 0
        ? impactProgress(cycleProgress)
        : 1 + returnProgress(cycleProgress);
    final ripple = math.sin(
      ((1 - distanceT) * math.pi * 3.6) - (travelPhase * math.pi * 1.4) + phaseShift,
    );
    final crest = math.max(0.0, ripple);
    return -amplitude * rippleMix * envelope * crest;
  }

  double _sampleCompositeOffset({
    required Rect rect,
    required double x,
    required double progress,
    required double phaseShift,
  }) {
    final amplitude = resolvedAmplitude(rect) * crestAmplitudeProgress(progress);
    final outgoing = WaveGeometry.travelingWaveOffset(
      x: x,
      width: rect.width,
      centerX: rect.left + (rect.width * outgoingCenterProgress(progress)),
      amplitude: amplitude * outgoingWaveMix(progress),
      frequency: resolvedFrequency(rect),
      spread: _lerpValue(spread * 0.7, spread * 1.05, outboundProgress(progress)),
      phase: phaseShift,
    );
    final reflected = WaveGeometry.travelingWaveOffset(
      x: x,
      width: rect.width,
      centerX: rect.left + (rect.width * reflectedCenterProgress(progress)),
      amplitude: amplitude * reflectedWaveMix(progress),
      frequency: resolvedFrequency(rect) * 1.08,
      spread: math.max(spread * 0.85, 0.12),
      phase: phaseShift + (math.pi / 5),
    );
    final wall = _wallRippleOffset(
      rect: rect,
      x: x,
      cycleProgress: progress,
      phaseShift: phaseShift,
      amplitude: amplitude,
    );
    return outgoing + reflected + wall;
  }

  @override
  Paint createPaint(double t, Rect rect, TextDirection? textDirection) {
    final visibility = visibilityProgress(t);
    if (visibility == 0) {
      return Paint()..color = baseColor;
    }

    final progress = centerProgress(t);
    return Paint()
      ..shader = LinearGradient(
        colors: colors,
        stops: stops,
        begin: begin,
        end: end,
        tileMode: tileMode,
        transform: _PingPongGradientTransform(offset: progress),
      ).createShader(rect, textDirection: textDirection);
  }

  @override
  double resolvedAmplitude(Rect rect) => rect.height * amplitudeFactor;

  @override
  double resolvedFrequency(Rect rect) => frequency;

  @override
  double sampleOffset({
    required Rect rect,
    required double x,
    required double progress,
    required double phase,
  }) {
    return _sampleCompositeOffset(
      rect: rect,
      x: x,
      progress: progress,
      phaseShift: _phaseShift(phase),
    );
  }

  @override
  Path buildPath({
    required Rect rect,
    required Radius radius,
    required double progress,
    required double phase,
  }) {
    final phaseShift = _phaseShift(phase);
    return WaveGeometry.buildSampledRectPath(
      rect: rect,
      radius: radius,
      deformation: deformation,
      topOffset: (x) => _sampleCompositeOffset(
        rect: rect,
        x: x,
        progress: progress,
        phaseShift: phaseShift,
      ),
      bottomOffset: (x) => _sampleCompositeOffset(
        rect: rect,
        x: x,
        progress: progress,
        phaseShift: phaseShift + (math.pi / 3),
      ),
    );
  }

  @override
  PingPongWaveEffect lerp(SkeletonizerEffect? other, double t) {
    if (other is! PingPongWaveEffect) {
      return this;
    }

    return PingPongWaveEffect(
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
      spread: lerpDouble(spread, other.spread, t)!,
      amplitudeFactor: lerpDouble(amplitudeFactor, other.amplitudeFactor, t)!,
      frequency: lerpDouble(frequency, other.frequency, t)!,
      pauseDuration: _lerpDuration(pauseDuration, other.pauseDuration, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PingPongWaveEffect &&
            baseColor == other.baseColor &&
            highlightColor == other.highlightColor &&
            deformation == other.deformation &&
            synchronization == other.synchronization &&
            begin == other.begin &&
            end == other.end &&
            listEquals(stops, other.stops) &&
            tileMode == other.tileMode &&
            spread == other.spread &&
            amplitudeFactor == other.amplitudeFactor &&
            frequency == other.frequency &&
            pauseDuration == other.pauseDuration &&
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
      spread,
      amplitudeFactor,
      frequency,
      pauseDuration,
      lowerBound,
      upperBound,
      reverse,
      duration,
    );
  }
}

class _PingPongGradientTransform extends GradientTransform {
  final double offset;

  const _PingPongGradientTransform({required this.offset});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final horizontalShift = bounds.width * ((offset - 0.5) * 0.7);
    return Matrix4.translationValues(horizontalShift, 0, 0);
  }
}