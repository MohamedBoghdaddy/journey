
import 'package:flutter/material.dart';
import 'package:masr_spaces_app/models/content.dart';
import 'package:masr_spaces_app/theme/tokens.dart';

class ContentTypeChip extends StatelessWidget {
  final ContentType type;

  const ContentTypeChip({super.key, required this.type});

  String get label {
    switch (type) {
      case ContentType.question:
        return 'Question';
      case ContentType.alert:
        return 'Alert';
      case ContentType.listing:
        return 'Listing';
      case ContentType.task:
        return 'Task';
      case ContentType.story:
        return 'Story';
      case ContentType.service:
        return 'Service';
    }
  }

  IconData get icon {
    switch (type) {
      case ContentType.question:
        return Icons.help_outline;
      case ContentType.alert:
        return Icons.report_gmailerrorred_outlined;
      case ContentType.listing:
        return Icons.home_work_outlined;
      case ContentType.task:
        return Icons.checklist_outlined;
      case ContentType.story:
        return Icons.auto_stories_outlined;
      case ContentType.service:
        return Icons.handyman_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
