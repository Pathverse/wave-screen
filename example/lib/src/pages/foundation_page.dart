import 'package:flutter/material.dart';
import 'package:wave_screen/wave_screen.dart';

import '../widgets/example_page_frame.dart';
import '../widgets/example_tile.dart';

/// M1 Foundation showcase: the fresh curated presets plus a wave composed
/// directly from swappable shape / style / motion traits.
class FoundationPage extends StatelessWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      ExampleTile(
        title: 'Aurora (preset)',
        child: WaveScreen(preset: WavePresets.aurora),
      ),
      ExampleTile(
        title: 'Dusk (preset)',
        child: WaveScreen(preset: WavePresets.dusk),
      ),
      ExampleTile(
        title: 'Abyss (preset)',
        child: WaveScreen(preset: WavePresets.abyss),
      ),
      ExampleTile(
        title: 'Composed from traits',
        child: WaveScreen.custom(
          background: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10131F), Color(0xFF1B2138)],
          ),
          waves: [
            Wave(
              shape: WaveShape.sine(
                amplitude: 0.05,
                frequency: 0.9,
                baseline: 0.55,
              ),
              style: const WaveStyle(fill: Color(0xFF3A7BD5)),
              motion: WaveMotion.drift(speed: 0.35),
            ),
            Wave(
              shape: WaveShape.sine(
                amplitude: 0.07,
                frequency: 1.3,
                baseline: 0.72,
              ),
              style: const WaveStyle(fill: Color(0xFF00D2A0), opacity: 0.9),
              motion: WaveMotion.drift(speed: -0.28),
            ),
            Wave(
              shape: WaveShape.sine(
                amplitude: 0.05,
                frequency: 1.1,
                baseline: 0.88,
              ),
              style: const WaveStyle(fill: Color(0xFF9C7BE8)),
              motion: WaveMotion.still(),
            ),
          ],
        ),
      ),
    ];

    return ExamplePageFrame(
      title: 'Foundation',
      description:
          'GPU shader-driven waves composed from swappable shape, style, and '
          'motion traits. Curated presets, plus a surface built inline from '
          'raw Wave traits.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900 ? 2 : 1;
          return GridView.count(
            crossAxisCount: columns,
            childAspectRatio: 16 / 10,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: tiles,
          );
        },
      ),
    );
  }
}
