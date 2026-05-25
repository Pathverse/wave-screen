import 'package:flutter/material.dart';
import 'package:wave_screen/wave_screen.dart';

import '../widgets/example_page_frame.dart';
import '../widgets/example_tile.dart';

class WavesPage extends StatelessWidget {
  const WavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final children = [
      ExampleTile(
        title: 'Violet Drift',
        child: WaveScreen(style: WaveScreenStyle.violet(seed: 25)),
      ),
      ExampleTile(
        title: 'Sunset Melt',
        child: WaveScreen(style: WaveScreenStyle.sunset(seed: 15)),
      ),
      ExampleTile(
        title: 'Lagoon Glass',
        child: WaveScreen(style: WaveScreenStyle.lagoon(seed: 23)),
      ),
    ];

    return ExamplePageFrame(
      title: 'Wave Examples',
      description:
          'Seeded wave screens with configurable palettes, adaptation, and width-aware layer actions.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return isWide
              ? Row(
                  children: [
                    for (int index = 0; index < children.length; index++) ...[
                      Expanded(child: children[index]),
                      if (index != children.length - 1)
                        const SizedBox(width: 20),
                    ],
                  ],
                )
              : ListView.separated(
                  itemBuilder: (context, index) => SizedBox(
                    height: 260,
                    child: children[index],
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemCount: children.length,
                );
        },
      ),
    );
  }
}