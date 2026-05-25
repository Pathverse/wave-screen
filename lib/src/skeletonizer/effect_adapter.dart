import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart' as ext;

import 'effect.dart';

@immutable
class SkeletonizerEffectAdapter extends ext.PaintingEffect {
  final SkeletonizerEffect effect;

  SkeletonizerEffectAdapter(this.effect)
    : super(
        duration: effect.duration,
        lowerBound: effect.lowerBound,
        upperBound: effect.upperBound,
        reverse: effect.reverse,
      );

  @override
  Paint createPaint(double t, Rect rect, TextDirection? textDirection) {
    return effect.createPaint(t, rect, textDirection);
  }

  @override
  ext.PaintingEffect lerp(ext.PaintingEffect? other, double t) {
    if (other is! SkeletonizerEffectAdapter) {
      return this;
    }

    return SkeletonizerEffectAdapter(effect.lerp(other.effect, t));
  }
}