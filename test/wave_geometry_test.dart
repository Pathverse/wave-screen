import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';
import 'package:wave_screen/src/skeletonizer/wave_geometry.dart';

void main() {
  test('top-edge deformation keeps bottom edge stable and lifts the crest', () {
    const rect = Rect.fromLTWH(0, 20, 200, 40);

    final path = WaveGeometry.buildRectPath(
      rect: rect,
      radius: Radius.circular(20),
      progress: 0.3,
      amplitude: 12,
      frequency: 1.6,
      deformation: WaveDeformation.topEdge,
      synchronization: WaveSynchronization.global,
      phase: 0,
    );

    final bounds = path.getBounds();

    expect(bounds.bottom, closeTo(rect.bottom, 0.5));
    expect(bounds.top, lessThan(rect.top));
  });

  test('full-outline deformation changes both top and bottom bounds', () {
    const rect = Rect.fromLTWH(0, 20, 200, 40);

    final path = WaveGeometry.buildRectPath(
      rect: rect,
      radius: Radius.circular(20),
      progress: 0.3,
      amplitude: 12,
      frequency: 1.6,
      deformation: WaveDeformation.fullOutline,
      synchronization: WaveSynchronization.local,
      phase: 0.25,
    );

    final bounds = path.getBounds();

    expect(bounds.top, lessThan(rect.top));
    expect(bounds.bottom, greaterThan(rect.bottom));
  });

  test('local synchronization changes geometry phase compared with global mode', () {
    const rect = Rect.fromLTWH(0, 20, 200, 40);

    final globalPath = WaveGeometry.buildRectPath(
      rect: rect,
      radius: Radius.circular(20),
      progress: 0.4,
      amplitude: 10,
      frequency: 1.2,
      deformation: WaveDeformation.topEdge,
      synchronization: WaveSynchronization.global,
      phase: 0,
    );
    final localPath = WaveGeometry.buildRectPath(
      rect: rect,
      radius: Radius.circular(20),
      progress: 0.4,
      amplitude: 10,
      frequency: 1.2,
      deformation: WaveDeformation.topEdge,
      synchronization: WaveSynchronization.local,
      phase: 0.35,
    );

    expect(localPath.getBounds().top, isNot(globalPath.getBounds().top));
  });

  test('ping-pong crest shifts horizontally as animation progresses', () {
    const rect = Rect.fromLTWH(0, 20, 200, 40);
    const effect = PingPongWaveEffect();

    final leftNear = effect.sampleOffset(
      rect: rect,
      x: rect.left + (rect.width * 0.42),
      progress: 0.12,
      phase: 0,
    );
    final leftFar = effect.sampleOffset(
      rect: rect,
      x: rect.left + (rect.width * 0.8),
      progress: 0.12,
      phase: 0,
    );
    final rightFar = effect.sampleOffset(
      rect: rect,
      x: rect.left + (rect.width * 0.2),
      progress: 0.24,
      phase: 0,
    );
    final rightNear = effect.sampleOffset(
      rect: rect,
      x: rect.left + (rect.width * 0.78),
      progress: 0.24,
      phase: 0,
    );

    expect(leftNear.abs(), greaterThan(leftFar.abs()));
    expect(rightNear.abs(), greaterThan(rightFar.abs()));
  });

  test('ping-pong uses a single crest around the moving center', () {
    const rect = Rect.fromLTWH(0, 20, 200, 40);
    const effect = PingPongWaveEffect();
    final centerX = rect.left + (rect.width * effect.centerProgress(0.15));

    final leftShoulder = effect.sampleOffset(
      rect: rect,
      x: centerX - (rect.width * 0.08),
      progress: 0.15,
      phase: 0,
    );
    final center = effect.sampleOffset(
      rect: rect,
      x: centerX,
      progress: 0.15,
      phase: 0,
    );
    final rightShoulder = effect.sampleOffset(
      rect: rect,
      x: centerX + (rect.width * 0.08),
      progress: 0.15,
      phase: 0,
    );
    final far = effect.sampleOffset(
      rect: rect,
      x: rect.left + (rect.width * 0.85),
      progress: 0.15,
      phase: 0,
    );

    expect(center.abs(), greaterThan(leftShoulder.abs()));
    expect(center.abs(), greaterThan(rightShoulder.abs()));
    expect(center.abs(), greaterThan(far.abs()));
    expect(leftShoulder.sign, equals(rightShoulder.sign));
  });

  test('ping-pong geometry stays active at the wall during impact', () {
    const rect = Rect.fromLTWH(0, 20, 200, 40);
    const effect = PingPongWaveEffect(
      duration: Duration(seconds: 5),
      pauseDuration: Duration(seconds: 2),
    );

    final nearWall = effect.sampleOffset(
      rect: rect,
      x: rect.right - 6,
      progress: 0.5,
      phase: 0,
    );
    final mid = effect.sampleOffset(
      rect: rect,
      x: rect.left + (rect.width * 0.72),
      progress: 0.5,
      phase: 0,
    );

    expect(nearWall.abs(), greaterThan(0));
    expect(nearWall.abs(), greaterThan(mid.abs()));
  });

  test('ping-pong center reaches the wall before reflection begins', () {
    const effect = PingPongWaveEffect(
      duration: Duration(seconds: 5),
      pauseDuration: Duration(seconds: 2),
    );

    final centerProgress = effect.centerProgress(0.3);

    expect(centerProgress, closeTo(1, 0.001));
  });

  test('ping-pong crest grows through the outgoing travel and shrinks on return', () {
    const rect = Rect.fromLTWH(0, 20, 200, 40);
    const effect = PingPongWaveEffect(
      duration: Duration(seconds: 5),
      pauseDuration: Duration(seconds: 2),
    );

    final earlyCenterX = rect.left + (rect.width * effect.centerProgress(0.08));
    final midCenterX = rect.left + (rect.width * effect.centerProgress(0.22));
    final returnCenterX = rect.left + (rect.width * effect.centerProgress(0.84));

    final early = effect.sampleOffset(
      rect: rect,
      x: earlyCenterX,
      progress: 0.08,
      phase: 0,
    );
    final mid = effect.sampleOffset(
      rect: rect,
      x: midCenterX,
      progress: 0.22,
      phase: 0,
    );
    final returning = effect.sampleOffset(
      rect: rect,
      x: returnCenterX,
      progress: 0.84,
      phase: 0,
    );

    expect(mid.abs(), greaterThan(early.abs()));
    expect(mid.abs(), greaterThan(returning.abs()));
  });

  test('ping-pong return wave produces wall-side interference', () {
    const rect = Rect.fromLTWH(0, 20, 200, 40);
    const effect = PingPongWaveEffect(
      duration: Duration(seconds: 5),
      pauseDuration: Duration(seconds: 2),
    );

    final nearWall = effect.sampleOffset(
      rect: rect,
      x: rect.right - 10,
      progress: 0.82,
      phase: 0,
    );
    final innerRipple = effect.sampleOffset(
      rect: rect,
      x: rect.right - 26,
      progress: 0.82,
      phase: 0,
    );
    final farther = effect.sampleOffset(
      rect: rect,
      x: rect.right - 56,
      progress: 0.82,
      phase: 0,
    );

    expect(nearWall.abs(), greaterThan(0));
    expect(innerRipple.abs(), greaterThan(0));
    expect(nearWall.abs(), isNot(closeTo(innerRipple.abs(), 0.15)));
    expect(nearWall.abs(), greaterThan(farther.abs()));
  });

  test('travelingWaveOffset creates one raised crest and flat outer baseline', () {
    const width = 200.0;
    const centerX = 100.0;

    final center = WaveGeometry.travelingWaveOffset(
      x: centerX,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.18,
      phase: 0,
    );
    final shoulder = WaveGeometry.travelingWaveOffset(
      x: 120,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.18,
      phase: 0,
    );
    final outside = WaveGeometry.travelingWaveOffset(
      x: 160,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.18,
      phase: 0,
    );

    expect(center, lessThan(0));
    expect(shoulder, lessThan(0));
    expect(center.abs(), greaterThan(shoulder.abs()));
    expect(outside, 0);
  });

  test('travelingWaveOffset keeps a flatter tide-like baseline with softer shoulders', () {
    const width = 200.0;
    const centerX = 100.0;

    final center = WaveGeometry.travelingWaveOffset(
      x: centerX,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.18,
      phase: 0,
    );
    final shoulder = WaveGeometry.travelingWaveOffset(
      x: 116,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.18,
      phase: 0,
    );
    final midShoulder = WaveGeometry.travelingWaveOffset(
      x: 120,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.18,
      phase: 0,
    );

    expect(shoulder.abs(), lessThan(center.abs() * 0.7));
    expect(midShoulder.abs(), lessThan(center.abs() * 0.5));
  });

  test('travelingWaveOffset adds a subtle bump near the lobe edge', () {
    const width = 200.0;
    const centerX = 100.0;

    final innerShoulder = WaveGeometry.travelingWaveOffset(
      x: 116,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.22,
      phase: 0,
    );
    final edgeBump = WaveGeometry.travelingWaveOffset(
      x: 138,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.22,
      phase: 0,
    );
    final edgeFlat = WaveGeometry.travelingWaveOffset(
      x: 146,
      width: width,
      centerX: centerX,
      amplitude: 12,
      frequency: 1.2,
      spread: 0.22,
      phase: 0,
    );

    expect(edgeBump.abs(), greaterThan(0));
    expect(edgeBump.abs(), lessThan(innerShoulder.abs()));
    expect(edgeBump.abs(), greaterThan(edgeFlat.abs()));
  });
}