import 'package:flutter/material.dart';

import 'example_pages.dart';

/// Hosts the milestone showcase pages. Navigation is derived from
/// [examplePages]; a single page renders on its own, and destinations appear
/// once a later milestone appends more pages.
class ExampleAppShell extends StatefulWidget {
  const ExampleAppShell({super.key});

  @override
  State<ExampleAppShell> createState() => _ExampleAppShellState();
}

class _ExampleAppShellState extends State<ExampleAppShell> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = examplePages;
    final hasNav = pages.length >= 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final body = pages[_index].builder(context);

        return Scaffold(
          backgroundColor: const Color(0xFF111324),
          body: SafeArea(
            child: hasNav && isWide
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: NavigationRail(
                          backgroundColor: const Color(0x12000000),
                          indicatorColor: const Color(0xFF3A34C7),
                          selectedIndex: _index,
                          onDestinationSelected: _select,
                          labelType: NavigationRailLabelType.all,
                          destinations: [
                            for (final page in pages)
                              NavigationRailDestination(
                                icon: Icon(page.icon),
                                selectedIcon: Icon(page.selectedIcon),
                                label: Text(page.label),
                              ),
                          ],
                        ),
                      ),
                      Expanded(child: body),
                    ],
                  )
                : body,
          ),
          bottomNavigationBar: hasNav && !isWide
              ? NavigationBar(
                  backgroundColor: const Color(0xFF171A31),
                  indicatorColor: const Color(0xFF3A34C7),
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  destinations: [
                    for (final page in pages)
                      NavigationDestination(
                        icon: Icon(page.icon),
                        selectedIcon: Icon(page.selectedIcon),
                        label: page.label,
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
