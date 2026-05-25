import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

void main() {
  test('screen style supports overlapping placements with explicit z order', () {
    final style = WaveScreenStyle(
      palette: WaveScreenPalette.violet,
      seed: 11,
      adaptation: const WaveScreenAdaptation.none(),
      layerAction: const WaveScreenLayerAction.none(),
      layers: [
        WaveScreenLayer(
          zIndex: 10,
          recipe: WaveLayerRecipe(
            amplitudeMin: 10,
            amplitudeMax: 10,
            frequencyMin: 0.8,
            frequencyMax: 0.8,
            speedMin: 0.1,
            speedMax: 0.1,
            placement: WavePlacement.fixed(0.42),
            slopeMin: 0,
            slopeMax: 0,
            horizontalShiftMin: 0,
            horizontalShiftMax: 0,
            secondaryStrengthMin: 0.1,
            secondaryStrengthMax: 0.1,
          ),
        ),
        WaveScreenLayer(
          zIndex: 0,
          recipe: WaveLayerRecipe(
            amplitudeMin: 30,
            amplitudeMax: 30,
            frequencyMin: 1.0,
            frequencyMax: 1.0,
            speedMin: -0.1,
            speedMax: -0.1,
            placement: WavePlacement.fixed(0.42),
            slopeMin: 0,
            slopeMax: 0,
            horizontalShiftMin: 0,
            horizontalShiftMax: 0,
            secondaryStrengthMin: 0.2,
            secondaryStrengthMax: 0.2,
          ),
        ),
      ],
    );

    final layers = style.buildLayers();

    expect(layers, hasLength(2));
    expect(layers[0].heightFactor, 0.42);
    expect(layers[1].heightFactor, 0.42);
    expect(layers[0].amplitude, 30);
    expect(layers[1].amplitude, 10);
  });

  test('layer action adds waves as scene width grows', () {
    final style = WaveScreenStyle(
      palette: WaveScreenPalette.violet,
      seed: 3,
      adaptation: const WaveScreenAdaptation.none(),
      layerAction: const WaveScreenLayerAction.growOnWideScreens(
        referenceWidth: 300,
        widthPerAddedLayer: 120,
        maxAdditionalLayers: 2,
      ),
      layers: const [
        WaveScreenLayer(
          zIndex: 0,
          recipe: WaveLayerRecipe(
            amplitudeMin: 10,
            amplitudeMax: 10,
            frequencyMin: 0.7,
            frequencyMax: 0.7,
            speedMin: 0.1,
            speedMax: 0.1,
            placement: WavePlacement.fixed(0.15),
            slopeMin: 0,
            slopeMax: 0,
            horizontalShiftMin: 0,
            horizontalShiftMax: 0,
            secondaryStrengthMin: 0.1,
            secondaryStrengthMax: 0.1,
          ),
        ),
        WaveScreenLayer(
          zIndex: 1,
          recipe: WaveLayerRecipe(
            amplitudeMin: 20,
            amplitudeMax: 20,
            frequencyMin: 0.9,
            frequencyMax: 0.9,
            speedMin: -0.1,
            speedMax: -0.1,
            placement: WavePlacement.fixed(0.5),
            slopeMin: 0,
            slopeMax: 0,
            horizontalShiftMin: 0,
            horizontalShiftMax: 0,
            secondaryStrengthMin: 0.15,
            secondaryStrengthMax: 0.15,
          ),
        ),
        WaveScreenLayer(
          zIndex: 2,
          recipe: WaveLayerRecipe(
            amplitudeMin: 30,
            amplitudeMax: 30,
            frequencyMin: 1.1,
            frequencyMax: 1.1,
            speedMin: 0.12,
            speedMax: 0.12,
            placement: WavePlacement.fixed(0.82),
            slopeMin: 0,
            slopeMax: 0,
            horizontalShiftMin: 0,
            horizontalShiftMax: 0,
            secondaryStrengthMin: 0.2,
            secondaryStrengthMax: 0.2,
          ),
        ),
      ],
    );

    final narrowLayers = style.buildLayers(sceneWidth: 300);
    final wideLayers = style.buildLayers(sceneWidth: 600);

    expect(narrowLayers, hasLength(3));
    expect(wideLayers, hasLength(5));
  });

  testWidgets('paints each configured wave layer inside layout constraints', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 320,
            height: 240,
            child: WaveWidget(
              backgroundGradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3D2BC6), Color(0xFF2322B7)],
              ),
              layers: const [
                WaveLayer.gradient(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x804A3BCD), Color(0x084A3BCD)],
                  ),
                  amplitude: 18,
                  frequency: 0.8,
                  speed: -0.1,
                  phaseShift: 0.6,
                  horizontalShift: 0.12,
                  heightFactor: 0.28,
                  slope: 0.03,
                ),
                WaveLayer.gradient(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xA06B40E6), Color(0x22523BD3)],
                  ),
                  amplitude: 30,
                  frequency: 0.95,
                  speed: 0.07,
                  phaseShift: 2.2,
                  horizontalShift: -0.18,
                  secondaryStrength: 0.18,
                  heightFactor: 0.72,
                  slope: -0.05,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(WaveWidget), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
  });
}