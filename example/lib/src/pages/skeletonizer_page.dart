import 'package:flutter/material.dart';

import '../widgets/example_page_frame.dart';
import '../widgets/skeletonizer_showcase.dart';

class SkeletonizerPage extends StatelessWidget {
  const SkeletonizerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExamplePageFrame(
      title: 'Skeletonizer',
      description:
          'A live WaveSkeletonizer preview using real widgets so the wave effect can be toggled and extended later.',
      child: const SkeletonizerShowcase(),
    );
  }
}
