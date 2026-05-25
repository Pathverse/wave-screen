import 'package:flutter/widgets.dart';

import '../wave/wave.dart';
import 'config.dart';

class WaveScreen extends StatelessWidget {
  final WaveScreenStyle style;
  final DecorationImage? backgroundImage;
  final double? width;
  final double? height;
  final Clip clipBehavior;
  final bool repeat;
  final Widget? child;

  const WaveScreen({
    super.key,
    required this.style,
    this.backgroundImage,
    this.width,
    this.height,
    this.clipBehavior = Clip.hardEdge,
    this.repeat = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth = width ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0);
        final resolvedHeight = height ??
            (constraints.maxHeight.isFinite ? constraints.maxHeight : 240.0);

        return WaveWidget(
          layers: _adaptLayers(
            style.buildLayers(sceneWidth: resolvedWidth),
            resolvedWidth,
            resolvedHeight,
          ),
          duration: style.duration,
          backgroundGradient: style.palette.backgroundGradient,
          backgroundImage: backgroundImage,
          width: width,
          height: height,
          clipBehavior: clipBehavior,
          repeat: repeat,
          child: child,
        );
      },
    );
  }

  List<WaveLayer> _adaptLayers(
    List<WaveLayer> layers,
    double sceneWidth,
    double sceneHeight,
  ) {
    final adaptation = style.adaptation;
    final widthRatio = sceneWidth / adaptation.referenceSize.width;
    final heightRatio = sceneHeight / adaptation.referenceSize.height;
    final frequencyScale = adaptation.scaleFrequencyToWidth
        ? widthRatio.clamp(
            adaptation.minFrequencyScale,
            adaptation.maxFrequencyScale,
          )
        : 1.0;
    final amplitudeScale = adaptation.scaleAmplitudeToHeight
        ? heightRatio.clamp(
            adaptation.minAmplitudeScale,
            adaptation.maxAmplitudeScale,
          )
        : 1.0;
    final speedScale = adaptation.scaleSpeedToWidth
        ? (1 / widthRatio).clamp(
            adaptation.minSpeedScale,
            adaptation.maxSpeedScale,
          )
        : 1.0;
    final shiftScale = adaptation.scaleHorizontalShiftToWidth
        ? (1 / widthRatio).clamp(
            adaptation.minShiftScale,
            adaptation.maxShiftScale,
          )
        : 1.0;
    final harmonicScale = adaptation.secondaryStrengthScale.clamp(
      adaptation.minSecondaryStrengthScale,
      adaptation.maxSecondaryStrengthScale,
    );

    return layers.map((layer) {
      return WaveLayer(
        color: layer.color,
        gradient: layer.gradient,
        amplitude: layer.amplitude * amplitudeScale,
        frequency: layer.frequency * frequencyScale,
        speed: layer.speed * speedScale,
        phaseShift: layer.phaseShift,
        horizontalShift: layer.horizontalShift * shiftScale,
        secondaryStrength: layer.secondaryStrength * harmonicScale,
        heightFactor: layer.heightFactor,
        slope: layer.slope,
        blur: layer.blur,
      );
    }).toList(growable: false);
  }
}