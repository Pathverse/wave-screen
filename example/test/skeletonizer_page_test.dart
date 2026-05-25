import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';
import 'package:wave_screen_example/src/pages/skeletonizer_page.dart';

void main() {
  testWidgets('SkeletonizerPage hosts a live WaveSkeletonizer demo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SkeletonizerPage(),
        ),
      ),
    );

    expect(find.byType(WaveSkeletonizer), findsOneWidget);
  expect(find.byType(WaveScreen), findsNothing);
    expect(find.text('Live demo'), findsOneWidget);
    expect(find.text('Mina Lawson'), findsOneWidget);

    var skeletonizer = tester.widget<WaveSkeletonizer>(
      find.byType(WaveSkeletonizer),
    );
    expect(skeletonizer.enabled, isTrue);

    await tester.tap(find.byKey(const ValueKey('skeletonizer-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    skeletonizer = tester.widget<WaveSkeletonizer>(find.byType(WaveSkeletonizer));
    expect(skeletonizer.enabled, isFalse);

    expect(
      tester.widget<Text>(find.text('Mina Lawson').first).style?.color,
      const Color(0xFF111827),
    );
    expect(
      tester.widget<Text>(find.text('Designing the wave effect seam').first).style?.color,
      const Color(0xFF111827),
    );
    expect(
      tester.widget<Text>(find.text('Design systems lead').first).style?.color,
      const Color(0xFF4B5563),
    );
    expect(
      tester.widget<Text>(find.text('Audit loading states').first).style?.color,
      const Color(0xFF111827),
    );
  });
}