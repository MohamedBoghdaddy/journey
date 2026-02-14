
  import 'package:flutter/material.dart';
  import '../../state/session.dart';
  import '../../theme/tokens.dart';

  class ListingItem {
    final String title;
    final String subtitle;
    final String price;
    final bool scamFlag;
    final String? scamReason;
    final double? scamConfidence; // 0..1
    final int sellerTrust; // 0-100 (prototype)
    final bool sellerVerified;

    const ListingItem({
      required this.title,
      required this.subtitle,
      required this.price,
      required this.sellerTrust,
      required this.sellerVerified,
      this.scamFlag = false,
      this.scamReason,
      this.scamConfidence,
    });
  }

  class HousingPage extends StatefulWidget {
    const HousingPage({super.key});

    @override
    State<HousingPage> createState() => _HousingPageState();
  }

  class _HousingPageState extends State<HousingPage> {
    int _selectedStory = 0;

    final List<ListingItem> _listings = const [
      ListingItem(
        title: 'Studio in Dokki',
        subtitle: 'Furnished • Near metro',
        price: 'EGP 9,500/mo',
        sellerTrust: 78,
        sellerVerified: true,
      ),
      ListingItem(
        title: '2BR “Too good to be true”',
        subtitle: 'Deposit requested before viewing',
        price: 'EGP 4,000/mo',
        sellerTrust: 42,
        sellerVerified: false,
        scamFlag: true,
        scamReason: 'Price outlier + deposit-before-view pattern',
        scamConfidence: 0.63,
      ),
    ];

    @override
    Widget build(BuildContext context) {
      final t = Theme.of(context);

      return ValueListenableBuilder(
        valueListenable: SessionStore.session,
        builder: (context, session, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Housing / Furniture')),
            body: ListView(
              padding: const EdgeInsets.all(AppTokens.s16),
              children: [
                _storiesRow(t),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    Chip(label: Text('Rent')),
                    Chip(label: Text('Buy')),
                    Chip(label: Text('Furniture')),
                    Chip(label: Text('Sort')),
                  ],
                ),
                const SizedBox(height: 16),
                ..._listings.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ListingCard(
                      item: l,
                      userTrust: session.trust,
                      userVerified: session.isVerified,
                      onDispute: () => _openDispute(context, l),
                      onSafeChat: () => _openSafeChat(context, l, session.trust, session.isVerified),
                      onView: () {},
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget _storiesRow(ThemeData t) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 8,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final selected = i == _selectedStory;
            return InkWell(
              borderRadius: BorderRadius.circular(AppTokens.rCard),
              onTap: () => setState(() => _selectedStory = i),
              child: Container(
                width: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTokens.rCard),
                  border: Border.all(
                    color: selected
                        ? (isDark ? AppTokens.neutral : AppTokens.primary)
                        : (isDark ? AppTokens.borderDark : AppTokens.border),
                    width: selected ? 1.4 : 1,
                  ),
                  boxShadow: selected && isDark ? AppTokens.shadowSoft(Colors.black) : null,
                ),
                child: Center(
                  child: Text('Story ${i + 1}', style: t.textTheme.bodyMedium),
                ),
              ),
            );
          },
        ),
      );
    }

    void _openSafeChat(BuildContext context, ListingItem item, int trust, bool verified) {
      final canReveal = verified || trust >= 85;

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
                  Text('Safe chat', style: t.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('Contact is masked by default.', style: t.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: Text(item.title, style: t.textTheme.titleMedium),
                      subtitle: Text(
                        'Seller trust: ${item.sellerTrust} • ${item.sellerVerified ? 'Verified' : 'Unverified'}',
                        style: t.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Phone', style: t.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    canReveal ? '+20 1XX XXX XXXX' : 'Hidden until verified or trust ≥ 85',
                    style: t.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (!canReveal) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/foundit_kyc');
                              return;
                            }
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chat opened (prototype).')),
                            );
                          },
                          child: Text(canReveal ? 'Open chat' : 'Verify to unlock'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    void _openDispute(BuildContext context, ListingItem item) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) {
          final t = Theme.of(context);
          final conf = item.scamConfidence == null ? 'Unknown' : '${(item.scamConfidence! * 100).round()}%';

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dispute flag', style: t.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('Reason', style: t.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(item.scamReason ?? 'No reason provided', style: t.textTheme.bodyLarge),
                  const SizedBox(height: 10),
                  Text('Confidence: $conf', style: t.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Text('What to include', style: t.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '- Proof of viewing/ownership\n'

                    '- Contract screenshots (IDs blurred)\n'

                    '- Message history (optional)\n',
                    style: t.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach evidence (stub)'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dispute submitted (prototype).')),
                        );
                      },
                      child: const Text('Submit dispute'),
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

  class _ListingCard extends StatelessWidget {
    final ListingItem item;
    final int userTrust;
    final bool userVerified;
    final VoidCallback onView;
    final VoidCallback onSafeChat;
    final VoidCallback onDispute;

    const _ListingCard({
      required this.item,
      required this.userTrust,
      required this.userVerified,
      required this.onView,
      required this.onSafeChat,
      required this.onDispute,
    });

    @override
    Widget build(BuildContext context) {
      final t = Theme.of(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTokens.rCard),
                  gradient: LinearGradient(
                    colors: [
                      (isDark ? AppTokens.surfaceDark : AppTokens.surface).withOpacity(0.0),
                      (isDark ? AppTokens.surfaceDark : AppTokens.surface).withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(item.price, style: t.textTheme.titleMedium),
              ),
              const SizedBox(height: 10),
              Text(item.title, style: t.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(item.subtitle, style: t.textTheme.bodyMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Seller trust: ${item.sellerTrust} • ${item.sellerVerified ? 'Verified' : 'Unverified'}',
                    style: t.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (item.scamFlag && item.scamReason != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTokens.dangerTintDark : AppTokens.dangerTintLight,
                    borderRadius: BorderRadius.circular(AppTokens.rCard),
                    border: Border.all(color: isDark ? AppTokens.borderDark : AppTokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scam alert (explainable)', style: t.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(item.scamReason!, style: t.textTheme.bodyLarge),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TextButton(onPressed: onDispute, child: const Text('Dispute')),
                          const Spacer(),
                          Text(
                            item.scamConfidence == null
                                ? ''
                                : 'Confidence: ${(item.scamConfidence! * 100).round()}%',
                            style: t.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  FilledButton(onPressed: onView, child: const Text('View')),
                  const SizedBox(width: 10),
                  OutlinedButton(onPressed: onSafeChat, child: const Text('Safe chat')),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
