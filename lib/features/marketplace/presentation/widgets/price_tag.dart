import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({super.key, required this.amount, this.currency});

  final num amount;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.tertiaryContainer,
      ),
      child: Text(
        '${Formatters.money(amount)} ${currency ?? 'EGP'}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: cs.onTertiaryContainer,
            ),
      ),
    );
  }
}
