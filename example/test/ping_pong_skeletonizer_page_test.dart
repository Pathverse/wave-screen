import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';
import 'package:wave_screen_example/src/pages/ping_pong_skeletonizer_page.dart';

void main() {
  testWidgets('PingPongSkeletonizerPage hosts a ping-pong WaveSkeletonizer demo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PingPongSkeletonizerPage(),
        ),
      ),
    );

    expect(find.byType(WaveSkeletonizer), findsOneWidget);
    expect(find.text('Traveling crest demo'), findsOneWidget);
    expect(find.text('Mina Lawson'), findsOneWidget);

    final skeletonizer = tester.widget<WaveSkeletonizer>(
      find.byType(WaveSkeletonizer),
    );

    expect(skeletonizer.effect, isA<PingPongWaveEffect>());
    expect(skeletonizer.enabled, isTrue);

    await tester.tap(find.byKey(const ValueKey('skeletonizer-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      tester.widget<Text>(find.text('Mina Lawson').first).style?.color,
      const Color(0xFF111827),
    );
    expect(
      tester.widget<Text>(find.text('Design systems lead').first).style?.color,
      const Color(0xFF4B5563),
    );
  });
}