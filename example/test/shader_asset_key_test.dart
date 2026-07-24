import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/src/wave/shader/wave_shader.dart';

/// The consuming-app view of the shader asset, which the package's own suite
/// cannot stage: this app depends on `wave_screen` by path, so its bundle
/// carries the shader under the package-prefixed key only. If that key were
/// wrong, every test inside the package would still pass while every real app
/// silently lost its shader.
void main() {
  testWidgets('the bare in-repo key does not exist for a consuming app', (
    tester,
  ) async {
    final resolved = await tester.runAsync(() async {
      try {
        await ui.FragmentProgram.fromAsset('shaders/wave.frag');
        return true;
      } catch (_) {
        return false;
      }
    });

    expect(
      resolved,
      isFalse,
      reason: 'the bare key is in-package tooling only, so the package-prefixed '
          'key below is what actually carries a consuming app',
    );
  });

  testWidgets('the package-prefixed shader key resolves for a consuming app', (
    tester,
  ) async {
    final program = await tester.runAsync(
      () => ui.FragmentProgram.fromAsset(
        'packages/wave_screen/shaders/wave.frag',
      ),
    );

    expect(program, isNotNull);
  });

  testWidgets('the loader resolves the shader from a consuming app', (
    tester,
  ) async {
    final program = await tester.runAsync(() => WaveShaderLoader.load());

    expect(
      program,
      isNotNull,
      reason: 'the loader must fall through to a key that works here',
    );
  });
}
