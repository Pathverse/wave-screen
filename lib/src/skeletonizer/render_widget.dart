import 'package:flutter/widgets.dart';
import 'package:skeletonizer/skeletonizer.dart' as ext;

import 'effect.dart';
import 'render_object.dart';

class WaveSkeletonizerRenderObjectWidget extends SingleChildRenderObjectWidget {
  const WaveSkeletonizerRenderObjectWidget({
    super.key,
    required super.child,
    required this.animationValue,
    required this.textDirection,
    required this.config,
    required this.ignorePointers,
    required this.isZone,
    required this.effect,
  });

  final double animationValue;
  final TextDirection textDirection;
  final ext.SkeletonizerConfigData config;
  final bool ignorePointers;
  final bool isZone;
  final SkeletonizerEffect effect;

  @override
  RenderWaveSkeletonizer createRenderObject(BuildContext context) {
    return RenderWaveSkeletonizer(
      animationValue: animationValue,
      textDirection: textDirection,
      config: config,
      ignorePointers: ignorePointers,
      isZone: isZone,
      effect: effect,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderWaveSkeletonizer renderObject) {
    renderObject
      ..animationValue = animationValue
      ..textDirection = textDirection
      ..config = config
      ..ignorePointers = ignorePointers
      ..isZone = isZone
      ..effect = effect;
  }
}