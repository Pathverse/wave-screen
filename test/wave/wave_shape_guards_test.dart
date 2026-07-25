import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';

/// Construction guards and the geometry edges the shapes promise: every assert
/// in the shape trait, plus metaball edge wrapping and sine periodicity.
void main() {
  group('construction guards', () {
    test('gerstner rejects a negative steepness', () {
      expect(
        () => WaveShape.gerstner(
          amplitude: 0.3,
          frequency: 1.0,
          steepness: -0.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('gerstner accepts zero steepness', () {
      expect(
        WaveShape.gerstner(amplitude: 0.3, frequency: 1.0, steepness: 0.0)
            .sampleAt(0.25, 0.0),
        closeTo(WaveShape.sine(amplitude: 0.3, frequency: 1.0).sampleAt(0.25, 0.0), 1e-9),
      );
    });

    test('metaball rejects a non-positive blob count', () {
      expect(
        () => WaveShape.metaball(blobCount: 0, amplitude: 0.3),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => WaveShape.metaball(blobCount: -2, amplitude: 0.3),
        throwsA(isA<AssertionError>()),
      );
    });

    test('metaball rejects a non-positive radius', () {
      expect(
        () => WaveShape.metaball(blobCount: 3, amplitude: 0.3, radius: 0.0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => WaveShape.metaball(blobCount: 3, amplitude: 0.3, radius: -0.1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  test('metaball blob centres wrap across the horizontal edges', () {
    // One blob sits at 0.5 before drift; a drift of 0.49 puts its centre at
    // 0.99, just inside the right edge.
    final shape = WaveShape.metaball(
      blobCount: 1,
      amplitude: 1.0,
      radius: 0.12,
    );
    final phase = 0.49 * 2 * math.pi;

    // A point just past the left edge is 0.02 away from the centre the short
    // way round, so it must sit near the bulge's peak.
    final nearWrapped = shape.sampleAt(0.01, phase).abs();
    // The far side of the field is genuinely distant and must stay at rest.
    final farAway = shape.sampleAt(0.5, phase).abs();

    expect(
      nearWrapped,
      greaterThan(0.9),
      reason: 'distance must wrap around the edge, keeping the surface seamless',
    );
    expect(farAway, lessThan(0.01), reason: 'the far side must stay at rest');
  });

  test('a sine completes exactly `frequency` cycles across the full width', () {
    final shape = WaveShape.sine(amplitude: 1.0, frequency: 3.0);

    // One cycle spans 1/3 of the width, so samples one cycle apart must match.
    for (final x in [0.05, 0.21, 0.4]) {
      expect(
        shape.sampleAt(x, 0.0),
        closeTo(shape.sampleAt(x + (1 / 3), 0.0), 1e-12),
      );
    }
    // The first crest lands a quarter-cycle in.
    expect(shape.sampleAt(1 / 12, 0.0), closeTo(1.0, 1e-12));
    // Half a cycle past the crest is the matching trough.
    expect(shape.sampleAt(1 / 12 + (1 / 6), 0.0), closeTo(-1.0, 1e-12));
  });
}
