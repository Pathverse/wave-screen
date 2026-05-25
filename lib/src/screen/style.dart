import 'dart:math';

import 'package:flutter/widgets.dart';

import '../wave/wave.dart';
import 'adaptation.dart';
import 'layer_action.dart';
import 'layer_recipe.dart';
import 'palette.dart';
import 'presets.dart';

@immutable
class WaveScreenStyle {
  final WaveScreenPalette palette;
  final List<WaveScreenLayer> layers;
  final int seed;
  final Duration duration;
  final WaveScreenAdaptation adaptation;
  final WaveScreenLayerAction layerAction;

  const WaveScreenStyle({
    required this.palette,
    required this.layers,
    required this.seed,
    this.duration = const Duration(seconds: 9),
    this.adaptation = const WaveScreenAdaptation.referenceSpace(),
    this.layerAction = const WaveScreenLayerAction.growOnWideScreens(),
  });

  List<WaveLayer> buildLayers({double? sceneWidth}) {
    final random = Random(seed);
    final sortedLayers = [...layers]
      ..sort((left, right) => left.zIndex.compareTo(right.zIndex));
    final resolvedLayers = layerAction.apply(
      baseLayers: sortedLayers,
      sceneWidth: sceneWidth,
    );

    return List<WaveLayer>.generate(resolvedLayers.length, (index) {
      final gradient = palette.layerGradients[index % palette.layerGradients.length];
      return resolvedLayers[index].recipe.build(random, gradient);
    }, growable: false);
  }

  factory WaveScreenStyle.violet({
    int seed = 7,
    Duration duration = const Duration(seconds: 9),
    WaveScreenAdaptation adaptation =
        const WaveScreenAdaptation.referenceSpace(),
    WaveScreenLayerAction layerAction =
        const WaveScreenLayerAction.growOnWideScreens(),
  }) {
    return WaveScreenStyle(
      palette: WaveScreenPalette.violet,
      layers: WaveScreenDefaults.layers,
      seed: seed,
      duration: duration,
      adaptation: adaptation,
      layerAction: layerAction,
    );
  }

  factory WaveScreenStyle.sunset({
    int seed = 17,
    Duration duration = const Duration(seconds: 9),
    WaveScreenAdaptation adaptation =
        const WaveScreenAdaptation.referenceSpace(),
    WaveScreenLayerAction layerAction =
        const WaveScreenLayerAction.growOnWideScreens(),
  }) {
    return WaveScreenStyle(
      palette: WaveScreenPalette.sunset,
      layers: WaveScreenDefaults.layers,
      seed: seed,
      duration: duration,
      adaptation: adaptation,
      layerAction: layerAction,
    );
  }

  factory WaveScreenStyle.lagoon({
    int seed = 29,
    Duration duration = const Duration(seconds: 9),
    WaveScreenAdaptation adaptation =
        const WaveScreenAdaptation.referenceSpace(),
    WaveScreenLayerAction layerAction =
        const WaveScreenLayerAction.growOnWideScreens(),
  }) {
    return WaveScreenStyle(
      palette: WaveScreenPalette.lagoon,
      layers: WaveScreenDefaults.layers,
      seed: seed,
      duration: duration,
      adaptation: adaptation,
      layerAction: layerAction,
    );
  }
}