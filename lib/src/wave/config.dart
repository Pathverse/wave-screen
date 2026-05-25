import 'package:flutter/widgets.dart';

@immutable
class WaveLayer {
  final Color? color;
  final Gradient? gradient;
  final double amplitude;
  final double frequency;
  final double speed;
  final double phaseShift;
  final double horizontalShift;
  final double secondaryStrength;
  final double heightFactor;
  final double slope;
  final MaskFilter? blur;

  const WaveLayer({
    this.color,
    this.gradient,
    required this.amplitude,
    required this.frequency,
    required this.speed,
    required this.phaseShift,
    this.horizontalShift = 0,
    this.secondaryStrength = 0.22,
    required this.heightFactor,
    this.slope = 0,
    this.blur,
  }) : assert(
         color != null || gradient != null,
         'A wave layer must define either a color or a gradient.',
       ),
       assert(
         color == null || gradient == null,
         'A wave layer cannot define both a color and a gradient.',
       ),
       assert(amplitude >= 0, 'amplitude must be positive.'),
       assert(frequency > 0, 'frequency must be greater than zero.'),
       assert(
         heightFactor >= 0 && heightFactor <= 1,
         'heightFactor must be between 0 and 1.',
       );

  const WaveLayer.color({
    required Color this.color,
    required this.amplitude,
    required this.frequency,
    required this.speed,
    required this.phaseShift,
    this.horizontalShift = 0,
    this.secondaryStrength = 0.22,
    required this.heightFactor,
    this.slope = 0,
    this.blur,
  }) : gradient = null;

  const WaveLayer.gradient({
    required Gradient this.gradient,
    required this.amplitude,
    required this.frequency,
    required this.speed,
    required this.phaseShift,
    this.horizontalShift = 0,
    this.secondaryStrength = 0.22,
    required this.heightFactor,
    this.slope = 0,
    this.blur,
  }) : color = null;
}
