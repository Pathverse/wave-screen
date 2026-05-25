import 'dart:math';

import 'package:flutter/widgets.dart';

import '../wave/wave.dart';

@immutable
class WaveLayerRecipe {
  final double amplitudeMin;
  final double amplitudeMax;
  final double frequencyMin;
  final double frequencyMax;
  final double speedMin;
  final double speedMax;
  final WavePlacement placement;
  final double slopeMin;
  final double slopeMax;
  final double horizontalShiftMin;
  final double horizontalShiftMax;
  final double secondaryStrengthMin;
  final double secondaryStrengthMax;
  final bool blur;

  const WaveLayerRecipe({
    required this.amplitudeMin,
    required this.amplitudeMax,
    required this.frequencyMin,
    required this.frequencyMax,
    required this.speedMin,
    required this.speedMax,
    required this.placement,
    required this.slopeMin,
    required this.slopeMax,
    required this.horizontalShiftMin,
    required this.horizontalShiftMax,
    required this.secondaryStrengthMin,
    required this.secondaryStrengthMax,
    this.blur = false,
  });

  WaveLayer build(Random random, Gradient gradient) {
    return WaveLayer.gradient(
      gradient: gradient,
      amplitude: _between(random, amplitudeMin, amplitudeMax),
      frequency: _between(random, frequencyMin, frequencyMax),
      speed: _between(random, speedMin, speedMax),
      phaseShift: random.nextDouble() * pi * 2,
      horizontalShift: _between(random, horizontalShiftMin, horizontalShiftMax),
      secondaryStrength: _between(
        random,
        secondaryStrengthMin,
        secondaryStrengthMax,
      ),
      heightFactor: placement.resolve(random),
      slope: _between(random, slopeMin, slopeMax),
      blur: blur ? MaskFilter.blur(BlurStyle.normal, 2) : null,
    );
  }

  static double _between(Random random, double min, double max) {
    return min + (max - min) * random.nextDouble();
  }
}

@immutable
class WavePlacement {
  final double min;
  final double max;

  const WavePlacement(this.min, this.max)
    : assert(min >= 0 && min <= 1),
      assert(max >= 0 && max <= 1),
      assert(min <= max);

  const WavePlacement.fixed(double value) : this(value, value);

  double resolve(Random random) {
    if (min == max) {
      return min;
    }
    return min + (max - min) * random.nextDouble();
  }
}

@immutable
class WaveScreenLayer {
  final int zIndex;
  final WaveLayerRecipe recipe;

  const WaveScreenLayer({required this.zIndex, required this.recipe});
}