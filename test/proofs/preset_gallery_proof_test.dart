@Tags(['proof_preset_gallery_is_valid'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M4 proof: the gallery is a broad set of valid presets, each reachable by a
/// unique name and each renderable (within the shader's layer budget).
void main() {
  test('preset gallery is broad, valid, and uniquely named', () {
    final gallery = WavePresets.all;

    // Broad — a real catalogue, not a handful.
    expect(gallery.length, greaterThanOrEqualTo(10));

    for (final preset in gallery) {
      expect(preset.waves, isNotEmpty);
      expect(preset.waves.length, lessThanOrEqualTo(8)); // shader MAX_LAYERS
      expect(
        preset.background != null || preset.backgroundColor != null,
        isTrue,
        reason: 'every preset needs a background',
      );
    }

    // Every preset is reachable by a unique name.
    final names = WavePresets.byName.keys.toList();
    expect(names.length, gallery.length);
    expect(names.toSet().length, names.length, reason: 'names must be unique');
    for (final name in names) {
      expect(WavePresets.byName[name]!.waves, isNotEmpty);
    }
  });
}
