import 'package:flutter/widgets.dart';

@immutable
class WaveScreenAdaptation {
  final Size referenceSize;
  final bool scaleFrequencyToWidth;
  final bool scaleAmplitudeToHeight;
  final bool scaleSpeedToWidth;
  final bool scaleHorizontalShiftToWidth;
  final double secondaryStrengthScale;
  final double minFrequencyScale;
  final double maxFrequencyScale;
  final double minAmplitudeScale;
  final double maxAmplitudeScale;
  final double minSpeedScale;
  final double maxSpeedScale;
  final double minShiftScale;
  final double maxShiftScale;
  final double minSecondaryStrengthScale;
  final double maxSecondaryStrengthScale;

  const WaveScreenAdaptation({
    required this.referenceSize,
    required this.scaleFrequencyToWidth,
    required this.scaleAmplitudeToHeight,
    required this.scaleSpeedToWidth,
    required this.scaleHorizontalShiftToWidth,
    required this.secondaryStrengthScale,
    required this.minFrequencyScale,
    required this.maxFrequencyScale,
    required this.minAmplitudeScale,
    required this.maxAmplitudeScale,
    required this.minSpeedScale,
    required this.maxSpeedScale,
    required this.minShiftScale,
    required this.maxShiftScale,
    required this.minSecondaryStrengthScale,
    required this.maxSecondaryStrengthScale,
  });

  const WaveScreenAdaptation.none()
    : this(
        referenceSize: const Size(360, 260),
        scaleFrequencyToWidth: false,
        scaleAmplitudeToHeight: false,
        scaleSpeedToWidth: false,
        scaleHorizontalShiftToWidth: false,
        secondaryStrengthScale: 1,
        minFrequencyScale: 1,
        maxFrequencyScale: 1,
        minAmplitudeScale: 1,
        maxAmplitudeScale: 1,
        minSpeedScale: 1,
        maxSpeedScale: 1,
        minShiftScale: 1,
        maxShiftScale: 1,
        minSecondaryStrengthScale: 1,
        maxSecondaryStrengthScale: 1,
      );

  const WaveScreenAdaptation.referenceSpace({
    this.referenceSize = const Size(360, 260),
    this.scaleFrequencyToWidth = true,
    this.scaleAmplitudeToHeight = true,
    this.scaleSpeedToWidth = true,
    this.scaleHorizontalShiftToWidth = true,
    this.secondaryStrengthScale = 1,
    this.minFrequencyScale = 0.72,
    this.maxFrequencyScale = 2.2,
    this.minAmplitudeScale = 0.90,
    this.maxAmplitudeScale = 1.45,
    this.minSpeedScale = 0.72,
    this.maxSpeedScale = 1.45,
    this.minShiftScale = 0.78,
    this.maxShiftScale = 1.35,
    this.minSecondaryStrengthScale = 1,
    this.maxSecondaryStrengthScale = 1,
  });

  const WaveScreenAdaptation.responsiveGeometry()
    : this(
        referenceSize: const Size(360, 260),
        scaleFrequencyToWidth: true,
        scaleAmplitudeToHeight: true,
        scaleSpeedToWidth: false,
        scaleHorizontalShiftToWidth: true,
        secondaryStrengthScale: 1,
        minFrequencyScale: 0.72,
        maxFrequencyScale: 2.2,
        minAmplitudeScale: 0.90,
        maxAmplitudeScale: 1.45,
        minSpeedScale: 1,
        maxSpeedScale: 1,
        minShiftScale: 0.78,
        maxShiftScale: 1.35,
        minSecondaryStrengthScale: 1,
        maxSecondaryStrengthScale: 1,
      );
}