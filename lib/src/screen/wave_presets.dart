import 'package:flutter/painting.dart';

import '../wave/wave.dart';
import '../wave/wave_motion.dart';
import '../wave/wave_shape.dart';
import '../wave/wave_style.dart';
import 'wave_screen_preset.dart';

/// A small library of curated [WaveScreenPreset]s designed for the trait system.
/// The gallery expands in a later milestone; these are the foundation set.
class WavePresets {
  WavePresets._();

  static Wave _layer({
    required double baseline,
    required double amplitude,
    required double frequency,
    required double speed,
    required Color color,
    double opacity = 1.0,
  }) {
    return Wave(
      shape: WaveShape.sine(
        amplitude: amplitude,
        frequency: frequency,
        baseline: baseline,
      ),
      style: WaveStyle(fill: color, opacity: opacity),
      motion: WaveMotion.drift(speed: speed),
    );
  }

  /// Cool teal→violet aurora ribbons over a deep night sky.
  static WaveScreenPreset get aurora => WaveScreenPreset(
    background: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0B1E3B), Color(0xFF122B4E)],
    ),
    waves: [
      _layer(baseline: 0.42, amplitude: 0.05, frequency: 0.9, speed: 0.35, color: const Color(0xFF1F7A6E)),
      _layer(baseline: 0.55, amplitude: 0.06, frequency: 1.2, speed: -0.30, color: const Color(0xFF2FA88F)),
      _layer(baseline: 0.68, amplitude: 0.07, frequency: 1.0, speed: 0.42, color: const Color(0xFF48C7A6)),
      _layer(baseline: 0.80, amplitude: 0.06, frequency: 1.4, speed: -0.26, color: const Color(0xFF7A6CD9)),
      _layer(baseline: 0.90, amplitude: 0.05, frequency: 1.1, speed: 0.22, color: const Color(0xFF9C7BE8)),
    ],
  );

  /// Warm dusk gradient of coral and amber swells.
  static WaveScreenPreset get dusk => WaveScreenPreset(
    background: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3A1D3F), Color(0xFF5E2A46)],
    ),
    waves: [
      _layer(baseline: 0.45, amplitude: 0.05, frequency: 0.8, speed: 0.30, color: const Color(0xFFC85C7E)),
      _layer(baseline: 0.58, amplitude: 0.06, frequency: 1.1, speed: -0.28, color: const Color(0xFFE87A6B)),
      _layer(baseline: 0.72, amplitude: 0.07, frequency: 0.95, speed: 0.40, color: const Color(0xFFF3A25E)),
      _layer(baseline: 0.85, amplitude: 0.06, frequency: 1.3, speed: -0.24, color: const Color(0xFFFFC46B)),
    ],
  );

  /// Deep, slow abyssal blues.
  static WaveScreenPreset get abyss => WaveScreenPreset(
    background: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF04121F), Color(0xFF082238)],
    ),
    waves: [
      _layer(baseline: 0.50, amplitude: 0.045, frequency: 0.7, speed: 0.18, color: const Color(0xFF10465F)),
      _layer(baseline: 0.65, amplitude: 0.055, frequency: 0.9, speed: -0.16, color: const Color(0xFF1B6A86)),
      _layer(baseline: 0.78, amplitude: 0.065, frequency: 1.05, speed: 0.22, color: const Color(0xFF2E90A8)),
      _layer(baseline: 0.90, amplitude: 0.05, frequency: 1.2, speed: -0.14, color: const Color(0xFF49B4C2)),
    ],
  );

  /// All foundation presets, in gallery order.
  static List<WaveScreenPreset> get all => [aurora, dusk, abyss];
}
