
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/models/content.dart';
import 'package:masr_spaces_app/theme/tokens.dart';
import 'package:masr_spaces_app/ui/components/unified_card.dart';

enum HomeFilter { trending, newest, nearby, trusted }

class HomeFeedV2 extends StatefulWidget {
  final String neighborhood;
  final List<String> interests;

  const HomeFeedV2({
    super.key,
    required this.neighborhood,
    required this.interests,
  });

  @override
  State<HomeFeedV2> createState() => _HomeFeedV2State();
}

class _HomeFeedV2State extends State<HomeFeedV2> {
  final ScrollController _scroll = ScrollController();
  bool _collapsedPulse = false;
  HomeFilter _filter = HomeFilter.trending;

  final List<FeedItem> _items = const [
    FeedItem(
      id: '1',
      type: ContentType.question,
      title: 'Best koshary spot near me?',
      body: 'Drop top picks and what to order.',
      space: 'Food',
      neighborhood: 'Maadi',
      trustScore: 72,
      isVerified: true,
    ),
    FeedItem(
      id: '2',
      type: ContentType.alert,
      title: 'Scam alert: fake apartment deposits',
      body: 'Deposit before viewing is a red flag. Report patterns.',
      space: 'Scam Radar',
      neighborhood: 'Nasr City',
      trustScore: 60,
      scamFlagged: true,
      scamReason: 'High similarity to known scam templates.',
    ),
    FeedItem(
      id: '3',
      type: ContentType.listing,
      title: '2BR apartment for rent (family only)',
      body: 'Near metro. Clean building. DM for details.',
      space: 'Rent Watch',
      neighborhood: 'Heliopolis',
      trustScore: 55,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.offset > 80 && !_collapsedPulse) {
        setState(() => _collapsedPulse = true);
      }
      if (_scroll.offset < 20 && _collapsedPulse) {
        setState(() => _collapsedPulse = false);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Change location: wire later')),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Home', style: t.textTheme.titleMedium),
                          Text(widget.neighborhood, style: t.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_outlined),
                      tooltip: 'Alerts',
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedHeader(
                  height: 132,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(AppTokens.s16),
                    child: Column(
                      children: [
                        const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search posts, neighbors, services...',
                            helperText: ' ',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _tab('Trending', HomeFilter.trending),
                            const SizedBox(width: 8),
                            _tab('Newest', HomeFilter.newest),
                            const SizedBox(width: 8),
                            _tab('Nearby', HomeFilter.nearby),
                            const SizedBox(width: 8),
                            _tab('Trusted', HomeFilter.trusted),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppTokens.s16, 12, AppTokens.s16, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _collapsedPulse
                        ? const SizedBox.shrink()
                        : Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppTokens.s16),
                              child: Row(
                                children: [
                                  const Icon(Icons.radar_outlined),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Pulse: 2 alerts near you',
                                      style: t.textTheme.bodyLarge,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('View'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppTokens.s16),
                sliver: SliverList.separated(
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final it = _items[i];
                    return UnifiedFeedCard(
                      item: it,
                      primaryCta: _primaryCta(it.type),
                      onPrimary: () {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Primary action: ${_primaryCta(it.type)}')),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                ),
              ),
            ],
          ),
          Positioned(
            left: AppTokens.s16,
            right: AppTokens.s16,
            top: MediaQuery.of(context).padding.top + 74,
            child: IgnorePointer(
              ignoring: !_collapsedPulse,
              child: AnimatedOpacity(
                opacity: _collapsedPulse ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.radar_outlined, size: 18),
                    label: const Text('Pulse: 2 alerts near you'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, HomeFilter f) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == f,
      onSelected: (_) => setState(() => _filter = f),
    );
  }

  String _primaryCta(ContentType type) {
    switch (type) {
      case ContentType.question:
        return 'Answer';
      case ContentType.alert:
        return 'Verify';
      case ContentType.listing:
        return 'View';
      case ContentType.task:
        return 'Open';
      case ContentType.story:
        return 'View';
      case ContentType.service:
        return 'Apply';
    }
  }
}

class _PinnedHeader extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _PinnedHeader({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedHeader oldDelegate) => false;
}
