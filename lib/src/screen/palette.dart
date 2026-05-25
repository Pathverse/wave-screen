import 'package:flutter/widgets.dart';

@immutable
class WaveScreenPalette {
  final Gradient backgroundGradient;
  final List<Gradient> layerGradients;

  const WaveScreenPalette({
    required this.backgroundGradient,
    required this.layerGradients,
  });

  static const violet = WaveScreenPalette(
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3B2CC5), Color(0xFF2522B9)],
    ),
    layerGradients: [
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4233C9), Color(0xFF2E2FB8)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4B36CB), Color(0xFF3430BB)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5C3FD1), Color(0xFF4032BB)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF6943D2), Color(0xFF4736C0)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7248D6), Color(0xFF4A39C4)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF7E53DB), Color(0xFF5641CA)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6642D0), Color(0xFF4436BF)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF583ACE), Color(0xFF3930BB)],
      ),
    ],
  );

  static const sunset = WaveScreenPalette(
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF672A58), Color(0xFF301D4F)],
    ),
    layerGradients: [
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD25C78), Color(0xFFB34865)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDF6B79), Color(0xFFBD516A)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFF1836D), Color(0xFFCA5E67)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF79E5F), Color(0xFFD36B5A)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFFFB85A), Color(0xFFE37D57)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFCA72), Color(0xFFF09164)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF08A6D), Color(0xFFD16263)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFE7717A), Color(0xFFB74F6C)],
      ),
    ],
  );

  static const lagoon = WaveScreenPalette(
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF173E84), Color(0xFF132F69)],
    ),
    layerGradients: [
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2C8AA4), Color(0xFF226D90)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF35A5B0), Color(0xFF2A7D98)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF49C1C1), Color(0xFF3491AE)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF60D1CC), Color(0xFF3C9DBA)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF73DDD8), Color(0xFF4FADD1)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF89ECE4), Color(0xFF68BDE1)],
      ),
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5CCBC8), Color(0xFF4198C2)],
      ),
      LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF42B6BE), Color(0xFF2C7DAB)],
      ),
    ],
  );
}