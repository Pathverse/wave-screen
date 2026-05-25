import 'package:flutter/material.dart';

import 'pages/ping_pong_skeletonizer_page.dart';
import 'pages/skeletonizer_page.dart';
import 'pages/waves_page.dart';

enum ExampleDestination { waves, skeletonizer, pingPong }

class ExampleAppShell extends StatefulWidget {
  const ExampleAppShell({super.key});

  @override
  State<ExampleAppShell> createState() => _ExampleAppShellState();
}

class _ExampleAppShellState extends State<ExampleAppShell> {
  ExampleDestination _destination = ExampleDestination.waves;

  @override
  Widget build(BuildContext context) {
    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.waves_outlined),
        selectedIcon: Icon(Icons.waves),
        label: 'Waves',
      ),
      NavigationDestination(
        icon: Icon(Icons.view_agenda_outlined),
        selectedIcon: Icon(Icons.view_agenda),
        label: 'Skeletonizer',
      ),
      NavigationDestination(
        icon: Icon(Icons.swap_horiz_outlined),
        selectedIcon: Icon(Icons.swap_horiz),
        label: 'Ping Pong',
      ),
    ];

    final pages = [
      const WavesPage(),
      const SkeletonizerPage(),
      const PingPongSkeletonizerPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: const Color(0xFF111324),
          body: SafeArea(
            child: isWide
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: NavigationRail(
                          backgroundColor: const Color(0x12000000),
                          indicatorColor: const Color(0xFF3A34C7),
                          selectedIndex: _destination.index,
                          onDestinationSelected: _select,
                          labelType: NavigationRailLabelType.all,
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.waves_outlined),
                              selectedIcon: Icon(Icons.waves),
                              label: Text('Waves'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.view_agenda_outlined),
                              selectedIcon: Icon(Icons.view_agenda),
                              label: Text('Skeletonizer'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.swap_horiz_outlined),
                              selectedIcon: Icon(Icons.swap_horiz),
                              label: Text('Ping Pong'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: pages[_destination.index]),
                    ],
                  )
                : pages[_destination.index],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  backgroundColor: const Color(0xFF171A31),
                  indicatorColor: const Color(0xFF3A34C7),
                  selectedIndex: _destination.index,
                  onDestinationSelected: _select,
                  destinations: destinations,
                ),
        );
      },
    );
  }

  void _select(int index) {
    setState(() {
      _destination = ExampleDestination.values[index];
    });
  }
}