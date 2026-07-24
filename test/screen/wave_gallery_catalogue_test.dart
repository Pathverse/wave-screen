import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// The gallery's catalogue promises: unique reachable names, and coverage
/// spanning every shape plus the interactive ripple effect.
void main() {
  test('every gallery name is unique and resolves via byName', () {
    final names = WavePresets.names;

    expect(names, isNotEmpty);
    expect(
      names.toSet().length,
      names.length,
      reason: 'preset names must be unique',
    );
    expect(WavePresets.all.length, names.length);

    for (final name in names) {
      final preset = WavePresets.byName[name];
      expect(preset, isNotNull, reason: '"$name" must resolve to a preset');
      expect(preset!.waves, isNotEmpty);
    }
  });

  test('the gallery spans sine, gerstner and metaball shapes', () {
    final shapeTypes = <Type>{
      for (final preset in WavePresets.all)
        for (final wave in preset.waves) wave.shape.runtimeType,
    };

    expect(shapeTypes, contains(SineWaveShape));
    expect(shapeTypes, contains(GerstnerWaveShape));
    expect(shapeTypes, contains(MetaballWaveShape));
  });

  test('at least one preset carries a pointer ripple effect', () {
    final interactive = WavePresets.all.where(
      (preset) => preset.waves.any(
        (wave) => wave.effects.any((effect) => effect is PointerRippleEffect),
      ),
    );

    expect(
      interactive,
      isNotEmpty,
      reason: 'the gallery must demonstrate the interactive ripple effect',
    );
  });
}
