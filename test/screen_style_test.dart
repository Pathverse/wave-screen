import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

void main() {
  test('preset factories keep palette, defaults, and deterministic layer count', () {
    final violet = WaveScreenStyle.violet();
    final sunset = WaveScreenStyle.sunset();
    final lagoon = WaveScreenStyle.lagoon();

    expect(violet.palette, same(WaveScreenPalette.violet));
    expect(sunset.palette, same(WaveScreenPalette.sunset));
    expect(lagoon.palette, same(WaveScreenPalette.lagoon));

    expect(violet.duration, const Duration(seconds: 9));
    expect(sunset.buildLayers(), hasLength(11));
    expect(lagoon.buildLayers(sceneWidth: 360), hasLength(11));
  });

  test('screen barrel export exposes split screen types', () {
    const adaptation = WaveScreenAdaptation.none();
    const action = WaveScreenLayerAction.none();
    const placement = WavePlacement.fixed(0.5);
    const recipe = WaveLayerRecipe(
      amplitudeMin: 10,
      amplitudeMax: 10,
      frequencyMin: 0.8,
      frequencyMax: 0.8,
      speedMin: 0.1,
      speedMax: 0.1,
      placement: placement,
      slopeMin: 0,
      slopeMax: 0,
      horizontalShiftMin: 0,
      horizontalShiftMax: 0,
      secondaryStrengthMin: 0.1,
      secondaryStrengthMax: 0.1,
    );
    const layer = WaveScreenLayer(zIndex: 0, recipe: recipe);

    final style = WaveScreenStyle(
      palette: WaveScreenPalette.violet,
      layers: const [layer],
      seed: 1,
      adaptation: adaptation,
      layerAction: action,
    );

    expect(style.buildLayers(), hasLength(1));
  });
}