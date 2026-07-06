@Tags(['proof_metaball_blobs_merge'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// M2 proof: a metaball surface bulges at each blob center. With two blobs, a
/// large radius bridges them into one gooey crest at the midpoint, while a small
/// radius leaves the midpoint back near the baseline.
void main() {
  test('metaball blobs bulge at centers and merge as radius grows', () {
    // Two blobs => centers at x = 0.25 and 0.75; midpoint at 0.5.
    final merged = WaveShape.metaball(blobCount: 2, radius: 0.35, amplitude: 1.0);
    final separated =
        WaveShape.metaball(blobCount: 2, radius: 0.08, amplitude: 1.0);

    // A clear bulge sits over a blob center.
    expect(merged.sampleAt(0.25, 0.0).abs(), greaterThan(0.5));

    // Merged blobs keep the midpoint elevated; separated blobs do not.
    expect(
      merged.sampleAt(0.5, 0.0).abs(),
      greaterThan(separated.sampleAt(0.5, 0.0).abs()),
    );
    expect(separated.sampleAt(0.5, 0.0).abs(), lessThan(0.2));
  });
}
