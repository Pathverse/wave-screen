@Tags(['proof_concurrent_shader_load'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/src/wave/shader/wave_shader.dart';

void main() {
  // This suite starts with a fresh loader. No earlier test warms its cache.
  testWidgets('concurrent initial requests await and reuse the same program', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final requests = List.generate(8, (_) => WaveShaderLoader.load());
      final programs = await Future.wait(requests);
      expect(programs.first, isNotNull);
      for (final program in programs) {
        expect(identical(program, programs.first), isTrue);
      }
      final cached = await WaveShaderLoader.load();
      expect(identical(cached, programs.first), isTrue);
    });
  });
}
