import 'package:flutter/material.dart';
import 'package:wave_screen/wave_screen.dart';

import '../widgets/example_page_frame.dart';
import '../widgets/skeletonizer_showcase.dart';

class PingPongSkeletonizerPage extends StatelessWidget {
  const PingPongSkeletonizerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageFrame(
      title: 'Ping Pong Skeletonizer',
      description:
          'A tide-pool scaffold swell that grows as it rolls in, compresses at the wall, reflects into ripples, then settles as it recedes.',
      child: const SkeletonizerShowcase(
        demoTitle: 'Traveling crest demo',
        demoDescription:
            'One shoreline-like swell builds across the scaffold shapes, hits the wall, reflects into ripples, and settles on the way back. The motion stays on the loading geometry only.',
        effect: PingPongWaveEffect(
          baseColor: Color(0xFFF7171F),
          highlightColor: Color(0xFFFF8D93),
          duration: Duration(milliseconds: 5200),
          pauseDuration: Duration(milliseconds: 2200),
          deformation: WaveDeformation.topEdge,
          synchronization: WaveSynchronization.global,
          spread: 0.3,
          amplitudeFactor: 0.27,
          frequency: 1.08,
        ),
      ),
    );
  }
}