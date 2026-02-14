import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/chat_thread.dart';

class InboxTile extends StatelessWidget {
  const InboxTile({super.key, required this.thread, required this.onOpen});

  final ChatThread thread;
  final VoidCallback onOpen;

  String get _title {
    if (thread.type == 'space' && thread.spaceId != null) return 'Space ${thread.spaceId}';
    if (thread.type == 'product' && thread.productId != null) return 'Product ${thread.productId}';
    return 'Direct message';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = thread.lastMessageText ?? '';
    final when = thread.lastMessageAt != null ? Formatters.dateTime(thread.lastMessageAt!) : '';
    return Card(
      child: ListTile(
        onTap: onOpen,
        leading: Icon(thread.type == 'dm'
            ? Icons.person_outline
            : thread.type == 'space'
                ? Icons.apartment_outlined
                : Icons.storefront_outlined),
        title: Text(_title),
        subtitle: subtitle.isEmpty ? null : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(when, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
