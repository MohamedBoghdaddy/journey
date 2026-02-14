
  import 'package:flutter/material.dart';
  import 'package:masr_spaces_app/theme/tokens.dart';

  class TrustBadge extends StatelessWidget {
    final int value; // e.g. 62
    final int max; // e.g. 100 or 1000
    final String title; // "Reputation" or "Trust Score"
    final bool showPercent;
    final String visibility; // "Public" / "Neighbors" / "Verified-only"

    const TrustBadge({
      super.key,
      required this.value,
      required this.max,
      required this.title,
      this.showPercent = false,
      this.visibility = 'Neighbors',
    });

    String get display {
      if (showPercent) {
        final pct = ((value / max) * 100).clamp(0, 100).round();
        return '$pct%';
      }
      return '$value';
    }

    @override
    Widget build(BuildContext context) {
      final t = Theme.of(context);
      return InkWell(
        borderRadius: BorderRadius.circular(AppTokens.rPill),
        onTap: () => _openExplainSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.rPill),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTokens.borderDark
                  : AppTokens.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_outlined, size: 16),
              const SizedBox(width: 8),
              Text(display, style: t.textTheme.labelLarge),
            ],
          ),
        ),
      );
    }

    void _openExplainSheet(BuildContext context) {
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
                  Text(title, style: t.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('Scale: 0–$max', style: t.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Text('What it measures', style: t.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '- Reliability signals (reports, accuracy)'
                    '- Community feedback (helpful actions)'
                    '- Verification status (when applicable)',
                    style: t.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text('How to improve', style: t.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '- Submit verifiable reports\n'
                    '- Keep posts clear and honest\n'
                    '- Verify identity for higher-trust actions',
                    style: t.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text('Who can see it', style: t.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(visibility, style: t.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    }
  }
