import 'package:flutter/material.dart';

import '../../domain/entities/space.dart';

class SpaceCard extends StatelessWidget {
  const SpaceCard({
    super.key,
    required this.space,
    required this.onOpen,
    required this.isMemberFuture,
    required this.onToggleJoin,
  });

  final Space space;
  final VoidCallback onOpen;
  final Future<bool> isMemberFuture;
  final ValueChanged<bool> onToggleJoin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.apartment_outlined, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(space.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (space.city != null && space.city!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(space.city!,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                    if (space.description != null &&
                        space.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        space.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FutureBuilder<bool>(
                future: isMemberFuture,
                builder: (context, snap) {
                  final isMember = snap.data ?? false;
                  return TextButton(
                    onPressed: () => onToggleJoin(isMember),
                    child: Text(isMember ? 'Leave' : 'Join'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
