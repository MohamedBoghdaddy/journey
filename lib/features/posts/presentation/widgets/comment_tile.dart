import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final when = comment.createdAt != null ? Formatters.dateTime(comment.createdAt!) : '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comment.userName ?? comment.userId,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(comment.content),
            const SizedBox(height: 8),
            Text(when, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
