import 'package:flutter/material.dart';
import 'package:wave_screen/wave_screen.dart';

const Color _loadedTitleColor = Color(0xFF111827);
const Color _loadedBodyColor = Color(0xFF4B5563);
const Color _loadedCardColor = Color(0xFFF3F4F6);
const Color _loadedCardBorderColor = Color(0x120F172A);
const Color _loadedIconColor = Color(0xFF4F46E5);

class SkeletonizerShowcase extends StatefulWidget {
  final String demoTitle;
  final String demoDescription;
  final SkeletonizerEffect effect;

  const SkeletonizerShowcase({
    super.key,
    this.demoTitle = 'Live demo',
    this.demoDescription =
        'The scaffold shapes carry the wave motion. No animated background.',
    this.effect = const WaveEffect(
      baseColor: Color(0xFFF7171F),
      highlightColor: Color(0xFFFF6368),
      duration: Duration(milliseconds: 1200),
      deformation: WaveDeformation.topEdge,
      synchronization: WaveSynchronization.global,
    ),
  });

  @override
  State<SkeletonizerShowcase> createState() => _SkeletonizerShowcaseState();
}

class _SkeletonizerShowcaseState extends State<SkeletonizerShowcase> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              _DemoHeader(
                title: widget.demoTitle,
                description: widget.demoDescription,
                enabled: _enabled,
                onChanged: (value) {
                  setState(() {
                    _enabled = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              _DemoSurface(enabled: _enabled, effect: widget.effect),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoHeader extends StatelessWidget {
  final String title;
  final String description;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _DemoHeader({
    required this.title,
    required this.description,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  color: Color(0xCC1A1A1A),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              enabled ? 'Skeleton' : 'Loaded',
              style: const TextStyle(color: Color(0xFF1A1A1A)),
            ),
            Switch(
              key: const ValueKey('skeletonizer-toggle'),
              value: enabled,
              onChanged: onChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class _DemoSurface extends StatelessWidget {
  final bool enabled;
  final SkeletonizerEffect effect;

  const _DemoSurface({required this.enabled, required this.effect});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: WaveSkeletonizer(
        enabled: enabled,
        effect: effect,
        ignoreContainers: true,
        enableSwitchAnimation: true,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(color: const Color(0x1A000000), width: 2),
          ),
          padding: const EdgeInsets.all(20),
          child: const SingleChildScrollView(
            child: _DemoContent(),
          ),
        ),
      ),
    );
  }
}

class _DemoContent extends StatelessWidget {
  const _DemoContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileCard(),
        SizedBox(height: 20),
        _SummaryCard(),
        SizedBox(height: 20),
        _TaskGroup(),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFF6E79F7),
          child: Text(
            'M',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mina Lawson',
                style: TextStyle(
                  color: _loadedTitleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Design systems lead',
                style: TextStyle(color: _loadedBodyColor),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: () {},
          child: const Text('Review'),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _loadedCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _loadedCardBorderColor),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Designing the wave effect seam',
              style: TextStyle(
                color: _loadedTitleColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'The widget layer stays simple while the effect seam remains open for future stars, sparks, or other motion systems.',
              style: TextStyle(color: _loadedBodyColor, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskGroup extends StatelessWidget {
  const _TaskGroup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TaskRow(
          title: 'Audit loading states',
          subtitle: 'Text, avatars, cards, and grouped layouts',
        ),
        SizedBox(height: 12),
        _TaskRow(
          title: 'Swap visual effects later',
          subtitle: 'Keep the widget stable while changing the motion system',
        ),
        SizedBox(height: 12),
        _TaskRow(
          title: 'Preserve transition quality',
          subtitle: 'Switch smoothly between skeleton and loaded content',
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TaskRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0x226E79F7),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.auto_awesome,
            color: _loadedIconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _loadedTitleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _loadedBodyColor,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}