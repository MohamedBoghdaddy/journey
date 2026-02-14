
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/models/content.dart';
import 'package:masr_spaces_app/theme/tokens.dart';
import 'package:masr_spaces_app/ui/components/content_type_chip.dart';
import 'package:masr_spaces_app/ui/components/trust_badge.dart';

class UnifiedFeedCard extends StatelessWidget {
  final FeedItem item;
  final String primaryCta;
  final VoidCallback onPrimary;

  const UnifiedFeedCard({
    super.key,
    required this.item,
    required this.primaryCta,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color? tinted = item.type == ContentType.alert || item.scamFlagged
        ? (isDark ? AppTokens.dangerTintDark : AppTokens.dangerTintLight)
        : null;

    return Card(
      child: Container(
        decoration: tinted == null
            ? null
            : BoxDecoration(
                color: tinted,
                borderRadius: BorderRadius.circular(AppTokens.rCard),
              ),
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ContentTypeChip(type: item.type),
                const Spacer(),
                TrustBadge(
                  value: item.trustScore,
                  max: 100,
                  title: 'Reputation',
                  visibility: 'Neighbors',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.title, style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(item.body, style: t.textTheme.bodyLarge),
            const SizedBox(height: 12),
            if (item.scamFlagged && item.scamReason != null) ...[
              Text(
                'Why flagged: ${item.scamReason}',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppTokens.textDark : AppTokens.text2,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Text(item.neighborhood, style: t.textTheme.bodyMedium),
                const Spacer(),
                FilledButton(
                  onPressed: onPrimary,
                  child: Text(primaryCta),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
