import 'package:flutter/rendering.dart';
import 'package:skeletonizer/skeletonizer.dart' as ext;

import 'effect.dart';
import 'painting.dart';

class RenderWaveSkeletonizer extends RenderProxyBox {
  RenderWaveSkeletonizer({
    required TextDirection textDirection,
    required double animationValue,
    required ext.SkeletonizerConfigData config,
    required bool ignorePointers,
    required bool isZone,
    required SkeletonizerEffect effect,
    RenderBox? child,
  }) : _textDirection = textDirection,
       _animationValue = animationValue,
       _config = config,
       _isZone = isZone,
       _ignorePointers = ignorePointers,
       _effect = effect,
       super(child);

  TextDirection _textDirection;
  ext.SkeletonizerConfigData _config;
  bool _ignorePointers;
  bool _isZone;
  double _animationValue;
  SkeletonizerEffect _effect;

  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsPaint();
    }
  }

  set config(ext.SkeletonizerConfigData value) {
    if (_config != value) {
      _config = value;
      markNeedsPaint();
    }
  }

  set ignorePointers(bool value) {
    if (_ignorePointers != value) {
      _ignorePointers = value;
      markNeedsPaint();
    }
  }

  set isZone(bool value) {
    if (_isZone != value) {
      _isZone = value;
      markNeedsPaint();
    }
  }

  set animationValue(double value) {
    if (_animationValue != value) {
      _animationValue = value;
      markNeedsPaint();
    }
  }

  set effect(SkeletonizerEffect value) {
    if (_effect != value) {
      _effect = value;
      markNeedsPaint();
    }
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_ignorePointers) return false;
    return super.hitTest(result, position: position);
  }

  @override
  OffsetLayer? get layer => super.layer as OffsetLayer?;

  @override
  void paint(PaintingContext context, Offset offset) {
    layer ??= OffsetLayer();
    if (layer!.hasChildren) {
      layer!.removeAllChildren();
    }
    context.addLayer(layer!);
    final estimatedBounds = paintBounds.shift(offset);
    final shaderPaint = _effect.createPaint(
      _animationValue,
      estimatedBounds,
      _textDirection,
    );
    final waveContext = WavePaintingContext(
      layer: layer!,
      estimatedBounds: estimatedBounds,
      shaderPaint: shaderPaint,
      config: _config,
      isZone: _isZone,
      animationValue: _animationValue,
      effect: _effect,
    );
    super.paint(waveContext, offset);
    waveContext.finishRecording();
  }
}