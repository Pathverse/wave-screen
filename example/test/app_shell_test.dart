import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen_example/src/app_shell.dart';

void main() {
  testWidgets('ExampleAppShell shows the Foundation showcase', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExampleAppShell()));
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('Foundation'), findsWidgets);
  });
}
