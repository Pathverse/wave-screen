import 'package:flutter/material.dart';
import 'package:wave_screen/wave_screen.dart';

import '../widgets/example_page_frame.dart';
import '../widgets/example_tile.dart';

/// M2 Shapes showcase: the new Gerstner (sharp ocean crests) and metaball
/// (gooey merging blobs) geometries, alongside a sine for comparison.
class ShapesPage extends StatelessWidget {
  const ShapesPage({super.key});

  static Wave _wave({
    required WaveShape shape,
    required Color color,
    required double speed,
    double opacity = 1.0,
  }) {
    return Wave(
      shape: shape,
      style: WaveStyle(fill: color, opacity: opacity),
      motion: WaveMotion.drift(speed: speed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      ExampleTile(
        title: 'Gerstner ocean',
        child: WaveScreen.custom(
          background: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF04121F), Color(0xFF0A2540)],
          ),
          waves: [
            _wave(
              shape: WaveShape.gerstner(
                amplitude: 0.06,
                frequency: 0.8,
                steepness: 0.9,
                baseline: 0.52,
              ),
              color: const Color(0xFF1C6E8C),
              speed: 0.25,
            ),
            _wave(
              shape: WaveShape.gerstner(
                amplitude: 0.07,
                frequency: 1.1,
                steepness: 1.2,
                baseline: 0.70,
              ),
              color: const Color(0xFF2E97B7),
              speed: -0.2,
            ),
            _wave(
              shape: WaveShape.gerstner(
                amplitude: 0.06,
                frequency: 0.95,
                steepness: 0.8,
                baseline: 0.86,
              ),
              color: const Color(0xFF57C4D6),
              speed: 0.3,
            ),
          ],
        ),
      ),
      ExampleTile(
        title: 'Gooey metaballs',
        child: WaveScreen.custom(
          background: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A123F), Color(0xFF45204E)],
          ),
          waves: [
            _wave(
              shape: WaveShape.metaball(
                blobCount: 4,
                radius: 0.18,
                amplitude: 0.12,
                baseline: 0.60,
              ),
              color: const Color(0xFFC85C9C),
              speed: 0.18,
            ),
            _wave(
              shape: WaveShape.metaball(
                blobCount: 3,
                radius: 0.24,
                amplitude: 0.14,
                baseline: 0.82,
              ),
              color: const Color(0xFFE87AB0),
              speed: -0.14,
            ),
          ],
        ),
      ),
      ExampleTile(
        title: 'Sine vs Gerstner',
        child: WaveScreen.custom(
          backgroundColor: const Color(0xFF10131F),
          waves: [
            _wave(
              shape: WaveShape.sine(
                amplitude: 0.07,
                frequency: 1.0,
                baseline: 0.55,
              ),
              color: const Color(0xFF3A7BD5),
              speed: 0.25,
              opacity: 0.85,
            ),
            _wave(
              shape: WaveShape.gerstner(
                amplitude: 0.07,
                frequency: 1.0,
                steepness: 1.4,
                baseline: 0.75,
              ),
              color: const Color(0xFF00D2A0),
              speed: 0.25,
            ),
          ],
        ),
      ),
    ];

    return ExamplePageFrame(
      title: 'Shapes',
      description:
          'New WaveShape geometries: Gerstner sharpens crests toward an ocean '
          'look, and metaball builds gooey merging blobs — all still composed '
          'from the same trait model.',
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
