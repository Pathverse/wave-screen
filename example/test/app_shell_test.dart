import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen_example/src/app_shell.dart';

void main() {
  testWidgets('ExampleAppShell exposes a ping-pong skeletonizer tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ExampleAppShell(),
      ),
    );

    expect(find.text('Ping Pong'), findsOneWidget);

    await tester.tap(find.text('Ping Pong'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Ping Pong Skeletonizer'), findsOneWidget);
  });
}