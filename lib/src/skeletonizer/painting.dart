// ignore_for_file: implementation_imports

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:skeletonizer/skeletonizer.dart' as ext;
import 'package:skeletonizer/src/painting/text_utils.dart';
import 'package:skeletonizer/src/utils/utils.dart';
import 'package:skeletonizer/src/widgets/skeleton.dart';

import 'config.dart';
import 'effect.dart';
import 'geometry_wave_effect.dart';
import 'wave_geometry.dart';

class WavePaintingContext extends PaintingContext {
  WavePaintingContext({
    required this.layer,
    required Rect estimatedBounds,
    required this.shaderPaint,
    required this.config,
    required this.isZone,
    required this.animationValue,
    required this.effect,
  }) : super(layer, estimatedBounds);

  final ext.SkeletonizerConfigData config;
  final double animationValue;
  final bool isZone;
  final ContainerLayer layer;
  final Paint shaderPaint;
  final SkeletonizerEffect effect;

  late final _treatedAsLeaf = <Offset>{};

  @override
  ui.Canvas get canvas => isZone ? super.canvas : WaveCanvas(super.canvas, this);

  void createDefaultContext(Rect rect, Painter paint) {
    final context = PaintingContext(layer, rect);
    paint(context, rect.topLeft);
    context.stopRecordingIfNeeded();
  }

  void createLeafContext(Rect rect, Painter painter) {
    final context = _LeafPaintingContext(
      layer: layer,
      shaderPaint: shaderPaint,
      config: config,
      estimatedBounds: rect,
      effect: effect,
      animationValue: animationValue,
    );
    painter(context, rect.topLeft);
    context.stopRecordingIfNeeded();
  }

  @override
  PaintingContext createChildContext(ContainerLayer childLayer, ui.Rect bounds) {
    return WavePaintingContext(
      layer: childLayer,
      estimatedBounds: bounds,
      shaderPaint: shaderPaint,
      config: config,
      isZone: isZone,
      animationValue: animationValue,
      effect: effect,
    );
  }

  void finishRecording() {
    stopRecordingIfNeeded();
  }

  @override
  void paintChild(RenderObject child, ui.Offset offset) {
    if (!isZone && child is RenderObjectWithChildMixin) {
      final key = child.paintBounds.shift(offset).center;
      final subChild = child.child;
      var treatAsLeaf = subChild == null || (subChild is RenderIgnoredSkeleton && subChild.enabled);
      if (child is RenderSemanticsAnnotations) {
        treatAsLeaf |= child.properties.button == true;
      }
      if (treatAsLeaf) {
        _treatedAsLeaf.add(key);
      }
    }
    child.paint(this, offset);
  }
}

class _LeafPaintingContext extends WavePaintingContext {
  _LeafPaintingContext({
    required super.layer,
    required super.estimatedBounds,
    required super.shaderPaint,
    required super.config,
    required super.effect,
    required super.animationValue,
  }) : super(isZone: true);
}

class WaveCanvas implements Canvas {
  WaveCanvas(this.parent, this.context);

  final Canvas parent;
  final WavePaintingContext context;

  Paint get _shaderPaint => context.shaderPaint;
  ext.SkeletonizerConfigData get _config => context.config;
  SkeletonizerEffect get _effect => context.effect;

  @override
  void drawParagraph(ui.Paragraph paragraph, ui.Offset offset) {
    final lines = paragraph.computeLineMetrics();
    for (var i = 0; i < lines.length; i++) {
      final rect = lineToRect(
        line: lines[i],
        offset: offset,
        numberOfLines: lines.length,
        justifyMultiLineText: _config.justifyMultiLineText,
        paragraphWidth: paragraph.width,
      );
      final borderRadius = _config.textBorderRadius.usesHeightFactor
          ? BorderRadius.circular(rect.height * _config.textBorderRadius.heightPercentage!)
          : _config.textBorderRadius.borderRadius?.resolve(TextDirection.ltr);

      if (borderRadius != null) {
        _drawWaveRRect(borderRadius.toRRect(rect));
      } else {
        _drawWaveRect(rect, Radius.zero);
      }
    }
  }

  @override
  void drawRect(ui.Rect rect, ui.Paint paint) {
    if (!_isBone(rect.center) || paint.color.a == 0) {
      _drawContainerRect(rect, paint);
      return;
    }
    _drawWaveRect(rect, Radius.zero);
  }

  @override
  void drawRRect(ui.RRect rrect, ui.Paint paint) {
    if (!_isBone(rrect.center) || paint.color.a == 0) {
      _drawContainerRRect(rrect, paint);
      return;
    }
    _drawWaveRRect(rrect);
  }

  @override
  void drawCircle(ui.Offset c, double radius, ui.Paint paint) {
    if (!_isBone(c) || paint.color.a == 0) {
      _drawContainerCircle(c, radius, paint);
      return;
    }

    final rect = Rect.fromCircle(center: c, radius: radius);
    final path = _buildPath(rect, Radius.circular(radius));
    parent.drawPath(path, _shaderPaint);
  }

  @override
  void drawDRRect(ui.RRect outer, ui.RRect inner, ui.Paint paint) {
    parent.drawDRRect(outer, inner, paint);
  }

  @override
  void drawPath(ui.Path path, ui.Paint paint) {
    if (!_isBone(path.getBounds().center) || paint.color.a == 0) {
      _drawContainerPath(path, paint);
      return;
    }

    final bounds = path.getBounds();
    final radius = Radius.circular(bounds.height / 2);
    final wavePath = _buildPath(bounds, radius);
    parent.drawPath(wavePath, _shaderPaint);
  }

  GeometryWaveEffect? get _geometryEffect => _effect is GeometryWaveEffect ? _effect as GeometryWaveEffect : null;

  double _phase(Rect rect) {
    return ((rect.left + rect.top) / 97.0) % 1.0;
  }

  bool _isBone(Offset center) => context._treatedAsLeaf.containsFuzzy(center);

  void _drawWaveRect(Rect rect, Radius radius) {
    final path = _buildPath(rect, radius);
    parent.drawPath(path, _shaderPaint);
  }

  void _drawWaveRRect(RRect rrect) {
    final path = _buildPath(rrect.outerRect, Radius.circular(rrect.tlRadiusX));
    parent.drawPath(path, _shaderPaint);
  }

  Path _buildPath(Rect rect, Radius radius) {
    final geometryEffect = _geometryEffect;
    if (geometryEffect == null) {
      return WaveGeometry.buildRectPath(
        rect: rect,
        radius: radius,
        progress: context.animationValue,
        amplitude: rect.height * 0.28,
        frequency: rect.width > 180 ? 1.6 : 1.2,
        deformation: WaveDeformation.topEdge,
        synchronization: WaveSynchronization.global,
        phase: _phase(rect),
      );
    }

    return geometryEffect.buildPath(
      rect: rect,
      radius: radius,
      progress: context.animationValue,
      phase: _phase(rect),
    );
  }

  void _drawContainerRect(Rect rect, Paint paint) {
    if (_config.ignoreContainers) return;
    parent.drawRect(rect, _config.containersColor != null ? paint.copyWith(color: _config.containersColor!) : paint);
  }

  void _drawContainerRRect(RRect rrect, Paint paint) {
    if (_config.ignoreContainers) return;
    parent.drawRRect(rrect, _config.containersColor != null ? paint.copyWith(color: _config.containersColor!) : paint);
  }

  void _drawContainerCircle(Offset c, double radius, Paint paint) {
    if (_config.ignoreContainers) return;
    parent.drawCircle(c, radius, _config.containersColor != null ? paint.copyWith(color: _config.containersColor!) : paint);
  }

  void _drawContainerPath(Path path, Paint paint) {
    if (_config.ignoreContainers) return;
    parent.drawPath(path, _config.containersColor != null ? paint.copyWith(color: _config.containersColor!) : paint);
  }

  @override
  int getSaveCount() => parent.getSaveCount();

  @override
  void save() => parent.save();

  @override
  void restore() => parent.restore();

  @override
  void saveLayer(Rect? bounds, Paint paint) => parent.saveLayer(bounds, paint);

  @override
  void translate(double dx, double dy) => parent.translate(dx, dy);

  @override
  void scale(double sx, [double? sy]) => parent.scale(sx, sy);

  @override
  void rotate(double radians) => parent.rotate(radians);

  @override
  void skew(double sx, double sy) => parent.skew(sx, sy);

  @override
  void transform(Float64List matrix4) => parent.transform(matrix4);

  @override
  Float64List getTransform() => parent.getTransform();

  @override
  noSuchMethod(Invocation invocation) => Function.apply(parent.noSuchMethod, [invocation]);
}