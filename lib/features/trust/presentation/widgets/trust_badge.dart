import 'package:flutter/material.dart';

class TrustBadge extends StatelessWidget {
  const TrustBadge({super.key, required this.score});

  final int? score;

  String get _label {
    final s = score ?? 0;
    if (s >= 80) return 'Verified';
    if (s >= 60) return 'Trusted';
    if (s >= 40) return 'New';
    return 'Low';
  }

  IconData get _icon {
    final s = score ?? 0;
    if (s >= 80) return Icons.verified_outlined;
    if (s >= 60) return Icons.shield_outlined;
    if (s >= 40) return Icons.fiber_new_outlined;
    return Icons.warning_amber_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16),
          const SizedBox(width: 6),
          Text(_label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
