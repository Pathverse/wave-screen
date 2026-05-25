import 'package:flutter/widgets.dart';

import 'layer_recipe.dart';

@immutable
class WaveScreenLayerAction {
  final double referenceWidth;
  final double widthPerAddedLayer;
  final int maxAdditionalLayers;

  const WaveScreenLayerAction({
    required this.referenceWidth,
    required this.widthPerAddedLayer,
    required this.maxAdditionalLayers,
  });

  const WaveScreenLayerAction.none()
    : this(
        referenceWidth: double.infinity,
        widthPerAddedLayer: double.infinity,
        maxAdditionalLayers: 0,
      );

  const WaveScreenLayerAction.growOnWideScreens({
    this.referenceWidth = 360,
    this.widthPerAddedLayer = 140,
    this.maxAdditionalLayers = 4,
  });

  List<WaveScreenLayer> apply({
    required List<WaveScreenLayer> baseLayers,
    double? sceneWidth,
  }) {
    if (_shouldKeepBaseLayers(baseLayers, sceneWidth)) {
      return baseLayers;
    }

    final extraLayers = _extraLayerCount(sceneWidth!);
    if (extraLayers == 0) {
      return baseLayers;
    }

    final expanded = [...baseLayers];
    for (int index = 0; index < extraLayers; index++) {
      expanded.insert(
        _insertionIndex(index, expanded.length, extraLayers),
        WaveScreenLayer(
          zIndex: 0,
          recipe: baseLayers[_sourceIndex(index, baseLayers.length, extraLayers)].recipe,
        ),
      );
    }

    return List<WaveScreenLayer>.generate(expanded.length, (index) {
      return WaveScreenLayer(zIndex: index, recipe: expanded[index].recipe);
    }, growable: false);
  }

  bool _shouldKeepBaseLayers(List<WaveScreenLayer> baseLayers, double? sceneWidth) {
    return sceneWidth == null ||
        maxAdditionalLayers <= 0 ||
        sceneWidth <= referenceWidth ||
        baseLayers.isEmpty;
  }

  int _extraLayerCount(double sceneWidth) {
    return ((sceneWidth - referenceWidth) / widthPerAddedLayer)
        .floor()
        .clamp(0, maxAdditionalLayers);
  }

  int _sourceIndex(int index, int baseLayerCount, int extraLayerCount) {
    return (((index + 1) * baseLayerCount) / (extraLayerCount + 1))
        .floor()
        .clamp(0, baseLayerCount - 1);
  }

  int _insertionIndex(int index, int expandedLength, int extraLayerCount) {
    return (((index + 1) * expandedLength) / (extraLayerCount + 1))
        .floor()
        .clamp(1, expandedLength);
  }
}