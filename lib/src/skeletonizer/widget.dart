// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart' as ext;
import 'package:skeletonizer/src/widgets/skeletonizer.dart' as ext_src;

import '../screen/screen.dart';
import 'effect.dart';
import 'effect_adapter.dart';
import 'render_widget.dart';
import 'wave_effect.dart';

class WaveSkeletonizer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final SkeletonizerEffect effect;
  final WaveScreenStyle? surfaceStyle;
  final ext.TextBoneBorderRadius? textBoneBorderRadius;
  final bool? ignoreContainers;
  final bool? justifyMultiLineText;
  final Color? containersColor;
  final bool ignorePointers;
  final bool? enableSwitchAnimation;
  final ext.SwitchAnimationConfig? switchAnimationConfig;

  const WaveSkeletonizer({
    super.key,
    required this.child,
    this.enabled = true,
    this.effect = const WaveEffect(),
    this.surfaceStyle,
    this.textBoneBorderRadius,
    this.ignoreContainers,
    this.justifyMultiLineText,
    this.containersColor,
    this.ignorePointers = true,
    this.enableSwitchAnimation,
    this.switchAnimationConfig,
  });

  @override
  State<WaveSkeletonizer> createState() => _WaveSkeletonizerState();
}

class _WaveSkeletonizerState extends State<WaveSkeletonizer>
    with TickerProviderStateMixin<WaveSkeletonizer> {
  AnimationController? _animationController;
  late bool _enabled = widget.enabled;
  ext.SkeletonizerConfigData? _config;
  TextDirection _textDirection = TextDirection.ltr;

  double get _animationValue => _animationController?.value ?? 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupEffect();
  }

  @override
  void didUpdateWidget(covariant WaveSkeletonizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _enabled = widget.enabled;
      if (!_enabled) {
        _animationController?.reset();
        _animationController?.stop(canceled: true);
      } else {
        _startAnimationIfNeeded();
      }
    }
    _setupEffect();
  }

  @override
  void dispose() {
    _animationController
      ?..removeListener(_onAnimationChange)
      ..dispose();
    super.dispose();
  }

  void _setupEffect() {
    _textDirection = Directionality.of(context);
    final brightness = Theme.of(context).brightness;
    var resolvedConfig = ext.SkeletonizerConfig.maybeOf(context) ??
        (brightness == Brightness.light
            ? const ext.SkeletonizerConfigData()
            : const ext.SkeletonizerConfigData.dark());

    resolvedConfig = resolvedConfig.copyWith(
      effect: SkeletonizerEffectAdapter(widget.effect),
      textBorderRadius: widget.textBoneBorderRadius,
      ignoreContainers: widget.ignoreContainers,
      justifyMultiLineText: widget.justifyMultiLineText,
      containersColor: widget.containersColor,
      enableSwitchAnimation: widget.enableSwitchAnimation,
      switchAnimationConfig: widget.switchAnimationConfig,
    );

    if (resolvedConfig != _config) {
      _config = resolvedConfig;
      _stopAnimation();
      if (widget.enabled) {
        _startAnimationIfNeeded();
      }
    }
  }

  void _stopAnimation() {
    _animationController
      ?..removeListener(_onAnimationChange)
      ..stop(canceled: true)
      ..dispose();
    _animationController = null;
  }

  void _startAnimationIfNeeded() {
    if (widget.effect.duration.inMilliseconds == 0) {
      return;
    }
    _animationController = AnimationController.unbounded(vsync: this)
      ..addListener(_onAnimationChange)
      ..repeat(
        reverse: widget.effect.reverse,
        min: widget.effect.lowerBound,
        max: widget.effect.upperBound,
        period: widget.effect.duration,
      );
  }

  void _onAnimationChange() {
    if (mounted && widget.enabled) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final parent = ext.Skeletonizer.maybeOf(context);
    final body = _enabled
        ? WaveSkeletonizerRenderObjectWidget(
            animationValue: _animationValue,
            textDirection: _textDirection,
            config: _config!,
            ignorePointers: widget.ignorePointers,
            isZone: false,
            effect: widget.effect,
            child: widget.child,
          )
        : KeyedSubtree(
            key: const ValueKey('content'),
            child: widget.child,
          );

    Widget skeletonizer = ext_src.SkeletonizerScope(
      enabled: _enabled,
      config: _config!,
      isZone: false,
      isInsideZone: parent?.isZone ?? false,
      animationController: _animationController,
      child: _config!.enableSwitchAnimation
          ? AnimatedSwitcher(
              duration: _config!.switchAnimationConfig.duration,
              reverseDuration: _config!.switchAnimationConfig.reverseDuration,
              switchInCurve: _config!.switchAnimationConfig.switchInCurve,
              switchOutCurve: _config!.switchAnimationConfig.switchOutCurve,
              transitionBuilder: _config!.switchAnimationConfig.transitionBuilder,
              layoutBuilder: _config!.switchAnimationConfig.layoutBuilder,
              child: body,
            )
          : body,
    );

    if (widget.surfaceStyle == null) {
      return skeletonizer;
    }

    return WaveScreen(
      style: widget.surfaceStyle!,
      child: skeletonizer,
    );
  }
}