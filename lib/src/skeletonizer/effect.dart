import 'package:flutter/material.dart';

@immutable
abstract class SkeletonizerEffect {
  final double lowerBound;
  final double upperBound;
  final bool reverse;
  final Duration duration;

  const SkeletonizerEffect({
    this.reverse = false,
    this.lowerBound = 0.0,
    this.upperBound = 1.0,
    required this.duration,
  });

  Paint createPaint(double t, Rect rect, TextDirection? textDirection);

  SkeletonizerEffect lerp(SkeletonizerEffect? other, double t);
}