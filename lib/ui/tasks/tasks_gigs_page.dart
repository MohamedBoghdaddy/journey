
  import 'package:flutter/material.dart';
  import 'package:masr_spaces_app/state/session.dart';
  import 'package:masr_spaces_app/theme/tokens.dart';

  class GigItem {
    final String title;
    final String timeLabel;
    final String distanceLabel;
    final String payLabel;
    final int recommendedTrust;
    final bool urgent;

    const GigItem({
      required this.title,
      required this.timeLabel,
      required this.distanceLabel,
      required this.payLabel,
      required this.recommendedTrust,
      this.urgent = false,
    });
  }

  enum GigsViewMode { list, map }

  class TasksGigsPage extends StatefulWidget {
    const TasksGigsPage({super.key});

    @override
    State<TasksGigsPage> createState() => _TasksGigsPageState();
  }

  class _TasksGigsPageState extends State<TasksGigsPage> {
    GigsViewMode _mode = GigsViewMode.list;

    final List<GigItem> _gigs = const [
      GigItem(
        title: 'Move a sofa',
        timeLabel: 'Today',
        distanceLabel: '<2km',
        payLabel: 'EGP 350',
        recommendedTrust: 85,
        urgent: true,
      ),
      GigItem(
        title: 'Fix kitchen sink',
        timeLabel: 'Urgent',
        distanceLabel: '3km',
        payLabel: 'EGP 500',
        recommendedTrust: 70,
        urgent: true,
      ),
      GigItem(
        title: 'Paint 1 room',
        timeLabel: 'This week',
        distanceLabel: '6km',
        payLabel: 'EGP 900',
        recommendedTrust: 60,
      ),
    ];

    @override
    Widget build(BuildContext context) {
      final t = Theme.of(context);

      return ValueListenableBuilder(
        valueListenable: SessionStore.session,
        builder: (context, session, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tasks / Gigs'),
              actions: [_viewToggle(context)],
            ),
            body: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      helperText: ' ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(label: Text('Urgent')),
                      Chip(label: Text('Today')),
                      Chip(label: Text('<2km')),
                      Chip(label: Text('High pay')),
                      Chip(label: Text('Verified only')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _mode == GigsViewMode.list
                        ? _listView(t, session.trust)
                        : _mapViewPlaceholder(t, session.trust),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget _viewToggle(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: SegmentedButton<GigsViewMode>(
          segments: const [
            ButtonSegment(
              value: GigsViewMode.list,
              label: Text('List'),
              icon: Icon(Icons.view_list_outlined),
            ),
            ButtonSegment(
              value: GigsViewMode.map,
              label: Text('Map'),
              icon: Icon(Icons.map_outlined),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
          showSelectedIcon: false,
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 10)),
          ),
        ),
      );
    }

    Widget _listView(ThemeData t, int userTrust) {
      return ListView.separated(
        itemCount: _gigs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final g = _gigs[i];
          final qualifies = userTrust >= g.recommendedTrust;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.title, style: t.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('${g.timeLabel} • ${g.distanceLabel} • ${g.payLabel}',
                      style: t.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recommended trust: ${g.recommendedTrust}',
                          style: t.textTheme.bodyMedium,
                        ),
                      ),
                      _qualifyPill(context, qualifies),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: qualifies
                          ? () {}
                          : () => _showHowToQualify(context, g.recommendedTrust),
                      child: Text(qualifies ? 'Apply' : 'How to qualify'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget _mapViewPlaceholder(ThemeData t, int userTrust) {
      return Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Map view is a prototype placeholder. Use this mode to preview map UX without packages.',
                      style: t.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _gigs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final g = _gigs[i];
                final qualifies = userTrust >= g.recommendedTrust;

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(g.title, style: t.textTheme.titleMedium),
                    subtitle: Text(
                      '${g.distanceLabel} • ${g.payLabel} • Recommended trust: ${g.recommendedTrust}',
                      style: t.textTheme.bodyMedium,
                    ),
                    trailing: qualifies
                        ? const Icon(Icons.check_circle_outline)
                        : TextButton(
                            onPressed: () => _showHowToQualify(context, g.recommendedTrust),
                            child: const Text('Qualify'),
                          ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    Widget _qualifyPill(BuildContext context, bool qualifies) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.rPill),
          border: Border.all(color: isDark ? AppTokens.borderDark : AppTokens.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(qualifies ? Icons.verified_outlined : Icons.lock_outline, size: 16),
            const SizedBox(width: 6),
            Text(qualifies ? 'You qualify' : 'Not yet'),
          ],
        ),
      );
    }

    void _showHowToQualify(BuildContext context, int targetTrust) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) {
          final t = Theme.of(context);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How to qualify', style: t.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('Target trust: $targetTrust', style: t.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Text('Actions that raise trust', style: t.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '- Complete verification\n'
                    '- Submit accurate reports\n'
                    '- Get helpful replies upvoted\n'
                    '- Avoid flagged content',
                    style: t.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/foundit_kyc');
                      },
                      child: const Text('Verify now'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
