import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onOpen});

  final Post post;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final subtitle = post.createdAt != null ? Formatters.dateTime(post.createdAt!) : '';
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  if (post.spaceId != null) ...[
                    const Icon(Icons.apartment_outlined, size: 16),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
