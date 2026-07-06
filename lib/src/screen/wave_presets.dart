import 'package:flutter/painting.dart';

import '../wave/pointer_ripple_effect.dart';
import '../wave/wave.dart';
import '../wave/wave_effect.dart';
import '../wave/wave_motion.dart';
import '../wave/wave_shape.dart';
import '../wave/wave_style.dart';
import 'wave_screen_preset.dart';

enum _Kind { sine, gerstner, metaball }

/// A broad, curated library of [WaveScreenPreset]s spanning all shapes and the
/// interactive ripple effect. Presets are reachable by name via [byName] or as
/// an ordered list via [all].
class WavePresets {
  WavePresets._();

  static Gradient _bg(int top, int bottom) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(top), Color(bottom)],
      );

  static List<Wave> _layers({
    required List<Color> colors,
    _Kind kind = _Kind.sine,
    double speed = 0.28,
    double amp = 0.06,
    double steepness = 0.9,
    int blobCount = 4,
    double radius = 0.2,
    List<WaveEffect> effects = const [],
  }) {
    return [
      for (var i = 0; i < colors.length; i++)
        Wave(
          shape: switch (kind) {
            _Kind.sine => WaveShape.sine(
                amplitude: amp,
                frequency: 0.8 + (i * 0.15),
                baseline: 0.42 + (i * 0.12),
              ),
            _Kind.gerstner => WaveShape.gerstner(
                amplitude: amp,
                frequency: 0.8 + (i * 0.15),
                steepness: steepness,
                baseline: 0.42 + (i * 0.12),
              ),
            _Kind.metaball => WaveShape.metaball(
                blobCount: blobCount,
                radius: radius,
                amplitude: amp + 0.05,
                baseline: 0.5 + (i * 0.13),
              ),
          },
          style: WaveStyle(fill: colors[i]),
          motion: WaveMotion.drift(
            speed: (i.isEven ? 1 : -1) * (speed - (i * 0.02)),
          ),
          effects: effects,
        ),
    ];
  }

  // --- Sine themes ---------------------------------------------------------

  static WaveScreenPreset get aurora => WaveScreenPreset(
        background: _bg(0xFF0B1E3B, 0xFF122B4E),
        waves: _layers(colors: const [
          Color(0xFF1F7A6E),
          Color(0xFF2FA88F),
          Color(0xFF48C7A6),
          Color(0xFF7A6CD9),
          Color(0xFF9C7BE8),
        ]),
      );

  /// The classic deep indigo/violet theme carried over from the original
  /// `WaveScreenStyle.violet`.
  static WaveScreenPreset get violet => WaveScreenPreset(
        background: _bg(0xFF3B2CC5, 0xFF2522B9),
        waves: _layers(colors: const [
          Color(0xFF4233C9),
          Color(0xFF5C3FD1),
          Color(0xFF6943D2),
          Color(0xFF7248D6),
          Color(0xFF7E53DB),
        ]),
      );

  static WaveScreenPreset get dusk => WaveScreenPreset(
        background: _bg(0xFF3A1D3F, 0xFF5E2A46),
        waves: _layers(colors: const [
          Color(0xFFC85C7E),
          Color(0xFFE87A6B),
          Color(0xFFF3A25E),
          Color(0xFFFFC46B),
        ]),
      );

  static WaveScreenPreset get sunset => WaveScreenPreset(
        background: _bg(0xFF2A0F2E, 0xFF5A2440),
        waves: _layers(colors: const [
          Color(0xFFB0446E),
          Color(0xFFE06A5C),
          Color(0xFFF59A4E),
          Color(0xFFFFD36B),
        ]),
      );

  static WaveScreenPreset get neon => WaveScreenPreset(
        background: _bg(0xFF130A2B, 0xFF241246),
        waves: _layers(speed: 0.4, colors: const [
          Color(0xFF6A3DF0),
          Color(0xFFB63BE6),
          Color(0xFFF03D9E),
          Color(0xFF3DE0F0),
        ]),
      );

  static WaveScreenPreset get mist => WaveScreenPreset(
        background: _bg(0xFF1A2230, 0xFF283645),
        waves: _layers(speed: 0.16, amp: 0.04, colors: const [
          Color(0xFF3D5064),
          Color(0xFF556A80),
          Color(0xFF6E869C),
          Color(0xFF90A6BA),
        ]),
      );

  // --- Gerstner (sharp ocean) themes --------------------------------------

  static WaveScreenPreset get abyss => WaveScreenPreset(
        background: _bg(0xFF04121F, 0xFF082238),
        waves: _layers(kind: _Kind.gerstner, speed: 0.18, steepness: 0.7, colors: const [
          Color(0xFF10465F),
          Color(0xFF1B6A86),
          Color(0xFF2E90A8),
          Color(0xFF49B4C2),
        ]),
      );

  static WaveScreenPreset get ocean => WaveScreenPreset(
        background: _bg(0xFF05131F, 0xFF0A2A44),
        waves: _layers(kind: _Kind.gerstner, steepness: 1.1, colors: const [
          Color(0xFF14607C),
          Color(0xFF2384A0),
          Color(0xFF35A6BE),
          Color(0xFF5AC8D6),
        ]),
      );

  static WaveScreenPreset get lagoon => WaveScreenPreset(
        background: _bg(0xFF08222B, 0xFF0F3B42),
        waves: _layers(kind: _Kind.gerstner, steepness: 0.9, colors: const [
          Color(0xFF1C8A7E),
          Color(0xFF2FB39C),
          Color(0xFF46D1B4),
          Color(0xFF74E6CE),
        ]),
      );

  static WaveScreenPreset get ember => WaveScreenPreset(
        background: _bg(0xFF200A0A, 0xFF3E1512),
        waves: _layers(kind: _Kind.gerstner, steepness: 1.3, speed: 0.2, colors: const [
          Color(0xFF8A2D22),
          Color(0xFFC0472E),
          Color(0xFFE86F3A),
          Color(0xFFFFA24E),
        ]),
      );

  // --- Metaball (gooey) themes --------------------------------------------

  static WaveScreenPreset get jelly => WaveScreenPreset(
        background: _bg(0xFF102614, 0xFF1B3F22),
        waves: _layers(kind: _Kind.metaball, blobCount: 4, radius: 0.2, speed: 0.16, colors: const [
          Color(0xFF3FA84E),
          Color(0xFF6CCB5A),
          Color(0xFFA8E86B),
        ]),
      );

  static WaveScreenPreset get lava => WaveScreenPreset(
        background: _bg(0xFF160404, 0xFF2C0A08),
        waves: _layers(kind: _Kind.metaball, blobCount: 3, radius: 0.26, speed: 0.12, colors: const [
          Color(0xFF9A1F14),
          Color(0xFFD8471E),
          Color(0xFFF5892E),
        ]),
      );

  // --- Interactive themes --------------------------------------------------

  static WaveScreenPreset get tidepool => WaveScreenPreset(
        background: _bg(0xFF061A2B, 0xFF0C2E44),
        waves: _layers(
          kind: _Kind.gerstner,
          steepness: 0.8,
          speed: 0.22,
          effects: const [PointerRippleEffect()],
          colors: const [
            Color(0xFF1C6E8C),
            Color(0xFF2E97B7),
            Color(0xFF57C4D6),
          ],
        ),
      );

  static WaveScreenPreset get pulse => WaveScreenPreset(
        background: _bg(0xFF120A26, 0xFF241542),
        waves: _layers(
          speed: 0.3,
          effects: const [PointerRippleEffect(strength: 0.1)],
          colors: const [
            Color(0xFF5A3DD0),
            Color(0xFF8E5CE0),
            Color(0xFFC77BE8),
          ],
        ),
      );

  /// All presets keyed by name — the source of truth for the gallery.
  static final Map<String, WaveScreenPreset> byName = {
    'aurora': aurora,
    'violet': violet,
    'dusk': dusk,
    'sunset': sunset,
    'neon': neon,
    'mist': mist,
    'abyss': abyss,
    'ocean': ocean,
    'lagoon': lagoon,
    'ember': ember,
    'jelly': jelly,
    'lava': lava,
    'tidepool': tidepool,
    'pulse': pulse,
  };

  /// All presets in gallery order.
  static List<WaveScreenPreset> get all => byName.values.toList(growable: false);

  /// All preset names in gallery order.
  static List<String> get names => byName.keys.toList(growable: false);
}
