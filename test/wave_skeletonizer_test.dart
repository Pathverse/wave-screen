import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave_screen/wave_screen.dart';
import 'package:wave_screen/src/skeletonizer/render_widget.dart';

void main() {
  testWidgets('WaveSkeletonizer wraps Skeletonizer with a default wave effect', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: WaveSkeletonizer(
          child: SizedBox(width: 120, height: 48),
        ),
      ),
    );

    final renderWidget = tester.widget<WaveSkeletonizerRenderObjectWidget>(
      find.byType(WaveSkeletonizerRenderObjectWidget),
    );

    expect(find.byType(WaveSkeletonizer), findsOneWidget);
    expect(find.byType(WaveScreen), findsNothing);
    expect(renderWidget.effect, const WaveEffect());
    expect(renderWidget.effect.duration, const Duration(seconds: 9));
  });

  testWidgets('WaveSkeletonizer can own the animated loading surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WaveSkeletonizer(
          surfaceStyle: WaveScreenStyle.violet(
            layerAction: const WaveScreenLayerAction.none(),
          ),
          child: const SizedBox(width: 120, height: 48),
        ),
      ),
    );

    expect(find.byType(WaveScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(WaveSkeletonizer),
        matching: find.byType(WaveScreen),
      ),
      findsOneWidget,
    );
  });

  testWidgets('WaveSkeletonizer forwards a custom package effect through the adapter', (
    tester,
  ) async {
    const effect = _TestEffect(
      duration: Duration(milliseconds: 1400),
      lowerBound: -0.25,
      upperBound: 1.25,
      reverse: true,
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: WaveSkeletonizer(
          effect: effect,
          child: SizedBox(width: 120, height: 48),
        ),
      ),
    );

    final renderWidget = tester.widget<WaveSkeletonizerRenderObjectWidget>(
      find.byType(WaveSkeletonizerRenderObjectWidget),
    );

    expect(renderWidget.effect.duration, effect.duration);
    expect(renderWidget.effect.lowerBound, effect.lowerBound);
    expect(renderWidget.effect.upperBound, effect.upperBound);
    expect(renderWidget.effect.reverse, effect.reverse);
  });

  test('WaveEffect lerps between configured values', () {
    const start = WaveEffect(
      duration: Duration(seconds: 6),
      baseColor: Color(0xFF2230AA),
      highlightColor: Color(0xFF6A8CFF),
      deformation: WaveDeformation.topEdge,
      synchronization: WaveSynchronization.global,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    const end = WaveEffect(
      duration: Duration(seconds: 6),
      baseColor: Color(0xFF101820),
      highlightColor: Color(0xFFB6D7FF),
      deformation: WaveDeformation.fullOutline,
      synchronization: WaveSynchronization.local,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final lerped = start.lerp(end, 0.5);

    expect(lerped.duration, start.duration);
    expect(lerped.baseColor, isNot(start.baseColor));
    expect(lerped.highlightColor, isNot(start.highlightColor));
    expect(lerped.begin, isNot(start.begin));
    expect(lerped.end, isNot(start.end));
    expect(lerped.deformation, start.deformation);
    expect(lerped.synchronization, start.synchronization);
  });

  test('WaveEffect exposes configurable scaffold motion defaults', () {
    const effect = WaveEffect();

    expect(effect.deformation, WaveDeformation.topEdge);
    expect(effect.synchronization, WaveSynchronization.global);
  });

  test('WaveEffect accepts explicit scaffold motion configuration', () {
    const effect = WaveEffect(
      deformation: WaveDeformation.fullOutline,
      synchronization: WaveSynchronization.local,
    );

    expect(effect.deformation, WaveDeformation.fullOutline);
    expect(effect.synchronization, WaveSynchronization.local);
  });

  test('PingPongWaveEffect exposes scaffold motion defaults', () {
    const effect = PingPongWaveEffect();

    expect(effect.deformation, WaveDeformation.topEdge);
    expect(effect.synchronization, WaveSynchronization.global);
  });

  test('PingPongWaveEffect uses reversing animation bounds', () {
    const effect = PingPongWaveEffect();

    expect(effect.lowerBound, 0);
    expect(effect.upperBound, 1);
    expect(effect.reverse, isFalse);
  });

  test('PingPongWaveEffect maps cycle progress to shore hit dwell and return', () {
    const effect = PingPongWaveEffect(
      duration: Duration(seconds: 5),
      pauseDuration: Duration(seconds: 2),
    );

    expect(effect.centerProgress(0), 0);
    expect(effect.centerProgress(0.15), greaterThan(0.4));
    expect(effect.centerProgress(0.3), closeTo(1, 0.001));
    expect(effect.centerProgress(0.5), closeTo(1, 0.001));
    expect(effect.centerProgress(0.85), lessThan(0.75));
    expect(effect.centerProgress(0.85), greaterThan(0));
    expect(effect.centerProgress(1), 0);
  });

  test('PingPongWaveEffect stays visible through impact and reflection', () {
    const effect = PingPongWaveEffect(
      duration: Duration(seconds: 5),
      pauseDuration: Duration(seconds: 2),
    );

    expect(effect.visibilityProgress(0.15), 1);
    expect(effect.visibilityProgress(0.3), 1);
    expect(effect.visibilityProgress(0.5), 1);
    expect(effect.visibilityProgress(0.71), 1);
    expect(effect.visibilityProgress(0.85), 1);
  });

  test('PingPongWaveEffect accelerates as it approaches the wall', () {
    const effect = PingPongWaveEffect(
      duration: Duration(seconds: 5),
      pauseDuration: Duration(seconds: 2),
    );

    final first = effect.centerProgress(0.05);
    final second = effect.centerProgress(0.10);
    final third = effect.centerProgress(0.15);
    final fourth = effect.centerProgress(0.20);

    expect(second - first, lessThan(third - second));
    expect(third - second, lessThan(fourth - third));
  });

  test('PingPongWaveEffect decelerates as the reflection settles outward', () {
    const effect = PingPongWaveEffect(
      duration: Duration(seconds: 5),
      pauseDuration: Duration(seconds: 2),
    );

    final first = effect.centerProgress(0.72);
    final second = effect.centerProgress(0.80);
    final third = effect.centerProgress(0.88);
    final fourth = effect.centerProgress(0.96);

    expect(first - second, greaterThan(second - third));
    expect(second - third, greaterThan(third - fourth));
  });

  test('PingPongWaveEffect lerps between configured values', () {
    const start = PingPongWaveEffect(
      baseColor: Color(0xFFF24B5A),
      highlightColor: Color(0xFFFF97A0),
      deformation: WaveDeformation.topEdge,
      synchronization: WaveSynchronization.global,
      spread: 0.16,
      amplitudeFactor: 0.22,
      frequency: 1.0,
      pauseDuration: Duration(seconds: 1),
    );
    const end = PingPongWaveEffect(
      baseColor: Color(0xFF8A1320),
      highlightColor: Color(0xFFFFCDD2),
      deformation: WaveDeformation.fullOutline,
      synchronization: WaveSynchronization.local,
      spread: 0.24,
      amplitudeFactor: 0.3,
      frequency: 1.4,
      pauseDuration: Duration(seconds: 3),
    );

    final lerped = start.lerp(end, 0.5);

    expect(lerped.baseColor, isNot(start.baseColor));
    expect(lerped.highlightColor, isNot(start.highlightColor));
    expect(lerped.spread, isNot(start.spread));
    expect(lerped.amplitudeFactor, isNot(start.amplitudeFactor));
    expect(lerped.frequency, isNot(start.frequency));
    expect(lerped.pauseDuration, isNot(start.pauseDuration));
    expect(lerped.deformation, start.deformation);
    expect(lerped.synchronization, start.synchronization);
  });
}

class _TestEffect extends SkeletonizerEffect {
  const _TestEffect({
    required super.duration,
    required super.lowerBound,
    required super.upperBound,
    required super.reverse,
  });

  @override
  Paint createPaint(double t, Rect rect, TextDirection? textDirection) {
    return Paint()..color = const Color(0xFF000000);
  }

  @override
  SkeletonizerEffect lerp(SkeletonizerEffect? other, double t) {
    return this;
  }
}