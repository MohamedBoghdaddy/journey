
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/theme/tokens.dart';

class AiAssistInline extends StatelessWidget {
  final bool enabled;
  final VoidCallback onImprove;
  final VoidCallback onAutoTag;
  final VoidCallback onSafetyScan;

  const AiAssistInline({
    super.key,
    required this.enabled,
    required this.onImprove,
    required this.onAutoTag,
    required this.onSafetyScan,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTokens.s12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTokens.borderDark
              : AppTokens.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Assist', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Improve draft, suggest tags, and remove phone numbers/IDs.',
            style: t.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: enabled ? onImprove : null,
                child: const Text('Improve draft'),
              ),
              OutlinedButton(
                onPressed: enabled ? onAutoTag : null,
                child: const Text('Auto-tag'),
              ),
              OutlinedButton(
                onPressed: enabled ? onSafetyScan : null,
                child: const Text('Safety scan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
