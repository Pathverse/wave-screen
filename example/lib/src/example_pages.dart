import 'package:flutter/material.dart';

import 'pages/foundation_page.dart';

/// One entry in the example's milestone gallery. Each milestone appends its own
/// [ExamplePage] here, so the navigation grows without touching the shell.
class ExamplePage {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;

  const ExamplePage({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });
}

/// The milestone showcases, in order. M1 ships the Foundation page; later
/// milestones append Shapes, Interaction, and the Preset Gallery.
final List<ExamplePage> examplePages = <ExamplePage>[
  ExamplePage(
    label: 'Foundation',
    icon: Icons.waves_outlined,
    selectedIcon: Icons.waves,
    builder: (_) => const FoundationPage(),
  ),
];
