import 'package:flutter/material.dart';
import 'package:wave_screen/wave_screen.dart';

import '../widgets/example_page_frame.dart';
import '../widgets/example_tile.dart';

/// M3 Interaction showcase: tap or drag to send ripples across the surface, and
/// a ping-pong wave that eases back and forth.
class InteractionPage extends StatelessWidget {
  const InteractionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      ExampleTile(
        title: 'Tap & drag to ripple',
        child: Stack(
          fit: StackFit.expand,
          children: [
            WaveScreen.custom(
              background: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF061A2B), Color(0xFF0C2E44)],
              ),
              waves: [
                Wave(
                  shape: WaveShape.sine(
                    amplitude: 0.05,
                    frequency: 0.9,
                    baseline: 0.58,
                  ),
                  style: const WaveStyle(fill: Color(0xFF1C6E8C)),
                  motion: WaveMotion.drift(speed: 0.25),
                  effects: const [PointerRippleEffect()],
                ),
                Wave(
                  shape: WaveShape.sine(
                    amplitude: 0.06,
                    frequency: 1.2,
                    baseline: 0.74,
                  ),
                  style: const WaveStyle(fill: Color(0xFF3CA0BE)),
                  motion: WaveMotion.drift(speed: -0.2),
                  effects: const [PointerRippleEffect(strength: 0.1)],
                ),
              ],
            ),
            const IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'tap or drag anywhere',
                    style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ExampleTile(
        title: 'Ping-pong sway',
        child: WaveScreen.custom(
          background: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF241535), Color(0xFF3A2050)],
          ),
          waves: [
            Wave(
              shape: WaveShape.sine(
                amplitude: 0.07,
                frequency: 1.0,
                baseline: 0.6,
              ),
              style: const WaveStyle(fill: Color(0xFF7A5FCF)),
              motion: WaveMotion.pingPong(sway: 1.4, period: 5.0),
            ),
            Wave(
              shape: WaveShape.sine(
                amplitude: 0.06,
                frequency: 1.3,
                baseline: 0.8,
              ),
              style: const WaveStyle(fill: Color(0xFFA07CE8)),
              motion: WaveMotion.pingPong(sway: 1.0, period: 7.0),
            ),
          ],
        ),
      ),
    ];

    return ExamplePageFrame(
      title: 'Interaction',
      description:
          'Pointer-driven ripples and oscillating motion. Tap or drag the first '
          'tile to send ripples through the surface; the second uses ping-pong '
          'motion that eases back and forth.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900 ? 2 : 1;
          return GridView.count(
            crossAxisCount: columns,
            childAspectRatio: 16 / 10,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: tiles,
          );
        },
      ),
    );
  }
}
