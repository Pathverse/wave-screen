import 'dart:ui' as ui;

/// Loads and caches the wave fragment program. The shader asset is bundled with
/// the package, so its key is package-prefixed when consumed by a dependent app;
/// the bare key is tried as a fallback for in-package tooling. A load failure is
/// non-fatal — callers render a CPU fallback so the surface never blanks.
class WaveShaderLoader {
  WaveShaderLoader._();

  static const List<String> _assetKeys = <String>[
    'packages/wave_screen/shaders/wave.frag',
    'shaders/wave.frag',
  ];

  static ui.FragmentProgram? _program;
  static bool _attempted = false;

  /// Attempts to load the fragment program once. Returns `null` on failure.
  static Future<ui.FragmentProgram?> load() async {
    if (_program != null || _attempted) {
      return _program;
    }
    _attempted = true;
    for (final key in _assetKeys) {
      try {
        _program = await ui.FragmentProgram.fromAsset(key);
        return _program;
      } catch (_) {
        // Try the next candidate key; fall through to null on exhaustion.
      }
    }
    return null;
  }
}
