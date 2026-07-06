import 'package:flutter/material.dart';
import 'package:wave_screen/wave_screen.dart';

import '../widgets/example_page_frame.dart';
import '../widgets/example_tile.dart';

/// M4 Preset Gallery: every curated preset in the library, each reachable by
/// name via WavePresets.byName.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = WavePresets.byName.entries.toList();

    return ExamplePageFrame(
      title: 'Preset Gallery',
      description:
          'The full curated library — sine, Gerstner and metaball themes plus '
          'interactive ripple presets. Each is reachable by name via '
          'WavePresets.byName.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100
              ? 3
              : constraints.maxWidth >= 700
                  ? 2
                  : 1;
          return GridView.count(
            crossAxisCount: columns,
            childAspectRatio: 16 / 11,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            children: [
              for (final entry in entries)
                ExampleTile(
                  title: entry.key,
                  child: WaveScreen(preset: entry.value),
                ),
            ],
          );
        },
      ),
    );
  }
}
